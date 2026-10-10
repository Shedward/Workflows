@testable import Core
import Foundation
import Testing

@Suite("Descriptive errors")
struct DescriptiveErrorTests {
    @Test func localizedDescriptionIsTheUserDescription() {
        let error: any Error = Failure("Disk is full", underlyingError: Failure("No space left"))

        #expect(error.localizedDescription == "Disk is full\n ↪ No space left")
    }
}
