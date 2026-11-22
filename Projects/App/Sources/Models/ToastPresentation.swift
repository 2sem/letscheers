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

    /// Call-and-response lines parsed from `contents`.
    let lines: [Line]
    /// Lead/response pair parsed from a title like "(선)A (후)B". Empty when the title has no markers.
    let titleLines: [Line]
    let meaning: String

    var hasCallAndResponse: Bool { !lines.isEmpty }
    var hasTitleCallAndResponse: Bool { !titleLines.isEmpty }

    /// Spoken-order description of the title pair, e.g. "선창, A. 후창, B".
    var titleAccessibilityLabel: String {
        titleLines.map { "\($0.role.rawValue), \($0.text)" }.joined(separator: ". ")
    }

    init(contents: String) {
        self.init(title: "", contents: contents)
    }

    init(title: String, contents: String) {
        self.titleLines = Self.parseTitle(title)
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

    private static let titlePattern = try? NSRegularExpression(
        pattern: "^\\s*[(（]?\\s*선\\s*[)）:：]\\s*(.+?)\\s+[(（]?\\s*후\\s*[)）:：]\\s*(.+?)\\s*$"
    )

    private static func parseTitle(_ title: String) -> [Line] {
        let range = NSRange(title.startIndex..., in: title)
        guard let match = titlePattern?.firstMatch(in: title, range: range),
              let leadRange = Range(match.range(at: 1), in: title),
              let responseRange = Range(match.range(at: 2), in: title) else {
            return []
        }
        let lead = String(title[leadRange]).trimmingCharacters(in: .whitespaces)
        let response = String(title[responseRange]).trimmingCharacters(in: .whitespaces)
        guard !lead.isEmpty, !response.isEmpty else { return [] }
        return [Line(id: 0, role: .lead, text: lead), Line(id: 1, role: .response, text: response)]
    }

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
