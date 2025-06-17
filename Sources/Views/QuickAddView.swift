import SwiftUI

struct QuickAddView: View {
    @ObservedObject var promptManager: PromptManager
    let onPromptCreated: ((Prompt) -> Void)?
    
    @State private var inputText = ""
    @FocusState private var isTextFieldFocused: Bool
    
    init(promptManager: PromptManager, onPromptCreated: ((Prompt) -> Void)? = nil) {
        self.promptManager = promptManager
        self.onPromptCreated = onPromptCreated
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Quick Add")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Capture your prompt or idea instantly")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Text input area
            VStack(alignment: .leading, spacing: 8) {
                Text("Content")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                TextEditor(text: $inputText)
                    .focused($isTextFieldFocused)
                    .font(.body)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(12)
                    .background(Color(.textBackgroundColor))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.separatorColor), lineWidth: 1)
                    )
            }
            
            // Bottom action area
            VStack(spacing: 12) {
                HStack {
                    Text("Auto-saved as General prompt • Edit categories later")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                HStack(spacing: 12) {
                    Button("Clear") {
                        inputText = ""
                        isTextFieldFocused = true
                    }
                    .disabled(inputText.isEmpty)
                    
                    Spacer()
                    
                    Button("Save as Idea") {
                        saveAsIdea()
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .buttonStyle(.bordered)
                    
                    Button("Save as Prompt") {
                        saveAsPrompt()
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .keyboardShortcut(.return, modifiers: .command)
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            isTextFieldFocused = true
        }
    }
    
    private func saveAsPrompt() {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        // Generate a title from the first line or first few words
        let title = generateTitle(from: trimmedText)
        
        let newPrompt = Prompt(
            title: title,
            content: trimmedText,
            category: .general,
            tags: ["quick-add"]
        )
        
        promptManager.addPrompt(newPrompt)
        
        // Clear the input and notify parent about the new prompt
        inputText = ""
        onPromptCreated?(newPrompt)
    }
    
    private func saveAsIdea() {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        let title = generateTitle(from: trimmedText)
        
        let newIdea = Prompt(
            title: title,
            content: trimmedText,
            category: .ideas,
            tags: ["quick-add", "idea"]
        )
        
        promptManager.addPrompt(newIdea)
        
        // Clear the input and notify parent about the new prompt
        inputText = ""
        onPromptCreated?(newIdea)
    }
    
    private func generateTitle(from text: String) -> String {
        // Get the first line or first 50 characters
        let lines = text.components(separatedBy: .newlines)
        if let firstLine = lines.first, !firstLine.isEmpty {
            return String(firstLine.prefix(50))
        }
        
        // If no line breaks, take first 50 characters
        return String(text.prefix(50))
    }
} 