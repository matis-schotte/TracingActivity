import XCTest
@testable import UNTracingActivity

final class UNTracingActivityTests: XCTestCase {
	func testInitiate() throws {
		let blockExecutedInActivity = expectation(description: "testInitiate.blockExecutedInActivity")
		let blockExecuted = expectation(description: "testInitiateblockExecuted")
		
		_ = UNTracingActivity.initiate("ActivitySuccess") {
			blockExecutedInActivity.fulfill()
		}
		
		// when dso is nil the activity cannot be created
		_ = UNTracingActivity.initiate("", dso: nil) {
			blockExecuted.fulfill()
		}
		
		waitForExpectations(timeout: 1)
	}
	
	func testFailableInit() throws {
		XCTAssertNotNil(UNTracingActivity("ActivitySuccess"))
		
		XCTAssertNil(UNTracingActivity("", dso: nil))
	}
	
	func testStaticApplyPositive() throws {
		let blockExecutedInActivity = expectation(description: "testApply.blockExecutedInActivity")
		
		let activitySuccess = UNTracingActivity("ActivitySuccess")
		let result = UNTracingActivity.apply(activitySuccess) {
			blockExecutedInActivity.fulfill()
		}
		XCTAssertTrue(result)
		
		waitForExpectations(timeout: 1)
	}
	
	func testStaticApplyNegative() throws {
		let blockExecuted = expectation(description: "testStaticApply.blockExecuted")
		
		// when dso is nil the activity cannot be created
		let activityFailure = UNTracingActivity("", dso: nil)
		let result = UNTracingActivity.apply(activityFailure) {
			blockExecuted.fulfill()
		}
		XCTAssertFalse(result)
		
		waitForExpectations(timeout: 1)
	}
	
	func testEnterLeaveScope() throws {
		var scopeChanged = false
		
		let activity = UNTracingActivity("TestActivity")
		var scope = activity?.enter() {
			didSet { scopeChanged.toggle() }
		}
		scope?.leave()
		
		XCTAssertTrue(scopeChanged)
	}

    static var allTests = [
        ("testInitiate", testInitiate),
		("testFailableInit", testFailableInit),
		("testStaticApplyPositive", testStaticApplyPositive),
		("testStaticApplyNegative", testStaticApplyNegative),
		("testEnterLeaveScope", testEnterLeaveScope),
    ]
}
