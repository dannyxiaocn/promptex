# PromptEx - AI Prompt Manager for macOS

A floating window app for macOS that helps you manage and organize your AI prompts. Access your prompt library from anywhere with a global hotkey.

## Features

### 🔍 **Search & Organization**
- Real-time search across all prompts (title, content, and tags)
- Category-based filtering (General, Coding, Writing, Analysis, Creative, Random Ideas)
- Favorites system for quick access
- Tag-based organization

### 🎯 **Global Access**
- **Global Hotkey**: `⌘ + ⇧ + P` (customizable)
- Floating window that stays on top
- Invoke from any application
- Quick show/hide functionality

### 📝 **Prompt Management**
- **Quick Add Mode**: Clean, simple text input interface
- **Detailed Add Mode**: Full featured editor with categories and tags
- **Easy Copy**: One-click copy buttons throughout the interface
- **Keyboard Shortcuts**: Copy with ⌘C, Quick Add with ⌘N
- Auto-save functionality

### 💡 **Idea Conversion (Extension Feature)**
- Store random ideas in the "Random Ideas" category
- Convert ideas to structured prompts with one click
- Automatic prompt formatting and enhancement

### 🎨 **Modern Interface**
- Native macOS design with SwiftUI
- Split-view layout for efficient browsing
- Dark/Light mode support
- Responsive design

## Installation

### Requirements
- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later (for building from source)

### Building from Source

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd promptex
   ```

2. **Build with Swift Package Manager**
   ```bash
   swift build -c release
   ```

3. **Run the application**
   ```bash
   swift run
   ```

### Alternative: Xcode Build

1. Open Terminal and navigate to the project directory
2. Generate Xcode project:
   ```bash
   swift package generate-xcodeproj
   ```
3. Open `PromptEx.xcodeproj` in Xcode
4. Build and run (⌘ + R)

## Usage

### First Launch
1. The app will start hidden from the dock (runs as accessory)
2. Use the global hotkey `⌘ + ⇧ + P` to show the window
3. The app comes with sample prompts to get you started

### Creating Prompts

**Quick Add Mode (Recommended):**
1. Click the "+" button in the sidebar (or press `⌘ + N`)
2. Simply type or paste your prompt/idea
3. Choose "Save as Prompt" or "Save as Idea"
4. Done! The app auto-generates a title and tags it appropriately

**Detailed Add Mode:**
1. Click the "+" button dropdown and select "Detailed Add" (or press `⌘ + ⇧ + N`)
2. Fill in the title, content, and select a category
3. Add custom tags for better organization
4. Save to your prompt library

### Quick Access
1. Press the global hotkey from any application
2. Search for your prompt using the search bar
3. Click on a prompt to view full content
4. Use the copy button to add the prompt to your clipboard

### Converting Ideas to Prompts
1. Create an entry in the "Random Ideas" category
2. Click the conversion button (→) in the detail view
3. A structured prompt will be automatically generated
4. Edit and refine as needed

## Keyboard Shortcuts

- `⌘ + ⇧ + P` - Toggle PromptEx window (global)
- `⌘ + N` - Quick Add new prompt
- `⌘ + ⇧ + N` - Detailed Add new prompt  
- `⌘ + C` - Copy selected prompt content
- `⌘ + F` - Focus search field
- `⌘ + W` - Hide window
- `⌘ + Q` - Quit application
- `Escape` - Cancel/Close dialogs

## Data Storage

Prompts are stored locally in JSON format at:
```
~/Library/Application Support/PromptEx/prompts.json
```

The app automatically creates backups and handles data migration between versions.

## Categories

- **General**: Multi-purpose prompts
- **Coding**: Programming and development prompts
- **Writing**: Content creation and editing prompts
- **Analysis**: Data analysis and research prompts
- **Creative**: Artistic and creative prompts
- **Random Ideas**: Quick thoughts and concepts

## Privacy

- All data is stored locally on your device
- No network requests or data transmission
- No analytics or tracking
- Complete offline functionality

## Contributing

This is a personal project, but suggestions and feedback are welcome!

## License

[Your chosen license here]

## Troubleshooting

### Global Hotkey Not Working
- Check System Preferences > Security & Privacy > Accessibility
- Ensure PromptEx has accessibility permissions
- Try restarting the application

### Window Not Appearing
- Try pressing the hotkey again
- Check if the app is running in Activity Monitor
- Restart the application

### Data Not Saving
- Check disk permissions for Application Support folder
- Ensure sufficient disk space
- Try creating a new prompt to test

## Version History

### v1.0.0
- Initial release
- Basic prompt management
- Global hotkey support
- Search and filtering
- Idea conversion feature

# PromptEx

A fast, intuitive prompt management app for macOS that runs in your menu bar.

## Features

- 🚀 **Menu Bar Access**: Always available in your system tray
- ⚡ **Global Hotkey**: Quick access with ⌘⇧P
- 📝 **Quick Add**: Instant prompt capture from anywhere
- 🗂️ **Smart Organization**: Category-based prompt management
- 🔍 **Powerful Search**: Find prompts instantly
- ⭐ **Favorites**: Mark important prompts for quick access
- 💾 **Local Storage**: All data stays on your machine
- 🎨 **Native macOS UI**: Clean, familiar interface

## Quick Start

### 1. One-Time Setup
```bash
# Clone and run (only need to do this once)
./launch.sh
```

### 2. Daily Usage
After the initial setup, PromptEx runs persistently in your menu bar:

- **Menu Bar Icon**: Look for the speech bubble icon 💬 in your menu bar
- **Global Hotkey**: Press `⌘⇧P` from anywhere to toggle the window
- **Menu Options**: Right-click the menu bar icon for quick actions

### 3. Menu Bar Options
- **Show/Hide PromptEx**: Toggle the main window
- **Quick Add**: Jump straight to prompt creation (`⌘N`)
- **About**: App information and features
- **Hotkey**: Reminder that `⌘⇧P` toggles the window
- **Quit**: Completely close the app

## How to Use

### Adding Prompts
1. **Quick Add**: Use the global hotkey `⌘⇧P` or menu bar → "Quick Add"
2. **Detailed Add**: Use `⌘⇧N` for full prompt creation with categories

### Managing Prompts
- **Edit**: Click the pencil icon on any prompt
- **Favorite**: Click the heart icon to mark as favorite
- **Copy**: Click the clipboard icon to copy content
- **Delete**: Click the trash icon to remove
- **Convert Ideas**: Turn ideas into full prompts with the arrow icon

### Organization
- **Categories**: General, Work, Personal, Creative, Technical, Ideas
- **Search**: Type in the search bar to find prompts instantly
- **Filters**: Filter by category or show favorites only
- **Tags**: Automatic tagging (e.g., "quick-add" for rapid entries)

## Keyboard Shortcuts

- `⌘⇧P` - Toggle PromptEx window (global)
- `⌘N` - Quick Add mode
- `⌘⇧N` - Detailed Add dialog
- `⌘C` - Copy prompt content (when viewing a prompt)
- `⌘⇧C` - Copy with formatting
- `Enter` - Save (in Quick Add mode)

## Persistence

PromptEx runs as a background application:
- ✅ **Always Available**: Accessible even when main window is closed
- ✅ **Survives Restarts**: Automatically starts on system boot (optional)
- ✅ **Low Resource**: Minimal memory and CPU usage
- ✅ **Data Persistence**: Prompts are saved locally and persist between sessions

## Installation

### Requirements
- macOS 13.0 or later
- Swift 5.9 or later

### Setup
```bash
# 1. Clone the repository
git clone [repository-url]
cd promptex

# 2. Run the launch script (builds and starts the app)
./launch.sh
```

The app will:
1. Build automatically
2. Start running in the background
3. Show a menu bar icon
4. Be ready to use immediately

### Stopping the App
- **Graceful**: Menu bar → "Quit PromptEx"
- **Force quit**: Use Activity Monitor or `killall PromptEx`

## Development

### Project Structure
```
Sources/
├── main.swift              # App entry point
├── AppDelegate.swift       # Menu bar and window management
├── Models/
│   └── Prompt.swift       # Data model
├── Managers/
│   └── PromptManager.swift # Business logic
└── Views/
    ├── PromptExView.swift     # Main interface
    ├── QuickAddView.swift     # Quick prompt creation
    ├── AddPromptView.swift    # Detailed prompt creation
    ├── EditPromptView.swift   # Prompt editing
    ├── PromptDetailView.swift # Prompt display/editing
    └── PromptListItem.swift   # List item component
```

### Building from Source
```bash
# Debug build
swift build

# Release build
swift build -c release

# Run directly
swift run
```

## Troubleshooting

### Menu Bar Icon Not Showing
- Check if the app is running: Activity Monitor → search "PromptEx"
- Try restarting: Quit and run `./launch.sh` again

### Global Hotkey Not Working
- Check System Preferences → Security & Privacy → Accessibility
- Add Terminal or your shell to the list of allowed apps
- Restart the app after granting permissions

### Window Not Appearing
- Click the menu bar icon and select "Show PromptEx"
- Try the global hotkey `⌘⇧P`
- Check if window is hidden behind other windows

### Data Not Persisting
- Prompts are saved automatically in `~/Library/Application Support/PromptEx/`
- Check file permissions in that directory
- Try running the app with appropriate permissions

## License

[Your License Here]

## Contributing

[Contributing Guidelines Here] 