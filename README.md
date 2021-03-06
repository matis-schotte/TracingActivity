# TracingActivity

![build](https://img.shields.io/badge/build-passing-success)
![tests](https://img.shields.io/badge/tests-passing-success)
![language](https://img.shields.io/badge/language-swift-important)
[![license](https://img.shields.io/github/license/matis-schotte/TracingActivity.svg)](./LICENSE)

![platform](https://img.shields.io/badge/platform-iOS%20|%20macOS%20|%20tvOS%20|%20watchOS-lightgrey.svg)
[![Twitter](https://img.shields.io/badge/twitter-@matis_schotte-blue.svg)](http://twitter.com/matis_schotte)

![Ethereum](https://img.shields.io/badge/ethereum-0x25C93954ad65f1Bb5A1fd70Ec33f3b9fe72e5e58-yellowgreen.svg)
![Litecoin](https://img.shields.io/badge/litecoin-MPech47X9GjaatuV4sQsEzoMwGMxKzdXaH-lightgrey.svg)

TracingActivity provides Apples Activity Tracing as part of Unified Logging for pure Swift applications.
Creation of a tracing activity can fail, but all blocks will always be executed.
The return values will inform if the code was executed inside the activity (success = true) or outside (in case the activity could not be created).
Nesting of activities is encouraged for sub-tasks.

## Requirements
- Swift >= 4
- iOS >= 10
- macOS >= 10.12
- tvOS >= 10
- watchOS >= 3.0

## Installation
### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Add the Package URL `https://github.com/matis-schotte/TracingActivity.git` in Xcodes project viewer.
Adding it to another Package as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
	.package(url: "https://github.com/matis-schotte/TracingActivity.git", from: "0.1.0")
]
```

## Usage
Block-based activity tracing once:
```swift
_ = TracingActivity.initiate("Activity") {
	// ... os_log stuff
}
```
Activity tracing for multiple blocks:
```swift
let activity: TracingActivity? = TracingActivity("Activity")
_ = TracingActivity.apply(activity) {
	// ... os_log stuff
}
```
Scope-based activity tracing:
```swift
let activity: TracingActivity? = TracingActivity("Activity2")
var scope = activity?.enter()
// ... os_log stuff
defer {
	scope?.leave()
}
```

[//]: # (Example: See the example project inside the `examples/` folder.)

## ToDo
- Add SwiftLint (by adding xcodeproj: `swift package generate-xcodeproj`, helps support Xcode Server, too)
- Add Travis CI (without xcodeproj see [reddit](https://www.reddit.com/r/iOSProgramming/comments/d7oyvh/configure_travis_ci_on_github_to_build_ios_swift/), [medium](https://medium.com/@aclaytonscott/creating-and-distributing-swift-packages-132444f5dd1))
- Add codecov
- Add codebeat
- Add codeclimate
- Add codetriage
- Add jazzy docs
- Add CHANGELOG.md
- Clean api docs
- Add Carthage support
- Add Cocoapods support

[//]: # (Donations: ETH, LTC welcome.)

## License
TracingActivity is available under the Apache-2.0 license. See the [LICENSE](https://github.com/matis-schotte/TracingActivity/blob/master/LICENSE) file for more info.

## Author
Matis Schotte, [dm26f1cab8aa26@ungeord.net](mailto:dm26f1cab8aa26@ungeord.net)

[https://github.com/matis-schotte/TracingActivity](https://github.com/matis-schotte/TracingActivity)
