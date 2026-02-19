import Foundation

/// Appends formatted entries to the Obsidian inbox file.
struct InboxWriter {
    let path: String

    /// Expands tilde in path to full home directory path.
    static func expandPath(_ path: String) -> String {
        (path as NSString).expandingTildeInPath
    }

    /// Appends entry to inbox file, creating it if needed.
    func append(_ entry: String) throws {
        let expandedPath = Self.expandPath(path)
        let url = URL(fileURLWithPath: expandedPath)
        let directory = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        if FileManager.default.fileExists(atPath: expandedPath) {
            let handle = try FileHandle(forWritingTo: url)
            handle.seekToEndOfFile()
            handle.write("\n".data(using: .utf8)!)
            handle.write(entry.data(using: .utf8)!)
            handle.closeFile()
        } else {
            try entry.write(toFile: expandedPath, atomically: true, encoding: .utf8)
        }
    }
}
