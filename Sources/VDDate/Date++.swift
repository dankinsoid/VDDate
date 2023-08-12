import Foundation

public extension Date {

	static var today: Date { Date().start(of: .day) }
	static var yesterday: Date { today - .day }
	static var tomorrow: Date { today + .day }
}

public extension Date {

	init(
		era: Int = 1,
		year: Int,
		month: Int = 1,
		day: Int = 1,
		hour: Int = 0,
		minute: Int = 0,
		second: Int = 0,
		nanosecond: Int = 0,
		calendar: Calendar = .default,
		timeZone: TimeZone = .default
	) {
		self = DateComponents(
			calendar: calendar,
			timeZone: timeZone,
			era: era,
			year: year,
			month: month,
			day: day,
			hour: hour,
			minute: minute,
			second: second,
			nanosecond: nanosecond
		).date ?? Date()
	}

	init?(
		components: DateComponents,
		calendar: Calendar = .default,
		timeZone: TimeZone = .default
	) {
		var components = components
		components.calendar = calendar
		components.timeZone = timeZone
		guard let date = components.date else { return nil }
		self = date
	}

	init?(
		from string: String,
		format: String,
		locale: Locale = .default,
		timezone: TimeZone = .default
	) {
		let formatter = DateFormatter()
		formatter.dateFormat = format
		formatter.locale = locale
		formatter.timeZone = timezone
		guard let date = formatter.date(from: string) else { return nil }
		self = date
	}
}

public extension Date {

	/// true if the given date is within today, as defined by default calendar and calendar’s locale; otherwise, false.
	var isToday: Bool { Calendar.default.isDateInToday(self) }

	/// Returns a Boolean value indicating whether the given date is within today.
	/// - Parameter calendar: The calendar to use
	/// - Returns: true if the given date is within today, as defined by the calendar and calendar’s locale; otherwise, false.
	func isToday(calendar: Calendar) -> Bool { calendar.isDateInToday(self) }

	/// true if the given date is within yesterday, as defined by default calendar and calendar’s locale; otherwise, false.
	var isYesterday: Bool { start(of: .day) == .yesterday }

	/// Returns a Boolean value indicating whether the given date is within today.
	/// - Parameter calendar: The calendar to use
	/// - Returns: true if the given date is within yesterday, as defined by the calendar and calendar’s locale; otherwise, false.
	func isYesterday(calendar: Calendar) -> Bool { start(of: .day, calendar: calendar) == .yesterday }

	/// true if the given date is within tomorrow, as defined by default calendar and calendar’s locale; otherwise, false.
	var isTomorrow: Bool { Calendar.default.isDateInTomorrow(self) }

	/// Returns a Boolean value indicating whether the given date is within today.
	/// - Parameter calendar: The calendar to use
	/// - Returns: true if the given date is within tomorrow, as defined by the calendar and calendar’s locale; otherwise, false.
	func isTomorrow(calendar: Calendar) -> Bool {
		calendar.isDateInTomorrow(self)
	}

	/// A string representing the date and time in ISO 8601 format.
	var iso860: String {
		string(
			"yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX",
			locale: Locale(identifier: "en_US_POSIX"),
			timeZone: TimeZone(secondsFromGMT: 0) ?? .default
		)
	}
}

public extension Date {

	/// Returns the components of the date, using the specified calendar.
	///
	/// - Parameters:
	///   - calendar: The calendar to use for extracting the components.
	/// - Returns: The components of the date.
	func components(calendar: Calendar = .default) -> DateComponents {
		calendar.dateComponents(Calendar.Component.allCases, from: self)
	}

	/// Returns the value for one component of a date.
	/// - Parameters:
	///   - component: The component to calculate
	///   - calendar: The calendar to use
	/// - Returns: The value for the component.
	subscript(_ component: Calendar.Component, calendar calendar: Calendar = .default) -> Int {
		get { calendar.component(component, from: self) }
		set { self = setting(newValue, component, calendar: calendar) ?? self }
	}

	/// Returns the first moment of a given Date, as a Date.
	///
	/// For example, pass in `.day`, if you want the start of today.
	/// - Parameters:
	///   - component: The component to compute for
	///   - calendar: The calendar to use
	/// - Returns: The first moment of the given date.
	func start(of component: Calendar.Component, calendar: Calendar = .default) -> Date {
		if component == .day {
			return calendar.startOfDay(for: self)
		}
		var set = component.allLarger
		set.insert(component)
		return calendar.date(from: calendar.dateComponents(set, from: self)) ?? self
	}

	/// Returns the last moment of a given Date, as a Date, with given accuracy.
	///
	/// For example, pass in `.day`, if you want the start of today.
	/// - Parameters:
	///   - component: The component to compute for
	///   - accuracy: The component to compute for
	///   - calendar: The calendar to use
	/// - Returns: The last moment of the given date.
	func end(of component: Calendar.Component, accuracy: Calendar.Component? = nil, calendar: Calendar = .default) -> Date {
		var smaller: Calendar.Component?
		if let smallest = accuracy, calendar.range(of: smallest, in: component, for: self) != nil {
			if smallest == .nanosecond {
				smaller = .second
			} else {
				smaller = smallest
			}
		} else {
			smaller = component.smaller
		}
		guard let next = smaller else { return self }
		var components = DateComponents()
		components.setValue(1, for: component)
		components.setValue(-1, for: next)
		return calendar.date(byAdding: components, to: start(of: component, calendar: calendar)) ?? self
	}

	func matches(_ components: DateComponents, calendar: Calendar = .default) -> Bool {
		for component in Calendar.Component.allCases {
			guard let value = components.value(for: component) else { continue }
			if calendar.component(component, from: self) != value {
				return false
			}
		}
		return true
	}

	func isInSame(_ component: Calendar.Component, as date: Date, calendar: Calendar = .default) -> Bool {
		if component == .day {
			return calendar.isDate(self, inSameDayAs: date)
		}
		return start(of: component, calendar: calendar) == date.start(of: component, calendar: calendar)
	}

	/// Returns a Boolean value indicating whether the given date is within today.
	/// - Parameter calendar: The calendar to use
	/// - Returns: true if the given date is within current week, as defined by the calendar and calendar’s locale; otherwise, false.
	func isCurrent(_ component: Calendar.Component, calendar: Calendar = .default) -> Bool {
		isInSame(component, as: Date(), calendar: calendar)
	}

	func isEqual(to date: Date, toGranularity: Calendar.Component, calendar: Calendar = .default) -> Bool {
		calendar.isDate(self, equalTo: date, toGranularity: toGranularity)
	}

	func number(of component: Calendar.Component, from date: Date, calendar: Calendar = .default) -> Int {
		calendar.dateComponents(
			[component],
			from: date.start(of: component, calendar: calendar),
			to: start(of: component, calendar: calendar)
		).value(for: component) ?? 0
	}

	func range(of smaller: Calendar.Component, in larger: Calendar.Component, calendar: Calendar = .default) -> Range<Int>? {
		calendar.range(of: smaller, in: larger, for: self)
	}

	func range(byAdding difference: DateDifference, calendar: Calendar = .default) -> Range<Date> {
		let new = adding(difference)
		if new < self {
			return new ..< self
		} else if self == new {
			return self ..< (self + .second)
		}
		return self ..< new
	}

	func dates(of smaller: Calendar.Component, in larger: Calendar.Component, calendar: Calendar = .default) -> Range<Date>? {
		let lower = start(of: larger, calendar: calendar)
		let upper = end(of: larger, accuracy: smaller, calendar: calendar)
		guard upper > lower else { return nil }
		return lower ..< upper
	}

	func number(of smaller: Calendar.Component, calendar: Calendar = .default) -> Int {
		smaller.larger.map { number(of: smaller, in: $0, calendar: calendar) } ?? 1
	}

	func number(of smaller: Calendar.Component, in larger: Calendar.Component, calendar: Calendar = .default) -> Int {
		if smaller.larger == larger || larger.smaller == smaller {
			return range(of: smaller, in: larger, calendar: calendar)?.count ?? 0
		} else {
			let from = start(of: larger, calendar: calendar)
			return from.adding(larger, value: 1, calendar: calendar).number(of: smaller, from: from, calendar: calendar)
		}
	}

	func string(_ format: String, locale: Locale = .default, timeZone: TimeZone = .default) -> String {
		let formatter = DateFormatter()
		formatter.locale = locale
		formatter.dateFormat = format
		formatter.timeZone = timeZone
		return formatter.string(from: self)
	}

	func string(
		date: DateFormatter.Style = .short,
		time: DateFormatter.Style = .none,
		locale: Locale = .default,
		timeZone: TimeZone = .default
	) -> String {
		let formatter = DateFormatter()
		formatter.locale = locale
		formatter.timeZone = timeZone
		formatter.dateStyle = date
		formatter.timeStyle = time
		return formatter.string(from: self)
	}

	func string(
		_ format: String,
		relative: [DateComponents: String],
		to date: Date = Date(),
		locale: Locale = .default,
		timeZone: TimeZone = .default,
		calendar: Calendar = .default
	) -> String {
		guard !relative.isEmpty else { return string(format, locale: locale, timeZone: timeZone) }
		let difference = from(date).dateComponents(calendar: calendar)
		for (comp, format) in relative.sorted(by: { $0.key.minComponent() < $1.key.minComponent() }) {
			if difference.contains(comp) {
				return string(format, locale: locale, timeZone: timeZone)
			}
		}
		return string(format, locale: locale, timeZone: timeZone)
	}

	func name(
		of component: Calendar.Component,
		locale: Locale = .default,
		timeZone: TimeZone = .default
	) -> String {
		switch component {
		case .era: return string("GGGG", locale: locale, timeZone: timeZone)
		case .year: return string("yyyy", locale: locale, timeZone: timeZone)
		case .month: return string("MMMM", locale: locale, timeZone: timeZone)
		case .day: return string("dd", locale: locale, timeZone: timeZone)
		case .hour: return string("HH", locale: locale, timeZone: timeZone)
		case .minute: return string("mm", locale: locale, timeZone: timeZone)
		case .second: return string("ss", locale: locale, timeZone: timeZone)
		case .weekday: return string("EEEE", locale: locale, timeZone: timeZone)
		case .weekdayOrdinal: return string("EEEE", locale: locale, timeZone: timeZone)
		case .quarter: return string("QQQQ", locale: locale, timeZone: timeZone)
		case .weekOfMonth: return string("W", locale: locale, timeZone: timeZone)
		case .weekOfYear: return string("w", locale: locale, timeZone: timeZone)
		case .yearForWeekOfYear: return string("Y", locale: locale, timeZone: timeZone)
		case .nanosecond: return "\(nanosecond)"
		case .calendar: return ""
		case .timeZone: return string("ZZZZ", locale: locale, timeZone: timeZone)
		@unknown default: return ""
		}
	}

	/// Returns, for a given absolute time, the ordinal number of a smaller calendar component (such as a day) within a specified larger calendar component (such as a week).
	/// ```swift
	/// date.ordinality(of: .day, in: .week)
	/// ```
	/// The ordinality is in most cases not the same as the decomposed value of the component.
	/// Typically return values are 1 and greater. For example, the time 00:45 is in the first hour of the day, and for components hour and day respectively, the result would be 1.
	/// An exception is the week-in-month calculation, which returns 0 for days before the first week in the month containing the date.
	/// - Note:
	///        Some computations can take a relatively long time.
	/// - Parameters:
	///   - smaller: The smaller calendar component.
	///   - larger: The larger calendar component.
	///   - calendar: The calendar to use
	/// - Returns: The ordinal number of smaller within larger at the time specified by date.
	/// Returns nil if larger is not logically bigger than smaller in the calendar, or the given combination of components does not make sense (or is a computation which is undefined).
	func ordinality(of smaller: Calendar.Component, in larger: Calendar.Component, calendar: Calendar = .default) -> Int? {
		calendar.ordinality(of: smaller, in: larger, for: self)
	}

	func from(_ other: Date) -> DateDifference {
		.dates(from: other, to: self)
	}

	func to(_ other: Date) -> DateDifference {
		other.from(self)
	}

	static func - (_ lhs: Date, _ rhs: Date) -> DateDifference {
		lhs.from(rhs)
	}

	func adding(_ difference: DateDifference, wrapping: Bool = false, calendar: Calendar = .default) -> Date {
		switch difference {
		case let .interval(interval):
			return addingTimeInterval(interval)
		case let .dates(from, to):
			return addingTimeInterval(to.timeIntervalSince(from))
		case let .components(components):
			return calendar.date(
				byAdding: DateComponents(rawValue: components),
				to: self, wrappingComponents: wrapping
			) ?? addingTimeInterval(TimeInterval(difference.seconds))
		}
	}

	func adding(components: DateComponents, wrapping: Bool = false, calendar: Calendar = .default) -> Date? {
		calendar.date(byAdding: components, to: self, wrappingComponents: wrapping)
	}

	func adding(_ component: Calendar.Component, value: Int, wrapping: Bool = false, calendar: Calendar = .default) -> Date {
		calendar.date(
			byAdding: component,
			value: value,
			to: self,
			wrappingComponents: wrapping
		) ?? addingTimeInterval(TimeInterval(value * number(of: .second, in: component)))
	}

	func setting(_ components: DateComponents, calendar: Calendar = .default) -> Date {
		components.rawValue.sorted(by: { $0.key > $1.key }).reduce(self) {
			$0.setting($1.value, $1.key) ?? $0
		}
	}

	func setting(_ value: Int, _ component: Calendar.Component, calendar: Calendar = .default) -> Date? {
		switch component {
		case .nanosecond, .second, .minute, .hour:
			var comps = components(calendar: calendar)
			comps.setValue(value, for: component)
			return calendar.date(from: comps)
		case .day, .weekday, .weekdayOrdinal, .weekOfYear, .weekOfMonth, .era, .month, .quarter, .year, .yearForWeekOfYear:
			let diff = value - self[component, calendar: calendar]
			return adding(component, value: diff, calendar: calendar)
		case .calendar, .timeZone:
			return nil
		@unknown default:
			return nil
		}
	}

	func compare(with date: Date, accuracy component: Calendar.Component, calendar: Calendar = .default) -> ComparisonResult {
		calendar.compare(self, to: date, toGranularity: component)
	}

	@available(iOS 10.0, macOS 10.12, *)
	func nextWeekend(direction: Calendar.SearchDirection = .forward, calendar: Calendar = .default) -> DateInterval? {
		calendar.nextWeekend(startingAfter: self, direction: direction)
	}

	func next(
		_ component: Calendar.Component,
		direction: Calendar.SearchDirection = .forward,
		count: Int = 1,
		calendar: Calendar = .default
	) -> Date {
		switch direction {
		case .forward:
			return calendar.date(byAdding: component, value: count, to: self)?.start(of: component, calendar: calendar) ?? self
		case .backward:
			return adding([component: -count], calendar: calendar).start(of: component, calendar: calendar)
		@unknown default: return self
		}
	}

	func nearest(
		_ components: DateComponents,
		in time: Calendar.SearchDirection.Set = .both,
		matchingPolicy: Calendar.MatchingPolicy = .strict,
		calendar: Calendar = .default
	) -> Date? {
		guard !time.isEmpty else { return nil }
		var next: Date?
		var prev: Date?
		if time.contains(.future) {
			next = calendar.nextDate(after: self, matching: components, matchingPolicy: matchingPolicy, direction: .forward)
		}
		if time.contains(.past) {
			prev = calendar.nextDate(after: self, matching: components, matchingPolicy: matchingPolicy, direction: .backward)
		}
		if let nxt = next, let prv = prev {
			return abs(nxt.timeIntervalSince(self)) < abs(prv.timeIntervalSince(self)) ? nxt : prv
		}
		return next ?? prev
	}

	func rounded(_ component: Calendar.Component, by value: Int, calendar: Calendar = .default) -> Date {
		guard value > 0 else { return setting(value, component, calendar: calendar) ?? self }
		var count = self[component, calendar: calendar]
		count = Int(Foundation.round(Double(count) / Double(value))) * value
		return setting(count, component, calendar: calendar) ?? self
	}

	func rounded(_ component: Calendar.Component, from date: Date, by value: Int, calendar: Calendar = .default) -> Date {
		guard value > 0 else { return setting(value, component, calendar: calendar) ?? self }
		var count = number(of: component, from: date, calendar: calendar)
		count = Int(Foundation.round(Double(count) / Double(value))) * value
		return date + .components([component: count])
	}
}

public extension Date {

	func month(in larger: Calendar.Component, calendar: Calendar = .default) -> Int? { ordinality(of: .month, in: larger, calendar: calendar) }
	func day(in larger: Calendar.Component, calendar: Calendar = .default) -> Int? { ordinality(of: .day, in: larger, calendar: calendar) }
	func hour(in larger: Calendar.Component, calendar: Calendar = .default) -> Int? { ordinality(of: .hour, in: larger, calendar: calendar) }
	func minute(in larger: Calendar.Component, calendar: Calendar = .default) -> Int? { ordinality(of: .minute, in: larger, calendar: calendar) }
	func second(in larger: Calendar.Component, calendar: Calendar = .default) -> Int? { ordinality(of: .second, in: larger, calendar: calendar) }
	func nanosecond(in larger: Calendar.Component, calendar: Calendar = .default) -> Int? { ordinality(of: .nanosecond, in: larger, calendar: calendar) }
	func weekday(in larger: Calendar.Component, calendar: Calendar = .default) -> Int? { ordinality(of: .weekday, in: larger, calendar: calendar) }
	func quarter(in larger: Calendar.Component, calendar: Calendar = .default) -> Int? { ordinality(of: .quarter, in: larger, calendar: calendar) }
	func week(in larger: Calendar.Component, calendar: Calendar = .default) -> Int? { ordinality(of: .weekOfYear, in: larger, calendar: calendar) }

	func era(calendar: Calendar) -> Int { calendar.component(.era, from: self) }
	func year(calendar: Calendar) -> Int { calendar.component(.year, from: self) }
	func month(calendar: Calendar) -> Int { calendar.component(.month, from: self) }
	func day(calendar: Calendar) -> Int { calendar.component(.day, from: self) }
	func hour(calendar: Calendar) -> Int { calendar.component(.hour, from: self) }
	func minute(calendar: Calendar) -> Int { calendar.component(.minute, from: self) }
	func second(calendar: Calendar) -> Int { calendar.component(.second, from: self) }
	func nanosecond(calendar: Calendar) -> Int { calendar.component(.nanosecond, from: self) }
	func weekday(calendar: Calendar) -> Weekdays { Weekdays(rawValue: calendar.component(.weekday, from: self)) ?? .sunday }
	func weekdayOrdinal(calendar: Calendar) -> Int { calendar.component(.weekdayOrdinal, from: self) }
	func quarter(calendar: Calendar) -> Int { calendar.component(.quarter, from: self) }
	func weekOfMonth(calendar: Calendar) -> Int { calendar.component(.weekOfMonth, from: self) }
	func weekOfYear(calendar: Calendar) -> Int { calendar.component(.weekOfYear, from: self) }
	func yearForWeekOfYear(calendar: Calendar) -> Int { calendar.component(.yearForWeekOfYear, from: self) }

	var era: Int { get { self[.era] } set { self[.era] = newValue } }
	var year: Int { get { self[.year] } set { self[.year] = newValue } }
	var month: Int { get { self[.month] } set { self[.month] = newValue } }
	var day: Int { get { self[.day] } set { self[.day] = newValue } }
	var hour: Int { get { self[.hour] } set { self[.hour] = newValue } }
	var minute: Int { get { self[.minute] } set { self[.minute] = newValue } }
	var second: Int { get { self[.second] } set { self[.second] = newValue } }
	var nanosecond: Int { get { self[.nanosecond] } set { self[.nanosecond] = newValue } }
	var weekday: Int { get { self[.weekday] } set { self[.weekday] = newValue } }
	var weekdayOrdinal: Int { get { self[.weekdayOrdinal] } set { self[.weekdayOrdinal] = newValue } }
	var quarter: Int { get { self[.quarter] } set { self[.quarter] = newValue } }
	var weekOfMonth: Int { get { self[.weekOfMonth] } set { self[.weekOfMonth] = newValue } }
	var weekOfYear: Int { get { self[.weekOfYear] } set { self[.weekOfYear] = newValue } }
	var yearForWeekOfYear: Int { get { self[.yearForWeekOfYear] } set { self[.yearForWeekOfYear] = newValue } }
}
