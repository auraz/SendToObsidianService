import Foundation

/// Formats captured text entries with timestamp, source app, and optional URL.
struct EntryFormatter {
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm"
        df.timeZone = .current
        return df
    }()

    /// Formats text into a markdown entry with metadata header.
    func format(text: String, appName: String, url: String?, date: Date = Date()) -> String {
        let timestamp = dateFormatter.string(from: date)
        let urlPart = url.map { " \($0)" } ?? ""
        let header = "- \(timestamp) | \(appName) |\(urlPart)"
        let indentedText = text.split(separator: "\n", omittingEmptySubsequences: false).map { "  \($0)" }.joined(separator: "\n")
        return "\(header)\n\(indentedText)\n"
    }
}
