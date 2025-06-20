import SwiftUI
import AppKit
import Combine

/// A SwiftUI wrapper around `NSTextView` that shows live placeholder highlighting
/// while remaining fully editable.
struct PlaceholderHighlightTextEditor: NSViewRepresentable {
    @Binding var text: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.borderType = .bezelBorder
        
        let textView = NSTextView(frame: .zero)
        textView.isRichText = true
        textView.backgroundColor = NSColor.textBackgroundColor
        textView.textColor = NSColor.labelColor
        textView.isEditable = true
        textView.isSelectable = true
        textView.allowsUndo = true
        textView.delegate = context.coordinator
        textView.textContainerInset = NSSize(width: 6, height: 6)
        // Make the text view resize properly within the scroll view
        textView.minSize = NSSize(width: 0, height: 0)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        if let container = textView.textContainer {
            container.containerSize = NSSize(width: scrollView.contentSize.width, height: CGFloat.greatestFiniteMagnitude)
            container.widthTracksTextView = true
        }
        scrollView.documentView = textView
        
        // Initial value
        textView.string = text
        textView.textStorage?.setAttributedString(highlightedAttributedString(text))
        
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        // If the user is actively editing (textView is first responder), avoid resetting attributes to keep caret & scroll stable
        if textView.window?.firstResponder == textView {
            return
        }
        if textView.string != text {
            textView.string = text
        }
        textView.textStorage?.setAttributedString(highlightedAttributedString(text))
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, NSTextViewDelegate {
        let parent: PlaceholderHighlightTextEditor
        init(parent: PlaceholderHighlightTextEditor) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView,
                  let textStorage = textView.textStorage else { return }
            // Save current scroll position
            let currentScrollOrigin = textView.enclosingScrollView?.contentView.bounds.origin
            // Update binding
            parent.text = textView.string
            let selectedRanges = textView.selectedRanges
            // Apply highlight in-place
            parent.applyHighlight(to: textStorage)
            // Restore selection
            textView.selectedRanges = selectedRanges
            // Restore scroll to previous origin to avoid jump
            if let origin = currentScrollOrigin,
               let scrollView = textView.enclosingScrollView {
                scrollView.contentView.scroll(to: origin)
                scrollView.reflectScrolledClipView(scrollView.contentView)
            }
        }
    }
    
    // MARK: - Helper
    private func applyHighlight(to textStorage: NSTextStorage) {
        let fullRange = NSRange(location: 0, length: textStorage.length)
        // Base attributes
        let baseFont = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        textStorage.beginEditing()
        textStorage.setAttributes([
            .font: baseFont,
            .foregroundColor: NSColor.labelColor
        ], range: fullRange)
        let pattern = "\\{\\{\\s*([a-zA-Z0-9_]+)\\s*\\}\\}"
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let matches = regex.matches(in: textStorage.string, range: fullRange)
            for match in matches where match.numberOfRanges > 1 {
                let variableNameRange = match.range(at: 1)
                let variableName = (textStorage.string as NSString).substring(with: variableNameRange)
                let color = colorForPlaceholder(variableName)
                textStorage.addAttributes([
                    .foregroundColor: color,
                    .font: NSFont.boldSystemFont(ofSize: NSFont.systemFontSize)
                ], range: match.range)
            }
        }
        textStorage.endEditing()
    }
    private func highlightedAttributedString(_ string: String) -> NSAttributedString {
        let attributed = NSMutableAttributedString(string: string)
        let fullRange = NSRange(location: 0, length: attributed.length)
        // Base attributes
        let baseFont = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        attributed.addAttributes([
            .font: baseFont,
            .foregroundColor: NSColor.labelColor
        ], range: fullRange)
        
        let pattern = "\\{\\{\\s*([a-zA-Z0-9_]+)\\s*\\}\\}"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return attributed }
        let matches = regex.matches(in: string, range: fullRange)
        for match in matches {
            guard match.numberOfRanges > 1 else { continue }
            let variableRange = match.range(at: 1)
            // Color selection
            let variableName = (string as NSString).substring(with: variableRange)
            let color = colorForPlaceholder(variableName)
            attributed.addAttributes([
                .foregroundColor: color,
                .font: NSFont.boldSystemFont(ofSize: NSFont.systemFontSize)
            ], range: match.range)
        }
        return attributed
    }
    
    private func colorForPlaceholder(_ name: String) -> NSColor {
        let palette: [NSColor] = [.systemRed, .systemOrange, .systemYellow, .systemGreen, .systemBlue, .systemPurple, .systemPink, .systemTeal]
        let index = abs(name.hashValue) % palette.count
        return palette[index]
    }
}
