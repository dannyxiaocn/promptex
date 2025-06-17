import SwiftUI

struct EditPromptView: View {
    let prompt: Prompt
    @ObservedObject var promptManager: PromptManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var content = ""
    @State private var category: PromptCategory = .general
    @State private var tagInput = ""
    @State private var tags: [String] = []
    @State private var isFavorite = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Edit Prompt")
                    .font(.title)
                    .fontWeight(.semibold)
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Save") {
                        savePrompt()
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(Color(.windowBackgroundColor))
            
            Divider()
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Basic Information
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Basic Information")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            // Title
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Title")
                                    .font(.headline)
                                
                                TextField("Enter prompt title", text: $title)
                                    .textFieldStyle(.roundedBorder)
                                    .font(.body)
                            }
                            
                            // Category
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Category")
                                    .font(.headline)
                                
                                Picker("Category", selection: $category) {
                                    ForEach(PromptCategory.allCases, id: \.self) { category in
                                        Label(category.rawValue, systemImage: category.icon)
                                            .tag(category)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            // Favorites toggle
                            HStack {
                                Text("Add to favorites")
                                    .font(.headline)
                                
                                Spacer()
                                
                                Toggle("", isOn: $isFavorite)
                                    .toggleStyle(.switch)
                            }
                        }
                    }
                    
                    // Content
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Content")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        TextEditor(text: $content)
                            .font(.body)
                            .frame(minHeight: 200)
                            .padding(8)
                            .background(Color(.textBackgroundColor))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.separatorColor), lineWidth: 1)
                            )
                            .overlay(
                                Group {
                                    if content.isEmpty {
                                        Text("Enter your prompt content...")
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 16)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                    }
                                }
                            )
                    }
                    
                    // Tags
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Tags")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        HStack {
                            TextField("Add tag", text: $tagInput)
                                .textFieldStyle(.roundedBorder)
                                .onSubmit {
                                    addTag()
                                }
                            
                            Button("Add") {
                                addTag()
                            }
                            .disabled(tagInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            .buttonStyle(.bordered)
                        }
                        
                        if !tags.isEmpty {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], alignment: .leading, spacing: 8) {
                                ForEach(tags, id: \.self) { tag in
                                    HStack {
                                        Text(tag)
                                            .font(.caption)
                                        
                                        Button {
                                            removeTag(tag)
                                        } label: {
                                            Image(systemName: "xmark")
                                                .font(.caption2)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.accentColor.opacity(0.2))
                                    .foregroundColor(.accentColor)
                                    .cornerRadius(6)
                                }
                            }
                        }
                    }
                }
                .padding(24)
            }
        }
        .frame(minWidth: 600, minHeight: 700)
        .onAppear {
            loadPromptData()
        }
    }
    
    private func loadPromptData() {
        title = prompt.title
        content = prompt.content
        category = prompt.category
        tags = prompt.tags
        isFavorite = prompt.isFavorite
    }
    
    private func addTag() {
        let trimmedTag = tagInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !tags.contains(trimmedTag) {
            tags.append(trimmedTag)
            tagInput = ""
        }
    }
    
    private func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
    
    private func savePrompt() {
        var updatedPrompt = prompt
        updatedPrompt.title = title
        updatedPrompt.content = content
        updatedPrompt.category = category
        updatedPrompt.tags = tags
        updatedPrompt.isFavorite = isFavorite
        updatedPrompt.lastModified = Date()
        
        promptManager.updatePrompt(updatedPrompt)
        dismiss()
    }
} 