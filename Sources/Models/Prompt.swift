import Foundation

struct Prompt: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var content: String
    var category: PromptCategory
    var tags: [String]
    var createdAt: Date
    var lastModified: Date
    var isFavorite: Bool
    
    init(title: String, content: String, category: PromptCategory = .general, tags: [String] = [], isFavorite: Bool = false) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.category = category
        self.tags = tags
        self.createdAt = Date()
        self.lastModified = Date()
        self.isFavorite = isFavorite
    }
    
    mutating func updateContent(_ newContent: String) {
        guard newContent != content else { return }
        self.content = newContent
        self.lastModified = Date()
    }
    
    mutating func addTag(_ tag: String) {
        if !tags.contains(tag) {
            tags.append(tag)
            lastModified = Date()
        }
    }
    
    mutating func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
        lastModified = Date()
    }
}

enum PromptCategory: String, CaseIterable, Codable {
    case general = "General"
    case coding = "Coding"
    case writing = "Writing"
    case analysis = "Analysis"
    case creative = "Creative"
    case ideas = "Random Ideas"
    
    var icon: String {
        switch self {
        case .general: return "doc.text"
        case .coding: return "chevron.left.forwardslash.chevron.right"
        case .writing: return "pencil"
        case .analysis: return "chart.bar"
        case .creative: return "paintbrush"
        case .ideas: return "lightbulb"
        }
    }
} 