import Foundation

public extension Calendar {

	/// Default Calendar with a specific TimeZone
	static func `default`(timeZone: TimeZone) -> Calendar {
		var calendar = Calendar.default
		calendar.timeZone = timeZone
		return calendar
	}

	/// Default Calendar with for a UTC TimeZone
	static var utc: Calendar {
		var calendar = Calendar.default
		calendar.timeZone = .utc
		return calendar
	}

	/// Calendare component for a now date
	func current(_ component: Component) -> Int {
		self.component(component, from: .now)
	}

	/// Name of a weekday
	func name(forWeekday weekday: Int) -> String {
		standaloneWeekdaySymbols[weekday - firstWeekday]
	}

	/// Default Calendar for all helper methods, can be overridden
	/// - Note: This value is not thread-safe
	static var `default`: Calendar {
		get { _default() }
		@available(*, deprecated, renamed: "Calendar.bootstrap")
		set { Calendar.bootstrap(default: newValue) }
	}

	/// Sets the default Calendar for all helper methods
	/// - Parameter calendar: The default Calendar
	/// - Example:
	/// ```swift
	/// public extension Calendar {
	///   @TaskLocal static var taskLocalDefault: Calendar = .autoupdatingCurrent
	/// }
	///
	/// Calendar.bootstrap {
	///    Calendar.taskLocalDefault
	/// }
	/// ```
	/// - Note: This method is not thread-safe
	static func bootstrap(default calendar: @escaping () -> Calendar) {
		_default = calendar
	}

	/// Sets the default Calendar for all helper methods
	/// - Parameter calendar: The default Calendar
	/// - Example:
	/// ```swift
	/// public extension Calendar {
	///   @TaskLocal static var taskLocalDefault: Calendar = .autoupdatingCurrent
	/// }
	///
	/// Calendar.bootstrap(default: .taskLocalDefault)
	/// ```
	/// - Note: This value is not thread-safe
	static func bootstrap(default calendar: @escaping @autoclosure () -> Calendar) {
		bootstrap(default: calendar)
	}
}

private extension Calendar {

	static var _default: () -> Calendar = { .autoupdatingCurrent }
}
