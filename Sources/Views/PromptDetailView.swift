import SwiftUI

struct PromptDetailView: View {
    let prompt: Prompt
    @ObservedObject var promptManager: PromptManager
    @Binding var editingPrompt: Prompt?
    var onPromptDeleted: (() -> Void)? = nil
    
    @State private var contentText: String = ""
    @State private var updateTimer: Timer?
    // Track editing focus to auto-select
    @FocusState private var isEditorFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(prompt.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Label(prompt.category.rawValue, systemImage: prompt.category.icon)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("Modified \(formatRelativeTime(prompt.lastModified))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Action buttons
                HStack(spacing: 8) {
                    Button {
                        promptManager.toggleFavorite(prompt)
                    } label: {
                        Image(systemName: prompt.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(prompt.isFavorite ? .red : .secondary)
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        editingPrompt = prompt
                        // Notify of user activity
                        NotificationCenter.default.post(name: .userActivity, object: nil)
                    } label: {
                        Image(systemName: "pencil")
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        copyToClipboard(prompt.content)
                    } label: {
                        Image(systemName: "doc.on.clipboard")
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut("c", modifiers: [.command])
                    .help("Copy content to clipboard (⌘C)")
                    
                    if prompt.category == .ideas {
                        Button {
                            let convertedPrompt = promptManager.convertIdeaToPrompt(prompt)
                            promptManager.addPrompt(convertedPrompt)
                        } label: {
                            Image(systemName: "arrow.right.circle")
                        }
                        .buttonStyle(.plain)
                        .help("Convert idea to prompt")
                    }
                    
                    Button {
                        promptManager.deletePrompt(prompt)
                        onPromptDeleted?()
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Divider()
            
            // Content (editable)
            VStack(alignment: .leading, spacing: 12) {
                Text("Content (editable)")
                    .font(.headline)
                
                TextEditor(text: $contentText)
                    .id(prompt.id)
                    .focused($isEditorFocused)
                    .font(.body)
                    .frame(minHeight: 160)
                    .padding(8)
                    .background(Color(.textBackgroundColor))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.separatorColor), lineWidth: 1)
                    )
                    .onChange(of: contentText) { newValue in
                        // Cancel previous timer
                        updateTimer?.invalidate()
                        
                        // Only update if user is actively editing and content changed
                        guard isEditorFocused else { return }
                        
                        // Debounce updates to avoid too frequent saves
                        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                            guard newValue != prompt.content else { return }
                            var updated = prompt
                            updated.updateContent(newValue)
                            promptManager.updatePrompt(updated)
                        }
                    }
                
                HStack {
                    Spacer()
                    Button {
                        copyToClipboard(contentText)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "doc.on.clipboard")
                            Text("Copy")
                        }
                    }
                    .keyboardShortcut("c", modifiers: [.command])
                    .buttonStyle(.borderedProminent)
                }
            }
            .frame(maxWidth: .infinity)
            
            // Tags section
            if !prompt.tags.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tags")
                        .font(.headline)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], alignment: .leading, spacing: 8) {
                        ForEach(prompt.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.accentColor.opacity(0.2))
                                .foregroundColor(.accentColor)
                                .cornerRadius(6)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            contentText = prompt.content
        }
        .onChange(of: prompt) { newPrompt in
            contentText = newPrompt.content
            updateTimer?.invalidate()
        }
        .onChange(of: prompt.content) { newContent in
            // Sync content if it was updated externally (not from this editor)
            if !isEditorFocused {
                contentText = newContent
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