import Cocoa
import SwiftUI
import KeyboardShortcuts

class AppDelegate: NSObject, NSApplicationDelegate {
    var floatingWindow: NSWindow?
    var promptManager = PromptManager()
    var statusBarItem: NSStatusItem?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Keep app running in background but show in menu bar
        NSApp.setActivationPolicy(.accessory)
        
        // Setup menu bar
        setupMenuBar()
        
        // Setup global hotkey
        setupGlobalHotkey()
        
        // Create floating window
        createFloatingWindow()
    }
    
    private func setupMenuBar() {
        // Create status bar item
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusBarItem?.button {
            // Set icon - using a system symbol
            button.image = NSImage(systemSymbolName: "text.bubble", accessibilityDescription: "PromptEx")
            button.toolTip = "PromptEx - AI Prompt Manager"
        }
        
        // Create menu
        let menu = NSMenu()
        
        // Show/Hide window item
        let toggleItem = NSMenuItem(title: "Show PromptEx", action: #selector(toggleFloatingWindow), keyEquivalent: "")
        toggleItem.target = self
        menu.addItem(toggleItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Quick Add item
        let quickAddItem = NSMenuItem(title: "Quick Add", action: #selector(showQuickAdd), keyEquivalent: "n")
        quickAddItem.keyEquivalentModifierMask = [.command]
        quickAddItem.target = self
        menu.addItem(quickAddItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Settings/Info section
        let aboutItem = NSMenuItem(title: "About PromptEx", action: #selector(showAbout), keyEquivalent: "")
        aboutItem.target = self
        menu.addItem(aboutItem)
        
        // Keyboard shortcut info
        let shortcutItem = NSMenuItem(title: "Hotkey: ⌘⇧P", action: nil, keyEquivalent: "")
        shortcutItem.isEnabled = false
        menu.addItem(shortcutItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Quit item
        let quitItem = NSMenuItem(title: "Quit PromptEx", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.keyEquivalentModifierMask = [.command]
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusBarItem?.menu = menu
    }
    
    private func setupGlobalHotkey() {
        // Force-set the shortcut each launch so it's always registered
        let shortcut = KeyboardShortcuts.Shortcut(.p, modifiers: [.command, .shift])
        KeyboardShortcuts.setShortcut(shortcut, for: .togglePromptEx)

        KeyboardShortcuts.onKeyUp(for: .togglePromptEx) { [weak self] in
            self?.toggleFloatingWindow()
        }
    }
    
    private func createFloatingWindow() {
        let windowSize = NSSize(width: 800, height: 600)
        
        floatingWindow = NSWindow(
            contentRect: NSRect(origin: .zero, size: windowSize),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        
        floatingWindow?.title = "PromptEx"
        floatingWindow?.level = .normal
        floatingWindow?.isReleasedWhenClosed = false
        floatingWindow?.hidesOnDeactivate = false
        
        // Set minimum window size
        floatingWindow?.minSize = NSSize(width: 600, height: 400)
        
        // Center the window
        floatingWindow?.center()
        
        // Set content view
        let contentView = PromptExView(promptManager: promptManager)
        floatingWindow?.contentView = NSHostingView(rootView: contentView)
        
        // Initially hidden
        floatingWindow?.orderOut(nil)
        
        // Update menu item title when window visibility changes
        floatingWindow?.delegate = self
    }
    
    @objc private func toggleFloatingWindow() {
        guard let window = floatingWindow else { return }
        
        if window.isVisible {
            window.orderOut(nil)
        } else {
            // Bring to front and focus
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            window.orderFrontRegardless()
        }
        
        updateMenuItemTitle()
    }
    
    @objc private func showQuickAdd() {
        // Show window if hidden, then trigger quick add mode
        guard let window = floatingWindow else { return }
        
        if !window.isVisible {
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            window.orderFrontRegardless()
        }
        
        // Post notification to trigger quick add mode in the UI
        NotificationCenter.default.post(name: .triggerQuickAdd, object: nil)
        
        updateMenuItemTitle()
    }
    
    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "PromptEx"
        alert.informativeText = """
        AI Prompt Manager for macOS
        
        Features:
        • Quick prompt capture and organization
        • Global hotkey access (⌘⇧P)
        • Category-based organization
        • Search and favorites
        • Menu bar access
        
        Version 1.0
        """
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
    
    private func updateMenuItemTitle() {
        guard let menu = statusBarItem?.menu,
              let toggleItem = menu.item(at: 0) else { return }
        
        let isVisible = floatingWindow?.isVisible ?? false
        toggleItem.title = isVisible ? "Hide PromptEx" : "Show PromptEx"
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Don't quit when window is closed, keep running in menu bar
        return false
    }
}

// Window delegate to update menu items
extension AppDelegate: NSWindowDelegate {
    func windowDidBecomeKey(_ notification: Notification) {
        updateMenuItemTitle()
    }
    
    func windowDidResignKey(_ notification: Notification) {
        updateMenuItemTitle()
    }
    
    func windowWillClose(_ notification: Notification) {
        updateMenuItemTitle()
    }
}

// Global hotkey extension
extension KeyboardShortcuts.Name {
    static let togglePromptEx = Self("togglePromptEx", default: .init(.p, modifiers: [.command, .shift]))
}

// Notification extension for quick add trigger
extension Notification.Name {
    static let triggerQuickAdd = Notification.Name("triggerQuickAdd")
} 