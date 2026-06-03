import Foundation

enum NovelParser {
    static func buildContinuousNovel(from raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }

        var pieces: [String] = []

        if let data = trimmed.data(using: .utf8) {
            if let json = try? JSONSerialization.jsonObject(with: data) {
                walk(json, into: &pieces)
            }
        }

        if pieces.isEmpty {
            for line in trimmed.components(separatedBy: .newlines) {
                let cleanLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !cleanLine.isEmpty else { continue }
                if let data = cleanLine.data(using: .utf8), let json = try? JSONSerialization.jsonObject(with: data) {
                    walk(json, into: &pieces)
                } else {
                    pieces.append(clean(cleanLine))
                }
            }
        }

        var output: [String] = []
        var last = ""
        for piece in pieces.map(clean).filter({ !$0.isEmpty }) {
            if piece != last {
                output.append(piece)
                last = piece
            }
        }
        return output.joined(separator: "\n\n")
    }

    private static func walk(_ value: Any, into pieces: inout [String]) {
        let contentKeys = ["mes", "message", "text", "content", "value", "reply", "response", "prompt", "description", "scenario", "first_mes", "alternate_greeting"]
        let arrayKeys = ["chat", "messages", "data", "history", "items", "entries", "log", "swipes", "alternate_greetings", "greetings"]

        if let array = value as? [Any] {
            array.forEach { walk($0, into: &pieces) }
            return
        }

        guard let dict = value as? [String: Any] else {
            if let text = value as? String { pieces.append(text) }
            return
        }

        var added = false
        for key in contentKeys {
            if let found = dict[key] {
                let text = textValue(found)
                if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    pieces.append(text)
                    added = true
                    break
                }
            }
        }

        for key in arrayKeys {
            if let nested = dict[key] { walk(nested, into: &pieces) }
        }

        if !added {
            for (key, nested) in dict where !arrayKeys.contains(key) && !contentKeys.contains(key) {
                walk(nested, into: &pieces)
            }
        }
    }

    private static func textValue(_ value: Any) -> String {
        if let text = value as? String { return text }
        if let array = value as? [Any] { return array.map(textValue).filter { !$0.isEmpty }.joined(separator: "\n") }
        if let dict = value as? [String: Any] {
            for key in ["mes", "message", "text", "content", "value", "reply", "response", "prompt"] {
                if let nested = dict[key] { return textValue(nested) }
            }
        }
        return ""
    }

    private static func clean(_ input: String) -> String {
        var s = input
            .replacingOccurrences(of: "\\r\\n", with: "\n")
            .replacingOccurrences(of: "\\n", with: "\n")
            .replacingOccurrences(of: "\\t", with: " ")

        s = s.replacingOccurrences(of: #"(?is)<script.*?</script>"#, with: "", options: .regularExpression)
        s = s.replacingOccurrences(of: #"(?is)<style.*?</style>"#, with: "", options: .regularExpression)
        s = s.replacingOccurrences(of: #"(?is)```.*?```"#, with: "", options: .regularExpression)
        s = s.replacingOccurrences(of: #"(?is)<!--.*?-->"#, with: "", options: .regularExpression)
        s = s.replacingOccurrences(of: #"<[^>]+>"#, with: "", options: .regularExpression)
        s = s.replacingOccurrences(of: #"[ \t]+"#, with: " ", options: .regularExpression)
        s = s.replacingOccurrences(of: #"\n{3,}"#, with: "\n\n", options: .regularExpression)

        return s
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && !$0.contains("clipboard") && !$0.contains("createElement") }
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
