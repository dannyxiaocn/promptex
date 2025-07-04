import SwiftUI
import Foundation

struct PromptListItem: View {
    let prompt: Prompt
    @ObservedObject var promptManager: PromptManager
    
    // Placeholder handling
    @State private var placeholderValues: [String: String] = [:]
    private var placeholderNames: [String] {
        prompt.content.extractPlaceholders()
    }
    
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
                    let substituted = prompt.content.replacingPlaceholders(with: placeholderValues)
                    copyToClipboard(substituted)
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
            
            // Placeholder inputs
            if !placeholderNames.isEmpty {
                HStack(spacing: 6) {
                    ForEach(placeholderNames, id: \.self) { name in
                        HStack(spacing: 2) {
                            Text("\(name):")
                                .font(.caption)
                            TextField("", text: Binding(
                                get: { placeholderValues[name] ?? "" },
                                set: { placeholderValues[name] = $0 }
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 60)
                        }
                    }
                }
            }
            
            // Content preview with highlighted placeholders
            Text(prompt.content.attributedHighlightPlaceholders())
                .font(.caption)
                .lineLimit(2)
            
            // Category and date
            HStack {
                Label(prompt.category.rawValue, systemImage: prompt.category.icon)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(formatRelativeTime(prompt.lastModified))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            // Tags
            if !prompt.tags.isEmpty {
                HStack {
                    ForEach(Array(prompt.tags.prefix(3)), id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.2))
                            .foregroundColor(.accentColor)
                            .cornerRadius(4)
                    }
                    
                    if prompt.tags.count > 3 {
                        Text("+\(prompt.tags.count - 3)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onAppear {
            for name in placeholderNames {
                if placeholderValues[name] == nil {
                    placeholderValues[name] = ""
                }
            }
        }
    }
    
    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        // Notify of user activity
        NotificationCenter.default.post(name: .userActivity, object: nil)
    }
    
    private func formatRelativeTime(_ timestamp: Date) -> String {
        let timeInterval = Date().timeIntervalSince(timestamp)
        
        if timeInterval < 60 {
            return "< 1 min"
        } else if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "\(minutes) min"
        } else if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return "\(hours) hour\(hours == 1 ? "" : "s")"
        } else if timeInterval < 2592000 {
            let days = Int(timeInterval / 86400)
            return "\(days) day\(days == 1 ? "" : "s")"
        } else if timeInterval < 31536000 {
            let months = Int(timeInterval / 2592000)
            return "\(months) month\(months == 1 ? "" : "s")"
        } else {
            let years = Int(timeInterval / 31536000)
            return "\(years) year\(years == 1 ? "" : "s")"
        }
    }
} 