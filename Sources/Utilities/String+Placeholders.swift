import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

extension String {
    /// Extracts unique placeholder names in the form `{{placeholder}}` from the string.
    /// - Returns: An array of placeholder identifiers without the surrounding braces.
    func extractPlaceholders() -> [String] {
        let pattern = "\\{\\{\\s*([a-zA-Z0-9_]+)\\s*\\}\\}"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let range = NSRange(startIndex..<endIndex, in: self)
        let matches = regex.matches(in: self, options: [], range: range)
        var ordered: [String] = []
        var seen = Set<String>()
        for match in matches {
            guard match.numberOfRanges > 1,
                  let range = Range(match.range(at: 1), in: self) else { continue }
            let name = String(self[range])
            if !seen.contains(name) {
                ordered.append(name)
                seen.insert(name)
            }
        }
        return ordered
    }

    /// Replaces placeholders of the form `{{placeholder}}` with provided values.
    /// Any placeholder without a corresponding value will be replaced with an empty string.
    /// - Parameter values: Mapping from placeholder name to substitution value.
    /// - Returns: A new string with placeholders substituted.
    func replacingPlaceholders(with values: [String: String]) -> String {
        var result = self
        let pattern = "\\{\\{\\s*([a-zA-Z0-9_]+)\\s*\\}\\}"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return self }
        // Iterate matches in reverse order to avoid messing up indices while replacing
        let matches = regex.matches(in: result, options: [], range: NSRange(result.startIndex..<result.endIndex, in: result))
        for match in matches.reversed() {
            guard match.numberOfRanges > 1,
                  let nameRange = Range(match.range(at: 1), in: result) else { continue }
            let name = String(result[nameRange])
            let replacement = values[name] ?? ""
            if let fullRange = Range(match.range(at: 0), in: result) {
                result.replaceSubrange(fullRange, with: replacement)
            }
        }
        return result
    }
    
    #if canImport(SwiftUI)
    /// Returns an AttributedString with placeholders highlighted in distinct colors.
    func attributedHighlightPlaceholders() -> AttributedString {
        var result = AttributedString()
        let pattern = "\\{\\{\\s*([a-zA-Z0-9_]+)\\s*\\}\\}"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return AttributedString(self)
        }
        let nsRange = NSRange(startIndex..<endIndex, in: self)
        let matches = regex.matches(in: self, options: [], range: nsRange)
        var currentIndex = startIndex
        for match in matches {
            guard match.numberOfRanges > 1,
                  let fullRange = Range(match.range(at: 0), in: self),
                  let nameRange = Range(match.range(at: 1), in: self) else { continue }
            // Append text before placeholder
            if currentIndex < fullRange.lowerBound {
                let segment = String(self[currentIndex..<fullRange.lowerBound])
                result.append(AttributedString(segment))
            }
            // Placeholder segment
            let placeholderText = String(self[fullRange])
            var placeholderAttr = AttributedString(placeholderText)
            let variableName = String(self[nameRange])
            placeholderAttr.foregroundColor = colorForPlaceholder(variableName)
            placeholderAttr.font = .body.bold()
            result.append(placeholderAttr)
            currentIndex = fullRange.upperBound
        }
        // Append remaining text
        if currentIndex < endIndex {
            let tail = String(self[currentIndex..<endIndex])
            result.append(AttributedString(tail))
        }
        return result
    }
    
    private func colorForPlaceholder(_ name: String) -> Color {
        let palette: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink, .teal]
        let index = abs(name.hashValue) % palette.count
        return palette[index]
    }
    #endif
}

