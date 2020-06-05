import XCTest
@testable import TracingActivity

final class TracingActivityTests: XCTestCase {
	func testInitiate() throws {
		let blockExecutedInActivity = expectation(description: "testInitiate.blockExecutedInActivity")
		let blockExecuted = expectation(description: "testInitiateblockExecuted")
		
		_ = TracingActivity.initiate("ActivitySuccess") {
			blockExecutedInActivity.fulfill()
		}
		
		// when dso is nil the activity cannot be created
		_ = TracingActivity.initiate("", dso: nil) {
			blockExecuted.fulfill()
		}
		
		waitForExpectations(timeout: 1)
	}
	
	func testFailableInit() throws {
		XCTAssertNotNil(TracingActivity("ActivitySuccess"))
		
		XCTAssertNil(TracingActivity("", dso: nil))
	}
	
	func testStaticApplyPositive() throws {
		let blockExecutedInActivity = expectation(description: "testApply.blockExecutedInActivity")
		
		let activitySuccess = TracingActivity("ActivitySuccess")
		let result = TracingActivity.apply(activitySuccess) {
			blockExecutedInActivity.fulfill()
		}
		XCTAssertTrue(result)
		
		waitForExpectations(timeout: 1)
	}
	
	func testStaticApplyNegative() throws {
		let blockExecuted = expectation(description: "testStaticApply.blockExecuted")
		
		// when dso is nil the activity cannot be created
		let activityFailure = TracingActivity("", dso: nil)
		let result = TracingActivity.apply(activityFailure) {
			blockExecuted.fulfill()
		}
		XCTAssertFalse(result)
		
		waitForExpectations(timeout: 1)
	}
	
	func testEnterLeaveScope() throws {
		var scopeChanged = false
		
		let activity = TracingActivity("TestActivity")
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
