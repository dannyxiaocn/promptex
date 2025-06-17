import SwiftUI

struct PromptListItem: View {
    let prompt: Prompt
    @ObservedObject var promptManager: PromptManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Title and action buttons
            HStack {
                Text(prompt.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                // Quick copy button
                Button {
                    copyToClipboard(prompt.content)
                } label: {
                    Image(systemName: "doc.on.clipboard")
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
                .help("Copy to clipboard")
                
                Button {
                    promptManager.toggleFavorite(prompt)
                } label: {
                    Image(systemName: prompt.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(prompt.isFavorite ? .red : .secondary)
                }
                .buttonStyle(.plain)
                .help("Toggle favorite")
            }
            
            // Content preview
            Text(prompt.content)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            // Category and date
            HStack {
                Label(prompt.category.rawValue, systemImage: prompt.category.icon)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(prompt.lastModified, style: .relative)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            // Tags
            if !prompt.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(prompt.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.accentColor.opacity(0.2))
                                .foregroundColor(.accentColor)
                                .cornerRadius(4)
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
    
    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
} 