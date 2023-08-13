import Foundation

extension Calendar.Component: CaseIterable, Comparable {

	public typealias AllCases = Set<Calendar.Component>

	public static var week: Calendar.Component {
		.weekOfYear
	}

	public static var sorted: [Calendar.Component] {
		[.nanosecond, .second, .minute, .hour, .day, .weekday, .weekdayOrdinal, .weekOfMonth, .weekOfYear, .month, .quarter, .year, .yearForWeekOfYear, .timeZone, .era, .calendar]
	}

	public static var allCases: Set<Calendar.Component> {
		[.year, .month, .day, .hour, .minute, .second, .weekday, .weekdayOrdinal, .quarter, .weekOfMonth, .weekOfYear, .yearForWeekOfYear, .nanosecond, .calendar, .timeZone, .era]
	}

	public static var allMinimalCases: Set<Calendar.Component> {
		[.year, .month, .day, .hour, .minute, .second, .nanosecond]
	}

	public var first: Int {
		switch self {
		case .era, .year, .month, .day, .weekday, .weekOfYear, .weekOfMonth, .weekdayOrdinal, .yearForWeekOfYear:
			return 1
		default:
			return 0
		}
	}

	public var smaller: Calendar.Component? {
		switch self {
		case .era: return .year
		case .year: return .month
		case .month: return .day
		case .day: return .hour
		case .hour: return .minute
		case .minute: return .second
		case .second: return .nanosecond
		case .weekday: return .hour
		case .weekdayOrdinal: return .hour
		case .quarter: return .month
		case .weekOfMonth: return .day
		case .weekOfYear: return .day
		case .yearForWeekOfYear: return .weekOfYear
		case .nanosecond: return nil
		case .calendar: return nil
		case .timeZone: return nil
		@unknown default: return nil
		}
	}

	public var allLarger: Set<Calendar.Component> {
		var result: Set<Calendar.Component> = []
		var current = larger
		while let component = current {
			result.insert(component)
			current = component.larger
		}
		return result
	}

	public var larger: Calendar.Component? {
		switch self {
		case .era: return nil
		case .year: return .era
		case .month: return .year
		case .day: return .month
		case .hour: return .day
		case .minute: return .hour
		case .second: return .minute
		case .weekday: return .day
		case .weekdayOrdinal: return .day
		case .quarter: return .year
		case .weekOfMonth: return .month
		case .weekOfYear: return .yearForWeekOfYear
		case .yearForWeekOfYear: return .era
		case .nanosecond: return .second
		case .calendar: return nil
		case .timeZone: return nil
		@unknown default: return nil
		}
	}

	var inSeconds: TimeInterval? {
		switch self {
		case .era: return nil
		case .year, .yearForWeekOfYear: return Calendar.Component.day.inSeconds.map { 365.2425 * $0 }
		case .month: return Calendar.Component.year.inSeconds.map { $0 / 12 }
		case .day: return Calendar.Component.hour.inSeconds.map { 24 * $0 }
		case .hour: return Calendar.Component.minute.inSeconds.map { 60 * $0 }
		case .minute: return Calendar.Component.second.inSeconds.map { $0 * 60 }
		case .second: return 1
		case .weekday: return Calendar.Component.day.inSeconds
		case .weekdayOrdinal: return Calendar.Component.day.inSeconds
		case .quarter: return Calendar.Component.month.inSeconds.map { 4 * $0 }
		case .weekOfMonth, .weekOfYear: return Calendar.Component.day.inSeconds.map { 7 * $0 }
		case .nanosecond: return Calendar.Component.second.inSeconds.map { $0 / 1_000_000_000 }
		case .calendar: return nil
		case .timeZone: return nil
		@unknown default: return nil
		}
	}

	public func `as`(_ component: Calendar.Component) -> Double? {
		guard component != .second else { return inSeconds ?? 1 }
		let other = component.inSeconds
		guard other != 0 else { return 0 }
		guard let other else { return nil }
		return inSeconds.map { $0 / other }
	}

	public static func < (lhs: Calendar.Component, rhs: Calendar.Component) -> Bool {
		sorted.filter { $0 == lhs || $0 == rhs } == [lhs, rhs]
	}
}

extension Calendar.Component: Codable, RawRepresentable, CustomStringConvertible {

	public var rawValue: String {
		switch self {
		case .era: return "era"
		case .year: return "year"
		case .month: return "month"
		case .day: return "day"
		case .hour: return "hour"
		case .minute: return "minute"
		case .second: return "second"
		case .weekday: return "weekday"
		case .weekdayOrdinal: return "weekdayOrdinal"
		case .quarter: return "quarter"
		case .weekOfMonth: return "weekOfMonth"
		case .weekOfYear: return "weekOfYear"
		case .yearForWeekOfYear: return "yearForWeekOfYear"
		case .nanosecond: return "nanosecond"
		case .calendar: return "calendar"
		case .timeZone: return "timeZone"
		@unknown default: return "unknown"
		}
	}

	public var description: String { rawValue }

	public init?(rawValue: String) {
		switch rawValue {
		case "era": self = .era
		case "year": self = .year
		case "month": self = .month
		case "day": self = .day
		case "hour": self = .hour
		case "minute": self = .minute
		case "second": self = .second
		case "weekday": self = .weekday
		case "weekdayOrdinal": self = .weekdayOrdinal
		case "quarter": self = .quarter
		case "weekOfMonth": self = .weekOfMonth
		case "weekOfYear": self = .weekOfYear
		case "yearForWeekOfYear": self = .yearForWeekOfYear
		case "nanosecond": self = .nanosecond
		case "calendar": self = .calendar
		case "timeZone": self = .timeZone
		default: return nil
		}
	}

	public init(from decoder: Decoder) throws {
		let raw = try String(from: decoder)
		if let it = Calendar.Component(rawValue: raw) {
			self = it
		} else {
			throw DecodingError.dataCorrupted(
				DecodingError.Context(
					codingPath: decoder.codingPath,
					debugDescription: "Invalid raw value \(raw) for Calendar.Component",
					underlyingError: nil
				)
			)
		}
	}

	public func encode(to encoder: Encoder) throws {
		try rawValue.encode(to: encoder)
	}
}
