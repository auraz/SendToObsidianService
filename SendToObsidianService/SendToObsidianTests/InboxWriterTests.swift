import XCTest
@testable import SendToObsidian

/// Tests for InboxWriter file append operations.
final class InboxWriterTests: XCTestCase {
    var tempFile: URL!

    override func setUp() {
        tempFile = FileManager.default.temporaryDirectory.appendingPathComponent("test-inbox-\(UUID()).md")
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempFile)
    }

    func testAppendToNewFile() throws {
        let writer = InboxWriter(path: tempFile.path)
        try writer.append("First entry\n")
        let content = try String(contentsOf: tempFile, encoding: .utf8)
        XCTAssertEqual(content, "First entry\n")
    }

    func testAppendToExistingFile() throws {
        try "Existing content\n".write(to: tempFile, atomically: true, encoding: .utf8)
        let writer = InboxWriter(path: tempFile.path)
        try writer.append("New entry\n")
        let content = try String(contentsOf: tempFile, encoding: .utf8)
        XCTAssertEqual(content, "Existing content\n\nNew entry\n")
    }

    func testExpandTildePath() {
        let expanded = InboxWriter.expandPath("~/Documents/test.md")
        XCTAssertFalse(expanded.contains("~"))
        XCTAssertTrue(expanded.hasPrefix("/Users/"))
    }
}
