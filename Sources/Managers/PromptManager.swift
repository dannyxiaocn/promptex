import Foundation
import Combine

class PromptManager: ObservableObject {
    @Published var prompts: [Prompt] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: PromptCategory? = nil
    @Published var showFavoritesOnly: Bool = false
    
    private let fileURL: URL
    
    init() {
        // Create application support directory if it doesn't exist
        let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let promptExDir = appSupportDir.appendingPathComponent("PromptEx")
        
        try? FileManager.default.createDirectory(at: promptExDir, withIntermediateDirectories: true)
        self.fileURL = promptExDir.appendingPathComponent("prompts.json")
        
        loadPrompts()
    }
    
    // MARK: - Core CRUD Operations
    
    func addPrompt(_ prompt: Prompt) {
        prompts.append(prompt)
        savePrompts()
    }
    
    func updatePrompt(_ prompt: Prompt) {
        if let index = prompts.firstIndex(where: { $0.id == prompt.id }) {
            prompts[index] = prompt
            savePrompts()
        }
    }
    
    func deletePrompt(_ prompt: Prompt) {
        prompts.removeAll { $0.id == prompt.id }
        savePrompts()
    }
    
    func toggleFavorite(_ prompt: Prompt) {
        if let index = prompts.firstIndex(where: { $0.id == prompt.id }) {
            prompts[index].isFavorite.toggle()
            savePrompts()
        }
    }
    
    // MARK: - Search and Filter
    
    var filteredPrompts: [Prompt] {
        var filtered = prompts
        
        // Filter by favorites
        if showFavoritesOnly {
            filtered = filtered.filter { $0.isFavorite }
        }
        
        // Filter by category
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { prompt in
                prompt.title.localizedCaseInsensitiveContains(searchText) ||
                prompt.content.localizedCaseInsensitiveContains(searchText) ||
                prompt.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Sort by last modified (most recent first)
        return filtered.sorted { $0.lastModified > $1.lastModified }
    }
    
    // MARK: - Conversion Functions (Extension Feature)
    
    func convertIdeaToPrompt(_ idea: Prompt) -> Prompt {
        let promptContent = """
        Please help me with the following idea/task:
        
        \(idea.content)
        
        Could you provide detailed guidance, suggestions, or implementation steps?
        """
        
        let newPrompt = Prompt(
            title: "Prompt: \(idea.title)",
            content: promptContent,
            category: .general,
            tags: idea.tags + ["converted-from-idea"]
        )
        
        return newPrompt
    }
    
    // MARK: - Data Persistence
    
    private func savePrompts() {
        do {
            let data = try JSONEncoder().encode(prompts)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save prompts: \(error)")
        }
    }
    
    private func loadPrompts() {
        do {
            let data = try Data(contentsOf: fileURL)
            prompts = try JSONDecoder().decode([Prompt].self, from: data)
        } catch {
            // If file doesn't exist or is corrupted, start with sample data
            createSampleData()
        }
    }
    
    private func createSampleData() {
        let samplePrompts = [
            Prompt(
                title: "Code Review Assistant",
                content: "Please review this code and provide suggestions for improvement, focusing on readability, performance, and best practices:",
                category: .coding,
                tags: ["code-review", "development"]
            ),
            Prompt(
                title: "Creative Writing Helper",
                content: "Help me write a creative story about [topic]. Please include vivid descriptions, engaging dialogue, and a compelling plot structure.",
                category: .creative,
                tags: ["writing", "storytelling"]
            ),
            Prompt(
                title: "Random Idea",
                content: "What if we could create an app that combines voice notes with AI to automatically organize thoughts?",
                category: .ideas,
                tags: ["brainstorming", "app-idea"]
            )
        ]
        
        prompts = samplePrompts
        savePrompts()
    }
} 