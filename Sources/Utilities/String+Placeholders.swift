import Foundation

extension String {
    /// Extracts unique placeholder names in the form `{{placeholder}}` from the string.
    /// - Returns: An array of placeholder identifiers without the surrounding braces.
    func extractPlaceholders() -> [String] {
        let pattern = "\\{\\{\\s*([a-zA-Z0-9_]+)\\s*\\}\\}"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let range = NSRange(startIndex..<endIndex, in: self)
        let matches = regex.matches(in: self, options: [], range: range)
        let names = matches.compactMap { match -> String? in
            guard match.numberOfRanges > 1,
                  let range = Range(match.range(at: 1), in: self) else { return nil }
            return String(self[range])
        }
        return Array(Set(names)) // Unique names
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
}
