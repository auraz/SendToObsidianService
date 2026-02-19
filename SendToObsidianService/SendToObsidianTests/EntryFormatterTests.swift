import XCTest
@testable import SendToObsidian

/// Tests for EntryFormatter markdown entry generation.
final class EntryFormatterTests: XCTestCase {
    func testFormatEntryWithURL() {
        let formatter = EntryFormatter()
        let result = formatter.format(text: "Hello world", appName: "Safari", url: "https://example.com", date: Date(timeIntervalSince1970: 1771502400))
        XCTAssertTrue(result.contains("| Safari | https://example.com"))
        XCTAssertTrue(result.contains("  Hello world"))
    }

    func testFormatEntryWithoutURL() {
        let formatter = EntryFormatter()
        let result = formatter.format(text: "Some note", appName: "Notes", url: nil, date: Date(timeIntervalSince1970: 1771502400))
        XCTAssertTrue(result.contains("| Notes |"))
        XCTAssertFalse(result.contains("https://"))
        XCTAssertTrue(result.contains("  Some note"))
    }

    func testMultilineTextIndentation() {
        let formatter = EntryFormatter()
        let result = formatter.format(text: "Line 1\nLine 2\nLine 3", appName: "TextEdit", url: nil, date: Date(timeIntervalSince1970: 1771502400))
        XCTAssertTrue(result.contains("  Line 1\n  Line 2\n  Line 3"))
    }
}
