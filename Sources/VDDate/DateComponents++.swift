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
	public static func nanoseconds(_ value: Int) -> DateComponents { .current(nanosecond: value) }

	public subscript(_ component: Calendar.Component) -> Int? {
		get { self.component(component) }
		set { setValue(newValue, for: component) }
	}

	public var rawValue: [Calendar.Component: Int] {
		Dictionary(Calendar.Component.allCases.compactMap { comp in component(comp).map { (comp, $0) } }, uniquingKeysWith: { _, s in s })
	}

	public init(dictionaryLiteral elements: (Calendar.Component, Int)...) {
		let dict = Dictionary(elements, uniquingKeysWith: { _, s in s })
		self = DateComponents(rawValue: dict)
	}

	public init(rawValue: [Calendar.Component: Int]) {
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

	private static func operation(_ lhs: DateComponents, _ rhs: DateComponents, _ block: (Int, Int) -> Int) -> DateComponents {
		.current(
			era: operation(block, lhs, rhs, at: \.era),
			year: operation(block, lhs, rhs, at: \.year),
			month: operation(block, lhs, rhs, at: \.month),
			day: operation(block, lhs, rhs, at: \.day),
			hour: operation(block, lhs, rhs, at: \.hour),
			minute: operation(block, lhs, rhs, at: \.minute),
			second: operation(block, lhs, rhs, at: \.second),
			nanosecond: operation(block, lhs, rhs, at: \.nanosecond),
			weekday: operation(block, lhs, rhs, at: \.weekday),
			weekdayOrdinal: operation(block, lhs, rhs, at: \.weekdayOrdinal),
			quarter: operation(block, lhs, rhs, at: \.quarter),
			weekOfMonth: operation(block, lhs, rhs, at: \.weekOfMonth),
			weekOfYear: operation(block, lhs, rhs, at: \.weekOfYear),
			yearForWeekOfYear: operation(block, lhs, rhs, at: \.yearForWeekOfYear)
		)
	}

	private static func operation(_ operation: (Int, Int) -> Int, _ lhs: DateComponents, _ rhs: DateComponents, at keyPath: KeyPath<DateComponents, Int?>) -> Int? {
		if let left = lhs[keyPath: keyPath] {
			return operation(left, rhs[keyPath: keyPath] ?? 0)
		}
		return rhs[keyPath: keyPath].map { operation(0, $0) }
	}

    static func current(timeZone: TimeZone? = .default, era: Int? = nil, year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil, nanosecond: Int? = nil, weekday: Int? = nil, weekdayOrdinal: Int? = nil, quarter: Int? = nil, weekOfMonth: Int? = nil, weekOfYear: Int? = nil, yearForWeekOfYear: Int? = nil) -> DateComponents {
		DateComponents(calendar: .default, timeZone: timeZone, era: era, year: year, month: month, day: day, hour: hour, minute: minute, second: second, nanosecond: nanosecond, weekday: weekday, weekdayOrdinal: weekdayOrdinal, quarter: quarter, weekOfMonth: weekOfMonth, weekOfYear: weekOfYear, yearForWeekOfYear: yearForWeekOfYear)
	}

    func component(_ component: Calendar.Component) -> Int? {
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

	public func contains(_ other: DateComponents) -> Bool {
		for (key, value) in other.rawValue {
			if component(key) != value { return false }
		}
		return true
	}

    func minComponent() -> Int {
		let all = Set(rawValue.map { $0.key })
		let sorted = Calendar.Component.sorted
		return all.compactMap(sorted.firstIndex).first ?? 0
	}
}
