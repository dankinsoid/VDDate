import Foundation

extension DateComponents: RawRepresentable, ExpressibleByDictionaryLiteral {

	public static func era(_ value: Int) -> DateComponents { .current(era: value) }
	public static func year(_ value: Int) -> DateComponents { .current(year: value) }
	public static func month(_ value: Int) -> DateComponents { .current(month: value) }
	public static func day(_ value: Int) -> DateComponents { .current(day: value) }
	public static func hour(_ value: Int) -> DateComponents { .current(hour: value) }
	public static func minute(_ value: Int) -> DateComponents { .current(minute: value) }
	public static func second(_ value: Int) -> DateComponents { .current(second: value) }
	public static func weekday(_ value: Int) -> DateComponents { .current(weekday: value) }
	public static func weekday(_ value: Weekdays) -> DateComponents { .current(weekday: value.rawValue) }
	public static func weekdayOrdinal(_ value: Int) -> DateComponents { .current(weekdayOrdinal: value) }
	public static func quarter(_ value: Int) -> DateComponents { .current(quarter: value) }
	public static func weekOfMonth(_ value: Int) -> DateComponents { .current(weekOfMonth: value) }
	public static func weekOfYear(_ value: Int, year: Int) -> DateComponents { .current(weekOfYear: value, yearForWeekOfYear: year) }
	public static func week(_ value: Int) -> DateComponents { .current(weekOfYear: value) }
	public static func nanosecond(_ value: Int) -> DateComponents { .current(nanosecond: value) }

	public var rawValue: [Calendar.Component: Int] {
		Dictionary(
			Calendar.Component.allCases.compactMap { comp in self[comp].map { (comp, $0) } },
			uniquingKeysWith: { _, s in s }
		)
	}

	var inSeconds: TimeInterval {
		rawValue.reduce(0) {
			$0 + TimeInterval($1.value) * ($1.key.inSeconds ?? 0)
		}
	}

	public init(dictionaryLiteral elements: (Calendar.Component, Int)...) {
		let dict = Dictionary(elements, uniquingKeysWith: { _, s in s })
		self = DateComponents(rawValue: dict)
	}

	public init(rawValue: [Calendar.Component: Int]) {
		self.init(rawValue: rawValue, calendar: nil)
	}

	public init(
		rawValue: [Calendar.Component: Int],
		calendar: Calendar?,
		timeZone: TimeZone? = nil
	) {
		self = DateComponents(
			calendar: nil,
			timeZone: nil,
			era: rawValue[.era],
			year: rawValue[.year],
			month: rawValue[.month],
			day: rawValue[.day],
			hour: rawValue[.hour],
			minute: rawValue[.minute],
			second: rawValue[.second],
			nanosecond: rawValue[.nanosecond],
			weekday: rawValue[.weekday],
			weekdayOrdinal: rawValue[.weekdayOrdinal],
			quarter: rawValue[.quarter],
			weekOfMonth: rawValue[.weekOfMonth],
			weekOfYear: rawValue[.weekOfYear],
			yearForWeekOfYear: rawValue[.yearForWeekOfYear]
		)
	}

	public init() {
		self = DateComponents(rawValue: [:])
	}

	public subscript(_ component: Calendar.Component) -> Int? {
		get {
			switch component {
			case .era: return era
			case .year: return year
			case .month: return month
			case .day: return day
			case .hour: return hour
			case .minute: return minute
			case .second: return second
			case .weekday: return weekday
			case .weekdayOrdinal: return weekdayOrdinal
			case .quarter: return quarter
			case .weekOfMonth: return weekOfMonth
			case .weekOfYear: return weekOfYear
			case .yearForWeekOfYear: return yearForWeekOfYear
			case .nanosecond: return nanosecond
			default: return nil
			}
		}
		set {
			setValue(newValue, for: component)
		}
	}

	public func contains(_ other: DateComponents) -> Bool {
		for (key, value) in other.rawValue {
			if self[key] != value { return false }
		}
		return true
	}

	public func `in`(_ component: Calendar.Component, calendar: Calendar = .default) -> DateComponents {
		let components = rawValue.filter {
			$0.key < component
		}
		return DateComponents(rawValue: components)
	}

	public static func + (_ lhs: DateComponents, _ rhs: DateComponents) -> DateComponents {
		operation(lhs, rhs, +)
	}

	public static func - (_ lhs: DateComponents, _ rhs: DateComponents) -> DateComponents {
		operation(lhs, rhs, -)
	}

	public static func += (_ lhs: inout DateComponents, _ rhs: DateComponents) {
		lhs = lhs + rhs
	}

	public static func -= (_ lhs: inout DateComponents, _ rhs: DateComponents) {
		lhs = lhs - rhs
	}

	public static func / (_ lhs: DateComponents, _ rhs: Int) -> DateComponents {
		operation(lhs, rhs, /)
	}

	public static func /= (_ lhs: inout DateComponents, _ rhs: Int) {
		lhs = lhs / rhs
	}

	public static func * (_ lhs: DateComponents, _ rhs: Int) -> DateComponents {
		operation(lhs, rhs, *)
	}

	public static func * (_ lhs: Int, _ rhs: DateComponents) -> DateComponents {
		rhs * lhs
	}

	public static func *= (_ lhs: inout DateComponents, _ rhs: Int) {
		lhs = lhs * rhs
	}

	private static func operation(
		_ lhs: DateComponents,
		_ rhs: DateComponents,
		_ block: (Int, Int) -> Int
	) -> DateComponents {
		let l = lhs.rawValue
		let r = rhs.rawValue
		return DateComponents(
			rawValue: Dictionary(Set(l.keys).union(r.keys).map { ($0, block(l[$0] ?? 0, r[$0] ?? 0)) }) { _, s in s },
			calendar: lhs.calendar ?? rhs.calendar,
			timeZone: lhs.timeZone ?? rhs.timeZone
		)
	}

	private static func operation(
		_ lhs: DateComponents,
		_ rhs: Int,
		_ block: (Int, Int) -> Int
	) -> DateComponents {
		DateComponents(
			rawValue: lhs.rawValue.mapValues { lhs in
				block(lhs, rhs)
			},
			calendar: lhs.calendar
		)
	}
}

extension DateComponents {

	func minComponent() -> Int {
		let all = Set(rawValue.keys)
		let sorted = Calendar.Component.sorted
		return all.compactMap(sorted.firstIndex).first ?? 0
	}

	static func current(
		timeZone: TimeZone? = .default,
		era: Int? = nil,
		year: Int? = nil,
		month: Int? = nil,
		day: Int? = nil,
		hour: Int? = nil,
		minute: Int? = nil,
		second: Int? = nil,
		nanosecond: Int? = nil,
		weekday: Int? = nil,
		weekdayOrdinal: Int? = nil,
		quarter: Int? = nil,
		weekOfMonth: Int? = nil,
		weekOfYear: Int? = nil,
		yearForWeekOfYear: Int? = nil
	) -> DateComponents {
		DateComponents(
			calendar: .default,
			timeZone: timeZone,
			era: era,
			year: year,
			month: month,
			day: day,
			hour: hour,
			minute: minute,
			second: second,
			nanosecond: nanosecond,
			weekday: weekday,
			weekdayOrdinal: weekdayOrdinal,
			quarter: quarter,
			weekOfMonth: weekOfMonth,
			weekOfYear: weekOfYear,
			yearForWeekOfYear: yearForWeekOfYear
		)
	}

	static func dif(_ component: Calendar.Component, _ value: Int) -> DateComponents {
		var result = DateComponents(
			era: 0,
			year: 0,
			month: 0,
			day: 0,
			hour: 0,
			minute: 0,
			second: 0,
			nanosecond: 0,
			weekday: 0,
			weekdayOrdinal: 0,
			quarter: 0,
			weekOfMonth: 0,
			weekOfYear: 0,
			yearForWeekOfYear: 0
		)
		result[component] = value
		return result
	}
}

public extension BinaryInteger {

	var eras: DateComponents { .dif(.era, Int(self)) }
	var years: DateComponents { .dif(.year, Int(self)) }
	var quarters: DateComponents { .dif(.quarter, Int(self)) }
	var months: DateComponents { .dif(.month, Int(self)) }
	var weeks: DateComponents { .dif(.week, Int(self)) }
	var days: DateComponents { .dif(.day, Int(self)) }
	var hours: DateComponents { .dif(.hour, Int(self)) }
	var minutes: DateComponents { .dif(.minute, Int(self)) }
	var seconds: DateComponents { .dif(.second, Int(self)) }
	var nanoseconds: DateComponents { .dif(.nanosecond, Int(self)) }
}

public prefix func - (_ rhs: DateComponents) -> DateComponents {
	-1 * rhs
}

public func + (_ lhs: Date, _ rhs: DateComponents) -> Date {
	lhs.adding(rhs)
}

public func - (_ lhs: Date, _ rhs: DateComponents) -> Date {
	lhs.adding(-rhs)
}

public func += (_ lhs: inout Date, _ rhs: DateComponents) {
	lhs = lhs + rhs
}

public func -= (_ lhs: inout Date, _ rhs: DateComponents) {
	lhs = lhs - rhs
}

public func == (_ lhs: DateInterval, _ rhs: DateComponents) -> Bool {
	rhs == lhs
}

public func == (_ lhs: DateComponents, _ rhs: DateInterval) -> Bool {
	rhs.start.adding(lhs) == rhs.end
}
