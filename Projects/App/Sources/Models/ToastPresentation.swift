//
//  ToastPresentation.swift
//  letscheers
//

import Foundation

/// Splits a toast's free-form `contents` into 선창/후창 call-and-response lines
/// plus a plain "meaning" paragraph. Nothing is ever invented: lines that do not
/// start with a known label stay in the meaning text.
struct ToastPresentation: Equatable {
    enum Role: String {
        case lead = "선창"
        case response = "후창"
        case together = "제창"
        case cheers = "건배"
    }

    struct Line: Identifiable, Equatable {
        let id: Int
        let role: Role
        let text: String
    }

    let lines: [Line]
    let meaning: String

    var hasCallAndResponse: Bool { !lines.isEmpty }

    init(contents: String) {
        var lines: [Line] = []
        var meaningLines: [String] = []

        for rawLine in contents.components(separatedBy: .newlines) {
            let line = rawLine.trimmingCharacters(in: .whitespaces)
            guard !line.isEmpty else { continue }

            if let parsed = Self.parse(line: line) {
                lines.append(Line(id: lines.count, role: parsed.role, text: parsed.text))
            } else {
                meaningLines.append(line)
            }
        }

        self.lines = lines
        self.meaning = meaningLines.joined(separator: "\n")
    }

    // MARK: - Parsing

    private static let pattern = try? NSRegularExpression(
        pattern: "^(선창|후창|제창|건배)\\s*[:：\\-]?\\s*(.+)$"
    )

    private static func parse(line: String) -> (role: Role, text: String)? {
        let range = NSRange(line.startIndex..., in: line)
        guard let match = pattern?.firstMatch(in: line, range: range),
              let labelRange = Range(match.range(at: 1), in: line),
              let textRange = Range(match.range(at: 2), in: line),
              let role = Role(rawValue: String(line[labelRange])) else {
            return nil
        }
        let text = String(line[textRange]).trimmingCharacters(in: .whitespaces)
        return text.isEmpty ? nil : (role, text)
    }
}
