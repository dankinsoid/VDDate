import Foundation

public extension Date {

	/// The current date and time.
	/// It's possible to mock the current date and time by calling `Date.bootstrap(now:)`.
	/// So it's recommended to use `Date.now` everywhere in the code instead of `Date()`.
	static var now: Date { nowBuilder() }
	static var today: Date { Date.now.start(of: .day) }
	static var yesterday: Date { today - 1.days }
	static var tomorrow: Date { today + 1.days }
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
		).date ?? .now
	}

	init?(
		components: DateComponents
	) {
		var components = components
		components.calendar = components.calendar ?? .default
		components.timeZone = components.timeZone ?? .default
		guard let date = components.date else { return nil }
		self = date
	}

	@available(macOS, deprecated: 12.0, message: "use init with Date.FormatString")
	@available(iOS, deprecated: 15.0, message: "use init with Date.FormatString")
	@available(tvOS, deprecated: 15.0, message: "use init with Date.FormatString")
	@available(watchOS, deprecated: 8.0, message: "use init with Date.FormatString")
	init?(
		from string: String,
		format: DateFormat,
		locale: Locale = .default,
		timeZone: TimeZone = .default
	) {
		let formatter = DateFormatter()
		formatter.dateFormat = format.string
		formatter.locale = locale
		formatter.timeZone = timeZone
		guard let date = formatter.date(from: string) else { return nil }
		self = date
	}

	@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
	init?(
		from string: String,
		formatString: Date.FormatString,
		locale: Locale = .default,
		calendar: Calendar = .default,
		timeZone: TimeZone = .default
	) {
		let formatter = Date.ParseStrategy(format: formatString, locale: locale, timeZone: timeZone, calendar: calendar)
		guard let date = try? formatter.parse(string) else { return nil }
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
	var iso8601: String {
		let timeZone = TimeZone(secondsFromGMT: 0) ?? .default
		if #available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
			return formatted(Date.ISO8601FormatStyle(includingFractionalSeconds: true, timeZone: timeZone))
		} else {
			return string(
				.iso8601,
				locale: Locale(identifier: "en_US_POSIX"),
				timeZone: timeZone
			)
		}
	}
}

public extension Date {

	/// Returns the components of the date, using the specified calendar.
	///
	/// - Parameters:
	///   - calendar: The calendar to use for extracting the components.
	/// - Returns: The components of the date.
	var components: DateComponents {
		get { components(calendar: .default) }
		set { self = setting(newValue) }
	}

	/// Returns the components of the date, using the specified calendar.
	///
	/// - Parameters:
	///   - calendar: The calendar to use for extracting the components.
	/// - Returns: The components of the date.
	func components(_ set: Set<Calendar.Component> = Calendar.Component.allCases, calendar: Calendar) -> DateComponents {
		calendar.dateComponents(set, from: self)
	}

	/// Returns the value for one component of a date.
	/// - Parameters:
	///   - component: The component to calculate
	///   - calendar: The calendar to use
	/// - Returns: The value for the component.
	subscript(_ component: Calendar.Component, calendar calendar: Calendar = .default) -> Int {
		get { calendar.component(component, from: self) }
		set { self = setting(component, newValue, calendar: calendar) ?? self }
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

        if
            component == .month,
            [.islamic, .islamicCivil, .islamicTabular, .islamicUmmAlQura].contains(calendar.identifier),
            let startOfYear = calendar.date(from: DateComponents(calendar: calendar, year: calendar.component(.year, from: self), month: 1)),
            let index = calendar.dateComponents([.month], from: startOfYear, to: self).month
        {
            var components = calendar.dateComponents(set, from: self)
            components.month = index + 1
            return calendar.date(from: components) ?? self
        }
        set.insert(component)
        return calendar.date(from: calendar.dateComponents(set, from: self)) ?? self
	}

	/// Returns the last moment of a given Date, as a Date, with given accuracy.
	///
	/// For example, pass in `.day`, if you want the end of today.
	/// - Parameters:
	///   - component: The component to compute for
	///   - toGranularity: The component to compute for
	///   - calendar: The calendar to use
	/// - Returns: The last moment of the given date.
	func end(of component: Calendar.Component, toGranularity: Calendar.Component? = nil, calendar: Calendar = .default) -> Date {
		guard component > .second else { return self }
        guard component != toGranularity else { return start(of: component, calendar: calendar) }
		var smaller: Calendar.Component?
		if let smallest = toGranularity, calendar.range(of: smallest, in: component, for: self) != nil {
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

	func matches(_ components: DateComponents, calendar: Calendar? = nil) -> Bool {
		for component in Calendar.Component.allCases {
			guard let value = components[component] else { continue }
			if (calendar ?? components.calendar ?? .default).component(component, from: self) != value {
				print(component, value)
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
		isInSame(component, as: .now, calendar: calendar)
	}

	func isEqual(to date: Date, toGranularity: Calendar.Component, calendar: Calendar = .default) -> Bool {
		calendar.isDate(self, equalTo: date, toGranularity: toGranularity)
	}

	/// Returns the number of given component from a given date.
	func number(of component: Calendar.Component, from date: Date, calendar: Calendar = .default) -> Int {
		calendar.dateComponents(
			[component],
			from: date.start(of: component, calendar: calendar),
			to: start(of: component, calendar: calendar)
		)[component] ?? 0
	}

	/// Returns the number of given component from a given date.
	func numbers(of components: Set<Calendar.Component> = Calendar.Component.allCases, from start: Date, calendar: Calendar = .default) -> DateComponents {
		DateComponents(
			rawValue: Dictionary(
				components.map {
					($0, number(of: $0, from: start, calendar: calendar))
				},
				uniquingKeysWith: { _, s in s }
			),
			calendar: calendar
		)
	}

	/// Returns the difference between two dates.
	func components(_ components: Set<Calendar.Component> = Calendar.Component.allMinimalCases, from date: Date, calendar: Calendar = .default) -> DateComponents {
		calendar.dateComponents(components, from: date, to: self)
	}

	func range(of smaller: Calendar.Component, in larger: Calendar.Component, calendar: Calendar = .default) -> Range<Int>? {
		calendar.range(of: smaller, in: larger, for: self)
	}

	func interval(byAdding difference: DateComponents, calendar: Calendar = .default) -> DateInterval {
		let new = adding(difference)
		if new <= self {
			return DateInterval(start: new, end: self)
		} else {
			return DateInterval(start: self, end: new)
		}
	}

	func interval(of smaller: Calendar.Component, in larger: Calendar.Component, calendar: Calendar = .default) -> DateInterval? {
		let lower = start(of: larger, calendar: calendar)
		let upper = end(of: larger, toGranularity: smaller, calendar: calendar)
		guard upper > lower else { return nil }
		return DateInterval(start: lower, end: upper)
	}

	func number(of smaller: Calendar.Component, calendar: Calendar = .default) -> Int {
		smaller.larger.map { number(of: smaller, in: $0, calendar: calendar) } ?? 1
	}

	func number(of smaller: Calendar.Component, in larger: Calendar.Component, calendar: Calendar = .default) -> Int {
		if smaller.larger == larger || larger.smaller == smaller {
			return range(of: smaller, in: larger, calendar: calendar)?.count ?? 0
		} else {
			let from = start(of: larger, calendar: calendar)
			return from.adding(1, larger, calendar: calendar).number(of: smaller, from: from, calendar: calendar)
		}
	}

	@available(macOS, deprecated: 12.0, renamed: "formatted")
	@available(iOS, deprecated: 15.0, renamed: "formatted")
	@available(tvOS, deprecated: 15.0, renamed: "formatted")
	@available(watchOS, deprecated: 8.0, renamed: "formatted")
	func string(
		_ format: DateFormat,
		locale: Locale = .default,
		timeZone: TimeZone = .default
	) -> String {
		let formatter = DateFormatter()
		formatter.locale = locale
		formatter.dateFormat = format.string
		formatter.timeZone = timeZone
		return formatter.string(from: self)
	}

	@available(macOS, deprecated: 12.0, renamed: "formatted")
	@available(iOS, deprecated: 15.0, renamed: "formatted")
	@available(tvOS, deprecated: 15.0, renamed: "formatted")
	@available(watchOS, deprecated: 8.0, renamed: "formatted")
	func string(
		date: DateFormatter.Style = .short,
		time: DateFormatter.Style = .short,
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

	///	Returns a string representation of the date relative to another date.
	///
	/// - Parameters:
	///   - format: The format to use
	///   - date: The date to compare to
	///   - locale: The locale to use
	///   - timeZone: The time zone to use
	///   - calendar: The calendar to use
	/// - Returns: A string representation of the date.
	/// ```swift
	/// date.string(
	///   RelativeDateFormat(.iso8601)
	///     .at(.day(-1), "'Yesterday'")
	///     .at(.day(0), "'Today'")
	///     .at(.week(0), [.weekday])
	///     .at(.year(0), "dd.MM")
	/// )
	/// ```
	@available(macOS, deprecated: 12.0, renamed: "formatted")
	@available(iOS, deprecated: 15.0, renamed: "formatted")
	@available(tvOS, deprecated: 15.0, renamed: "formatted")
	@available(watchOS, deprecated: 8.0, renamed: "formatted")
	func string(
		format: RelativeDateFormat<DateFormat>,
		relativeTo date: Date = .now,
		locale: Locale = .default,
		timeZone: TimeZone = .default,
		calendar: Calendar = .default
	) -> String {
		string(format: format, relativeTo: date, calendar: calendar) {
			string($0, locale: locale, timeZone: timeZone)
		}
	}

	///	Returns a string representation of the date relative to another date.
	///
	/// - Parameters:
	///   - format: The format to use
	///   - date: The date to compare to
	///   - locale: The locale to use
	///   - calendar: The calendar to use
	/// - Returns: A string representation of the date.
	@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
	func formatted(
		_ format: RelativeDateFormatStyle,
		relativeTo date: Date = .now,
		locale: Locale = .default,
		calendar: Calendar = .default
	) -> String {
		string(format: format, relativeTo: date, calendar: calendar) {
			$0.format(self)
		}
	}

	private func string<T>(
		format: RelativeDateFormat<T>,
		relativeTo date: Date,
		calendar: Calendar,
		formatter: (T) -> String
	) -> String {
		formatter(format.format(from: date, to: self, calendar: calendar))
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
		case .isLeapMonth: return ""
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
	func ordinality(of smaller: Calendar.Component, in bigger: Calendar.Component, calendar: Calendar = .default) -> Int? {
		calendar.ordinality(of: smaller, in: bigger, for: self)
	}

	static func - (_ lhs: Date, _ rhs: Date) -> TimeInterval {
		lhs.timeIntervalSince(rhs)
	}

	func adding(_ components: DateComponents, wrapping: Bool = false, calendar: Calendar? = nil) -> Date {
		(calendar ?? components.calendar ?? .default).date(byAdding: components, to: self, wrappingComponents: wrapping)
			?? Date(timeInterval: components.inSeconds, since: self)
	}

	func adding(_ value: Int, _ component: Calendar.Component, wrapping: Bool = false, calendar: Calendar = .default) -> Date {
		calendar.date(
			byAdding: component,
			value: value,
			to: self,
			wrappingComponents: wrapping
		) ?? addingTimeInterval(TimeInterval(value * number(of: .second, in: component)))
	}

	func setting(_ components: DateComponents, calendar: Calendar? = nil) -> Date {
		components.rawValue.sorted(by: { $0.key > $1.key }).reduce(self) {
			$0.setting($1.key, $1.value, calendar: calendar ?? components.calendar ?? .default) ?? $0
		}
	}

	func setting(_ component: Calendar.Component, _ value: Int, calendar: Calendar = .default) -> Date? {
		switch component {
		case .nanosecond, .second, .minute, .hour:
			var comps = components(calendar: calendar)
			comps.setValue(value, for: component)
			return calendar.date(from: comps)
		case .day, .weekday, .weekdayOrdinal, .weekOfYear, .weekOfMonth, .era, .month, .quarter, .year, .yearForWeekOfYear:
			let diff = value - self[component, calendar: calendar]
			return adding(diff, component, calendar: calendar)
		case .calendar, .timeZone, .isLeapMonth:
			return nil
		@unknown default:
			return nil
		}
	}

	func compare(with date: Date, toGranularity component: Calendar.Component, calendar: Calendar = .default) -> ComparisonResult {
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
		calendar: Calendar? = nil
	) -> Date? {
		guard !time.isEmpty else { return nil }
		let calendar = calendar ?? components.calendar ?? .default
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
		guard value > 0 else { return self }
		var count = self[component, calendar: calendar]
		count = Int(Foundation.round(Double(count) / Double(value))) * value
		return (setting(component, count, calendar: calendar) ?? self).start(of: component, calendar: calendar)
	}

	func rounded(_ component: Calendar.Component, by value: Int, from date: Date, calendar: Calendar = .default) -> Date {
		guard value > 0 else { return self }
		var count = number(of: component, from: date, calendar: calendar)
		count = Int(Foundation.round(Double(count) / Double(value))) * value
		return (date + [component: count]).start(of: component, calendar: calendar)
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

public extension Date {

	/// Bootstraps the `Date.now` property with a custom builder.
	static func bootstrap(now builder: @escaping () -> Date) {
		nowBuilder = builder
	}

	/// Bootstraps the `Date.now` property with a custom builder.
	static func bootstrap(now builder: @escaping @autoclosure () -> Date) {
		bootstrap(now: builder)
	}
}

private extension Date {

	static var nowBuilder: () -> Date = { Date() }
}
