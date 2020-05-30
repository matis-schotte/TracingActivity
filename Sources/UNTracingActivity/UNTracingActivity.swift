//
//  UNTracingActivity
//
//  Created by Matis Schotte for Nera on 2020/05/29.
//  Copyright © 2020 ungeord.net. All rights reserved.
//  Based on @vgorloff https://gist.github.com/zwaldowski/49f61292757f86d7d036a529f2d04f0c#gistcomment-2580480
//
//  Using Swift 5.2
//  Running on macOS 10.15
//

import Foundation
import os.activity

// Bridging Obj-C variabled defined as c-macroses. See `activity.h` header.
fileprivate let OS_ACTIVITY_NONE = unsafeBitCast(dlsym(UnsafeMutableRawPointer(bitPattern: -2), "_os_activity_none"),
												 to: os_activity_t.self)
fileprivate let OS_ACTIVITY_CURRENT = unsafeBitCast(dlsym(UnsafeMutableRawPointer(bitPattern: -2), "_os_activity_current"),
													to: os_activity_t.self)
/**
Activity Tracing

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
*/
public struct UNTracingActivity {
	private let activity: os_activity_t
	
	/// Creates an os_activity_t object which can be passed to os_activity_apply
	/// function.
	///
	/// @param description
	/// Pass a description for the activity.  The description must be a constant
	/// string within the calling executable or library.
	///
	/// @param parent_activity
	/// Depending on flags will link the newly created activity to the value passed
	/// or note where the activity was created.  Possible activities include:
	/// OS_ACTIVITY_NONE, OS_ACTIVITY_CURRENT or any existing os_activity_t object
	/// created using os_activity_create.
	///
	/// @param flags
	/// A valid os_activity_flag_t which will determine behavior of the newly created
	/// activity.
	///
	/// If the OS_ACTIVITY_FLAG_DETACHED flag is passed, the value passed to the
	/// parent_activity argument is ignored, and OS_ACTIVITY_NONE is used instead.
	///
	/// If the OS_ACTIVITY_FLAG_IF_NONE_PRESENT flag is passed, then passing another
	/// value than OS_ACTIVITY_CURRENT to the parent_activity argument is undefined.
	public init?(_ description: StaticString, dso: UnsafeRawPointer? = #dsohandle, parent: UNTracingActivity = .current, options: Options = []) {
		let createdActivity: os_activity_t? = description.withUTF8Buffer {
			guard let dso = UnsafeMutableRawPointer(mutating: dso), let address = $0.baseAddress else {
				return nil
			}
			let str = UnsafeRawPointer(address).assumingMemoryBound(to: Int8.self)
			return _os_activity_create(dso, str, parent.activity, os_activity_flag_t(rawValue: options.rawValue))
		}
		
		guard let unwrappedActivity = createdActivity else { return nil }
		self.activity = unwrappedActivity
	}
	
	/// Will change the current execution context to use the provided activity.
	/// An activity can be created and then applied to the current scope by doing:
	///
	/// <code>
	///     struct os_activity_scope_state_s state;
	///     os_activity_t activity = os_activity_create("my new activity", 0);
	///     os_activity_scope_enter(activity, &state);
	///     ... do some work ...
	///     os_activity_scope_leave(&state);
	/// </code>
	///
	/// To auto-cleanup state call:
	///      os_activity_scope(activity);
	public func enter() -> Scope {
		var scope = Scope()
		os_activity_scope_enter(activity, &scope.state)
		
		return scope
	}
	
	private init(_ activity: os_activity_t) {
		self.activity = activity
	}
	
}

// MARK: - Static members
extension UNTracingActivity {
	/// Create activity with no current traits, this is the equivalent of a
	/// detached activity.
	public static var none: UNTracingActivity {
		return UNTracingActivity(OS_ACTIVITY_NONE)
	}
	
	/// Create activity and links to the current activity if one is present.
	/// If no activity is present it is treated as if it is detached.
	public static var current: UNTracingActivity {
		return UNTracingActivity(OS_ACTIVITY_CURRENT)
	}
	
	/// Synchronously initiates an activity using the provided block and creates
	/// a tracing buffer as appropriate.  All new activities are created as a
	/// subactivity of an existing activity on the current thread.
	///
	/// <code>
	///     os_activity_initiate("indexing database", OS_ACTIVITY_FLAG_DEFAULT, ^(void) {
	///         // either do work directly or issue work asynchronously
	///     });
	/// </code>
	///
	/// Returns if the activity could be created. If not, the block will nevertheless be executed regardless the successful creation
	@discardableResult
	public static func initiate(_ description: StaticString, dso: UnsafeRawPointer? = #dsohandle, options: Options = [], execute body: @convention(block) () -> ()) -> Bool {
		return description.withUTF8Buffer {
			guard let dso = UnsafeMutableRawPointer(mutating: dso), let address = $0.baseAddress else {
				body()
				return false
			}
			let str = UnsafeRawPointer(address).assumingMemoryBound(to: Int8.self)
			_os_activity_initiate(dso, str, os_activity_flag_t(rawValue: options.rawValue), body)
			return true
		}
	}
	
	/// Label an activity that is auto-generated by AppKit/UIKit with a name that is
	/// useful for debugging macro-level user actions.  The API should be called
	/// early within the scope of the IBAction and before any sub-activities are
	/// created.  The name provided will be shown in tools in additon to the
	/// underlying AppKit/UIKit provided name.  This API can only be called once and
	/// only on the activity created by AppKit/UIKit.  These actions help determine
	/// workflow of the user in order to reproduce problems that occur.  For example,
	/// a control press and/or menu item selection can be labeled:
	///
	/// <code>
	///     os_activity_label_useraction("New mail message");
	///     os_activity_label_useraction("Empty trash");
	/// </code>
	///
	/// Where the underlying AppKit/UIKit name will be "gesture:" or "menuSelect:".
	public static func labelUserAction(_ description: StaticString, dso: UnsafeRawPointer? = #dsohandle) {
		description.withUTF8Buffer {
			if let dso = UnsafeMutableRawPointer(mutating: dso), let address = $0.baseAddress {
				let str = UnsafeRawPointer(address).assumingMemoryBound(to: Int8.self)
				_os_activity_label_useraction(dso, str)
			}
		}
	}
	
	/// Execute a block using a given activity object.
	///
	/// The given activity object created with os_activity_create() or
	/// OS_ACTIVITY_NONE.
	/// Takes care of always executing the body block, regardless of the activity being created successfully
	@discardableResult
	public static func apply(_ activity: UNTracingActivity?, execute body: @convention(block) () -> ()) -> Bool {
		guard let unwrappedActivity = activity else {
			body()
			return false
		}
		
		os_activity_apply(unwrappedActivity.activity, body)
		return true
	}
}

// MARK: - Options and Scope structs
extension UNTracingActivity {
	/// Support flags for os_activity_create or os_activity_start.
	public struct Options: OptionSet {
		public let rawValue: UInt32
		
		public init(rawValue: UInt32) {
			self.rawValue = rawValue
		}
		
		/// Use the default flags.
		public static let `default` = Options(rawValue: OS_ACTIVITY_FLAG_DEFAULT.rawValue)
		/// Detach the newly created activity from the provided activity (if any).  If
		/// passed in conjunction with an exiting activity, the activity will only note
		/// what activity "created" the new one, but will make the new activity a top
		/// level activity.  This allows users to see what activity triggered work
		/// without actually relating the activities.
		public static let detached = Options(rawValue: OS_ACTIVITY_FLAG_DETACHED.rawValue)
		/// Will only create a new activity if none present.  If an activity ID is
		/// already present, a new object will be returned with the same activity ID
		/// underneath.
		public static let ifNonePresent = Options(rawValue: OS_ACTIVITY_FLAG_IF_NONE_PRESENT.rawValue)
	}
	
	public struct Scope {
		fileprivate var state = os_activity_scope_state_s()
		
		/// Will pop state up to the state provided.
		///
		/// Will leave scope using the state provided.  If state is not present an error
		/// will be generated.
		public mutating func leave() {
			os_activity_scope_leave(&state)
		}
	}
}
