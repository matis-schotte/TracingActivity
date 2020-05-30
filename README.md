# UNTracingActivity

Apples Activity Tracing as part of Unified Logging made available for pure Swift applications.
Creation of a tracing activity can fail, but all blocks will always be executed.
The return values will inform if the code was executed inside the activity (success = true) or not.
Nesting of activities is encouraged for dependening sub-tasks.

Block-based activity tracing once:
```
_ = UNTracingActivity.initiate("Activity") {
	// ... os_log stuff
}
```
Activity tracing for multiple blocks:
```
let activity: UNTracingActivity? = UNTracingActivity("Activity")
_ = UNTracingActivity.apply(activity) {
	// ... os_log stuff
}
```
Scope-based activity tracing:
```
let activity: UNTracingActivity? = UNTracingActivity("Activity2")
var scope = activity?.enter()
// ... os_log stuff
defer {
	scope?.leave()
}
```
