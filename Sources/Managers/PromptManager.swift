import Foundation
import Combine

class PromptManager: ObservableObject {
    @Published var prompts: [Prompt] = []
    @Published var searchText: String = "" {
        didSet {
            // Notify of user activity when search text changes
            if !searchText.isEmpty || !oldValue.isEmpty {
                NotificationCenter.default.post(name: .userActivity, object: nil)
            }
        }
    }
    @Published var selectedCategory: PromptCategory? = nil {
        didSet {
            // Notify of user activity when category filter changes
            if selectedCategory != oldValue {
                NotificationCenter.default.post(name: .userActivity, object: nil)
            }
        }
    }
    @Published var showFavoritesOnly: Bool = false {
        didSet {
            // Notify of user activity when favorites filter changes
            if showFavoritesOnly != oldValue {
                NotificationCenter.default.post(name: .userActivity, object: nil)
            }
        }
    }
    
    private let promptsDirectory: URL
    private let resourcesDirectory: URL // New directory for human-readable markdown copies
    private let metadataFileURL: URL
    
    init() {
        // Create application support directory if it doesn't exist
        let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let promptExDir = appSupportDir.appendingPathComponent("PromptEx")
        
        // Create prompts subdirectory for markdown files
        self.promptsDirectory = promptExDir.appendingPathComponent("prompts")
        // Store human-readable copies in the "resources" folder relative to where the executable is launched
        let cwdResources = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("resources")
        self.resourcesDirectory = cwdResources
        self.metadataFileURL = promptExDir.appendingPathComponent("metadata.json")
        
        try? FileManager.default.createDirectory(at: promptExDir, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: promptsDirectory, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: resourcesDirectory, withIntermediateDirectories: true)
        
        loadPrompts()
    }
    
    // MARK: - Core CRUD Operations
    
    func addPrompt(_ prompt: Prompt) {
        prompts.append(prompt)
        savePrompts()
        // Notify of user activity
        NotificationCenter.default.post(name: .userActivity, object: nil)
    }
    
    func updatePrompt(_ prompt: Prompt) {
        if let index = prompts.firstIndex(where: { $0.id == prompt.id }) {
            prompts[index] = prompt
            savePrompts()
            // Notify of user activity
            NotificationCenter.default.post(name: .userActivity, object: nil)
        }
    }
    
    func deletePrompt(_ prompt: Prompt) {
        prompts.removeAll { $0.id == prompt.id }
        savePrompts()
        // Notify of user activity
        NotificationCenter.default.post(name: .userActivity, object: nil)
    }
    
    func toggleFavorite(_ prompt: Prompt) {
        if let index = prompts.firstIndex(where: { $0.id == prompt.id }) {
            prompts[index].isFavorite.toggle()
            savePrompts()
            // Notify of user activity
            NotificationCenter.default.post(name: .userActivity, object: nil)
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
        // Save each prompt as a separate markdown file
        for prompt in prompts {
            savePromptAsMarkdown(prompt)
        }
        
        // Save lightweight metadata for quick loading
        saveMetadata()
        
        // Clean up any orphaned markdown files
        cleanupOrphanedFiles()
    }
    
    private func loadPrompts() {
        // Try to load from metadata first for quick startup
        if loadFromMetadata() {
            return
        }
        
        // Fallback: scan markdown files and rebuild metadata
        if loadFromMarkdownFiles() {
            saveMetadata() // Save the rebuilt metadata
            return
        }
        
        // If no files exist, create sample data
        createSampleData()
    }
    
    private func savePromptAsMarkdown(_ prompt: Prompt) {
        let filename = sanitizeFilename("\(prompt.title)_\(prompt.id.uuidString.prefix(8)).md")
        let fullMarkdown = generateMarkdownContent(for: prompt)
        let simpleMarkdown = generateSimpleMarkdown(for: prompt)
        
        // Save to primary prompts directory
        let primaryURL = promptsDirectory.appendingPathComponent(filename)
        // Save to resources directory for human inspection
        let resourcesURL = resourcesDirectory.appendingPathComponent(filename)
        
        // Write full content to primary directory
        do {
            try fullMarkdown.write(to: primaryURL, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to save prompt as markdown to \(primaryURL): \(error)")
        }
        // Write simplified content to resources directory
        do {
            try simpleMarkdown.write(to: resourcesURL, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to save simplified prompt to \(resourcesURL): \(error)")
        }
    }
    
    private func generateMarkdownContent(for prompt: Prompt) -> String {
        // Full markdown with metadata for app storage
        let formatter = ISO8601DateFormatter()
        
        var markdown = """
        ---
        title: "\(prompt.title)"
        id: \(prompt.id.uuidString)
        category: \(prompt.category.rawValue)
        favorite: \(prompt.isFavorite)
        created: \(formatter.string(from: prompt.createdAt))
        modified: \(formatter.string(from: prompt.lastModified))
        tags: [\(prompt.tags.map { "\"\($0)\"" }.joined(separator: ", "))]
        ---
        
        # \(prompt.title)
        
        **Category:** \(prompt.category.rawValue) \(prompt.category.icon)  
        **Created:** \(formatRelativeTime(prompt.createdAt))  
        **Modified:** \(formatRelativeTime(prompt.lastModified))  
        **Favorite:** \(prompt.isFavorite ? "⭐ Yes" : "No")
        
        """
        
        if !prompt.tags.isEmpty {
            markdown += "**Tags:** \(prompt.tags.map { "`\($0)`" }.joined(separator: ", "))\n\n"
        }
        
        markdown += """
        ---
        
        \(prompt.content)
        """
        
        return markdown
    }
    
    private func generateSimpleMarkdown(for prompt: Prompt) -> String {
        """
        # \(prompt.title)
        
        \(prompt.content)
        """
    }
    
    private func saveMetadata() {
        // Save lightweight metadata for quick app startup
        let metadata = prompts.map { prompt in
            [
                "id": prompt.id.uuidString,
                "title": prompt.title,
                "category": prompt.category.rawValue,
                "favorite": prompt.isFavorite,
                "created": ISO8601DateFormatter().string(from: prompt.createdAt),
                "modified": ISO8601DateFormatter().string(from: prompt.lastModified),
                "tags": prompt.tags
            ] as [String: Any]
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: metadata, options: .prettyPrinted)
            try data.write(to: metadataFileURL)
        } catch {
            print("Failed to save metadata: \(error)")
        }
    }
    
    private func loadFromMetadata() -> Bool {
        do {
            let data = try Data(contentsOf: metadataFileURL)
            let metadata = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
            
            guard let metadata = metadata else { return false }
            
            let formatter = ISO8601DateFormatter()
            var loadedPrompts: [Prompt] = []
            
            for item in metadata {
                guard let idString = item["id"] as? String,
                      let id = UUID(uuidString: idString),
                      let title = item["title"] as? String,
                      let categoryString = item["category"] as? String,
                      let category = PromptCategory(rawValue: categoryString),
                      let favorite = item["favorite"] as? Bool,
                      let createdString = item["created"] as? String,
                      let created = formatter.date(from: createdString),
                      let modifiedString = item["modified"] as? String,
                      let modified = formatter.date(from: modifiedString),
                      let tags = item["tags"] as? [String] else {
                    continue
                }
                
                // Load content from markdown file
                let filename = sanitizeFilename("\(title)_\(id.uuidString.prefix(8)).md")
                let fileURL = promptsDirectory.appendingPathComponent(filename)
                
                if let content = loadContentFromMarkdown(fileURL) {
                    let prompt = Prompt(
                        id: id,
                        title: title,
                        content: content,
                        category: category,
                        tags: tags,
                        createdAt: created,
                        lastModified: modified,
                        isFavorite: favorite
                    )
                    loadedPrompts.append(prompt)
                }
            }
            
            prompts = loadedPrompts
            return true
            
        } catch {
            return false
        }
    }
    
    private func loadFromMarkdownFiles() -> Bool {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: promptsDirectory,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
            ).filter { $0.pathExtension == "md" }
            
            var loadedPrompts: [Prompt] = []
            
            for fileURL in fileURLs {
                if let prompt = parseMarkdownFile(fileURL) {
                    loadedPrompts.append(prompt)
                }
            }
            
            prompts = loadedPrompts
            return !prompts.isEmpty
            
        } catch {
            print("Failed to load from markdown files: \(error)")
            return false
        }
    }
    
    private func parseMarkdownFile(_ fileURL: URL) -> Prompt? {
        do {
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            
            // Parse YAML frontmatter
            guard let frontmatterEnd = content.range(of: "\n---\n")?.upperBound else {
                return nil
            }
            
            let frontmatter = String(content[..<frontmatterEnd])
            let body = String(content[frontmatterEnd...])
            
            // Extract content after the markdown headers
            let lines = body.components(separatedBy: .newlines)
            var contentStart = 0
            for (index, line) in lines.enumerated() {
                if line.trimmingCharacters(in: .whitespaces) == "---" {
                    contentStart = index + 1
                    break
                }
            }
            
            let promptContent = lines[contentStart...].joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Parse frontmatter fields
            guard let title = extractFrontmatterValue(frontmatter, key: "title"),
                  let idString = extractFrontmatterValue(frontmatter, key: "id"),
                  let id = UUID(uuidString: idString),
                  let categoryString = extractFrontmatterValue(frontmatter, key: "category"),
                  let category = PromptCategory(rawValue: categoryString) else {
                return nil
            }
            
            let favorite = extractFrontmatterValue(frontmatter, key: "favorite") == "true"
            let tags = extractFrontmatterArray(frontmatter, key: "tags")
            
            let formatter = ISO8601DateFormatter()
            let created = extractFrontmatterValue(frontmatter, key: "created").flatMap { formatter.date(from: $0) } ?? Date()
            let modified = extractFrontmatterValue(frontmatter, key: "modified").flatMap { formatter.date(from: $0) } ?? Date()
            
            return Prompt(
                id: id,
                title: title,
                content: promptContent,
                category: category,
                tags: tags,
                createdAt: created,
                lastModified: modified,
                isFavorite: favorite
            )
            
        } catch {
            print("Failed to parse markdown file \(fileURL): \(error)")
            return nil
        }
    }
    
    private func loadContentFromMarkdown(_ fileURL: URL) -> String? {
        do {
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            
            // Find the content after the second "---"
            let components = content.components(separatedBy: "\n---\n")
            if components.count >= 3 {
                return components[2].trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            return nil
        } catch {
            return nil
        }
    }
    
    private func cleanupOrphanedFiles() {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: promptsDirectory,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
            ).filter { $0.pathExtension == "md" }
            
            let currentFilenames = Set(prompts.map { prompt in
                sanitizeFilename("\(prompt.title)_\(prompt.id.uuidString.prefix(8)).md")
            })
            
            for fileURL in fileURLs {
                let filename = fileURL.lastPathComponent
                if !currentFilenames.contains(filename) {
                    try? FileManager.default.removeItem(at: fileURL)
                }
            }
        } catch {
            print("Failed to cleanup orphaned files: \(error)")
        }
    }
    
    private func sanitizeFilename(_ filename: String) -> String {
        let invalidCharacters = CharacterSet(charactersIn: ":/\\?%*|\"<>")
        return filename.components(separatedBy: invalidCharacters).joined(separator: "_")
    }
    
    private func extractFrontmatterValue(_ frontmatter: String, key: String) -> String? {
        let pattern = "\(key):\\s*\"?([^\"\\n]+)\"?"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        
        let range = NSRange(frontmatter.startIndex..<frontmatter.endIndex, in: frontmatter)
        if let match = regex.firstMatch(in: frontmatter, range: range) {
            let valueRange = Range(match.range(at: 1), in: frontmatter)!
            return String(frontmatter[valueRange])
        }
        
        return nil
    }
    
    private func extractFrontmatterArray(_ frontmatter: String, key: String) -> [String] {
        let pattern = "\(key):\\s*\\[([^\\]]+)\\]"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        
        let range = NSRange(frontmatter.startIndex..<frontmatter.endIndex, in: frontmatter)
        if let match = regex.firstMatch(in: frontmatter, range: range) {
            let valueRange = Range(match.range(at: 1), in: frontmatter)!
            let arrayContent = String(frontmatter[valueRange])
            
            return arrayContent
                .components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .map { $0.trimmingCharacters(in: CharacterSet(charactersIn: "\"")) }
                .filter { !$0.isEmpty }
        }
        
        return []
    }
    
    private func formatRelativeTime(_ timestamp: Date) -> String {
        let timeInterval = Date().timeIntervalSince(timestamp)
        
        if timeInterval < 60 {
            return "< 1 min ago"
        } else if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "\(minutes) min ago"
        } else if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else if timeInterval < 2592000 {
            let days = Int(timeInterval / 86400)
            return "\(days) day\(days == 1 ? "" : "s") ago"
        } else if timeInterval < 31536000 {
            let months = Int(timeInterval / 2592000)
            return "\(months) month\(months == 1 ? "" : "s") ago"
        } else {
            let years = Int(timeInterval / 31536000)
            return "\(years) year\(years == 1 ? "" : "s") ago"
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