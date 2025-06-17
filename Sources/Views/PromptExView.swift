import SwiftUI

struct PromptExView: View {
    @ObservedObject var promptManager: PromptManager
    @State private var selectedPrompt: Prompt?
    @State private var showingAddPrompt = false
    @State private var showingQuickAdd = false
    @State private var editingPrompt: Prompt?
    @State private var sidebarWidth: CGFloat = 300
    
    var body: some View {
        HStack(spacing: 0) {
            // Sidebar with search and prompt list
            VStack(spacing: 0) {
                // Search and filter header
                VStack(alignment: .leading, spacing: 8) {
                    // Top bar with search and add button
                    HStack {
                        Text("Prompts")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            // Primary quick add button
                            Button {
                                selectedPrompt = nil
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .imageScale(.large)
                                    .foregroundColor(.accentColor)
                            }
                            .buttonStyle(.plain)
                            .help("Quick Add (⌘N)")
                            
                            // Menu for more options
                            Menu {
                                Button {
                                    selectedPrompt = nil
                                } label: {
                                    Label("Quick Add", systemImage: "bolt")
                                }
                                
                                Button {
                                    showingAddPrompt = true
                                } label: {
                                    Label("Detailed Add", systemImage: "plus.circle")
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                                    .imageScale(.medium)
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                            .help("More options")
                        }
                    }
                    
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search prompts...", text: $promptManager.searchText)
                            .textFieldStyle(.plain)
                        
                        if !promptManager.searchText.isEmpty {
                            Button {
                                promptManager.searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.controlBackgroundColor))
                    .cornerRadius(8)
                    
                    // Category filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            CategoryFilterButton(
                                title: "All",
                                isSelected: promptManager.selectedCategory == nil,
                                action: { promptManager.selectedCategory = nil }
                            )
                            
                            ForEach(PromptCategory.allCases, id: \.self) { category in
                                CategoryFilterButton(
                                    title: category.rawValue,
                                    icon: category.icon,
                                    isSelected: promptManager.selectedCategory == category,
                                    action: { promptManager.selectedCategory = category }
                                )
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                    
                    // Favorites toggle
                    Toggle("Favorites Only", isOn: $promptManager.showFavoritesOnly)
                        .toggleStyle(.checkbox)
                        .font(.caption)
                }
                .padding()
                .background(Color(.windowBackgroundColor))
                
                Divider()
                
                // Prompt list
                List(promptManager.filteredPrompts, id: \.id, selection: $selectedPrompt) { prompt in
                    PromptListItem(prompt: prompt, promptManager: promptManager)
                        .tag(prompt)
                }
                .listStyle(.sidebar)
            }
            .frame(width: sidebarWidth)
            
            // Draggable divider
            Rectangle()
                .fill(Color(.separatorColor).opacity(0.5))
                .frame(width: 8)
                .overlay(
                    Rectangle()
                        .fill(Color(.separatorColor))
                        .frame(width: 1)
                )
                .onHover { hovering in
                    if hovering {
                        NSCursor.resizeLeftRight.set()
                    } else {
                        NSCursor.arrow.set()
                    }
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let newWidth = sidebarWidth + value.translation.width
                            sidebarWidth = max(200, min(600, newWidth))
                        }
                        .onEnded { _ in
                            NSCursor.arrow.set()
                        }
                )
            
            // Detail view
            if let prompt = selectedPrompt {
                PromptDetailView(
                    prompt: prompt,
                    promptManager: promptManager,
                    editingPrompt: $editingPrompt
                )
            } else {
                // Direct Quick Add when no prompt selected
                QuickAddView(promptManager: promptManager) { newPrompt in
                    selectedPrompt = newPrompt
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingAddPrompt) {
            AddPromptView(promptManager: promptManager)
        }
        .sheet(item: $editingPrompt) { prompt in
            EditPromptView(prompt: prompt, promptManager: promptManager)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification)) { _ in
            // Window became active
        }
        .onReceive(NotificationCenter.default.publisher(for: .triggerQuickAdd)) { _ in
            // Triggered from menu bar - switch to quick add mode
            selectedPrompt = nil
        }
        .background(
            // Invisible buttons for keyboard shortcuts
            VStack {
                Button("") {
                    selectedPrompt = nil
                }
                .keyboardShortcut("n", modifiers: .command)
                .opacity(0)
                
                Button("") {
                    showingAddPrompt = true
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])
                .opacity(0)
            }
            .frame(width: 0, height: 0)
            .clipped()
        )
    }
}

struct CategoryFilterButton: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(.caption)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isSelected ? Color.accentColor : Color(.controlBackgroundColor))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
} 