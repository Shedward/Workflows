import Foundation

struct TestError: LocalizedError {
    static let message = "test error"

    var errorDescription: String? {
        Self.message
    }
}
