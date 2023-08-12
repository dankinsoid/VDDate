import Foundation

public struct DateFormat: ExpressibleByArrayLiteral, ExpressibleByStringInterpolation, Hashable, Codable, CustomStringConvertible {

	public var string: String

	public var components: [Component] {
		get {
			DateFormatParser(string).parse()
		}
		set {
			string = newValue.map(\.format).joined()
		}
	}

	public var description: String {
		string
	}

	public init(arrayLiteral components: Component...) {
		self.init(components)
	}

	public init<T: Collection>(_ components: T) where T.Element == Component {
		string = components.map(\.format).joined()
	}

	public init(stringInterpolation: StringInterpolation) {
		self.init(stringInterpolation.components)
	}

	public init(stringLiteral value: String) {
		self.init(value)
	}

	public init(_ value: String) {
		string = value
	}

	public init(from decoder: Decoder) throws {
		try self.init(String(from: decoder))
	}

	public func encode(to encoder: Encoder) throws {
		try string.encode(to: encoder)
	}

	public enum Component: Hashable, ExpressibleByStringLiteral {

		case string(String)
		case component(Character, Int)

		public var format: String {
			switch self {
			case let .string(string):
				if
					!string.isEmpty && DateFormat.Component.characterSet.contains(string[string.startIndex]) ||
					string.count > 1 && DateFormat.Component.characterSet.contains(string[string.index(before: string.endIndex)])
				{
					return "'\(string)'"
				} else {
					return string
				}

			case let .component(char, count):
				return String(repeating: char, count: count)
			}
		}

		public init(stringLiteral value: String.StringLiteralType) {
			if Set(value).count == 1, Self.characterSet.contains(value[value.startIndex]) {
				self = .component(value[value.startIndex], value.count)
			} else {
				self = .string(value)
			}
		}
	}

	public struct StringInterpolation: StringInterpolationProtocol {

		public typealias StringLiteralType = String
		public var components: [Component]

		public init(literalCapacity: Int, interpolationCount: Int) {
			components = []
			components.reserveCapacity(literalCapacity + interpolationCount)
		}

		public mutating func appendLiteral(_ literal: String) {
			if !literal.isEmpty {
				components.append(.string(literal))
			}
		}

		public mutating func appendInterpolation(_ component: Component) {
			components.append(component)
		}

		public mutating func appendInterpolation(_ component: Calendar.Component, style: DateFormat.Component.Style) {
			components.append(.calendarComponent(component, style: style))
		}
	}
}

public extension DateFormat.Component {

	static var characterSet: Set<Character> {
		["a", "G", "y", "Y", "M", "d", "H", "h", "m", "s", "E", "Q", "w", "W", "S", "Z"]
	}

	/// AM/PM
	static var am_pm: DateFormat.Component { .component("a", 1) }
	/// era: AD
	static var G: DateFormat.Component { .component("G", 1) }
	/// era: AD
	static var GGG: DateFormat.Component { .component("G", 3) }
	/// era: Anno Domini
	static var GGGG: DateFormat.Component { .component("G", 4) }
	/// year: 22
	static var yy: DateFormat.Component { .component("y", 2) }
	/// year: 2022, recomended
	static var y: DateFormat.Component { .component("y", 1) }
	/// year: 2022
	static var year: DateFormat.Component { .y }
	/// year: 2022
	static var yyyy: DateFormat.Component { .component("y", 4) }
	/// month: 1
	static var M: DateFormat.Component { .component("M", 1) }
	/// month: 01
	static var MM: DateFormat.Component { .component("M", 2) }
	/// month: Jan
	static var MMM: DateFormat.Component { .component("M", 3) }
	/// month: January
	static var MMMM: DateFormat.Component { .component("M", 4) }
	/// month: January
	static var month: DateFormat.Component { .MMMM }
	/// month: J
	static var MMMMM: DateFormat.Component { .component("M", 5) }
	/// day: 1
	static var d: DateFormat.Component { .component("d", 1) }
	/// day: 1
	static var day: DateFormat.Component { .d }
	/// day: 01
	static var dd: DateFormat.Component { .component("d", 2) }
	/// 12 hour format: 1
	static var h: DateFormat.Component { .component("h", 1) }
	/// 12 hour format: 01
	static var hh: DateFormat.Component { .component("h", 2) }
	/// 24 hour format: 1
	static var H: DateFormat.Component { .component("H", 1) }
	/// 24 hour format: 01
	static var HH: DateFormat.Component { .component("H", 2) }
	/// 24 hour format: 01
	static var hour: DateFormat.Component { .HH }
	/// minute: 1
	static var m: DateFormat.Component { .component("m", 1) }
	/// minute: 01
	static var mm: DateFormat.Component { .component("m", 2) }
	/// minute: 01
	static var minute: DateFormat.Component { .mm }
	/// second: 1
	static var s: DateFormat.Component { .component("s", 1) }
	/// second: 01
	static var ss: DateFormat.Component { .component("s", 2) }
	/// second: 01
	static var second: DateFormat.Component { .ss }
	/// weekday: Thu
	static var E: DateFormat.Component { .component("E", 1) }
	/// weekday: Thursday
	static var EEEE: DateFormat.Component { .component("E", 4) }
	/// weekday: Thursday
	static var weekday: DateFormat.Component { .EEEE }
	/// weekday: T
	static var EEEEE: DateFormat.Component { .component("E", 5) }
	/// quarter: 1
	static var Q: DateFormat.Component { .component("Q", 1) }
	/// quarter: Q1
	static var QQQ: DateFormat.Component { .component("Q", 3) }
	/// quarter: 1st quarter
	static var QQQQ: DateFormat.Component { .component("Q", 4) }
	/// week of month: 5
	static var W: DateFormat.Component { .component("W", 1) }
	/// week of year: 5
	static var w: DateFormat.Component { .component("w", 1) }
	/// week of year: 5
	static var week: DateFormat.Component { .w }
	/// week of year: 05
	static var ww: DateFormat.Component { .component("w", 2) }
	/// year for week of year: 22
	static var YY: DateFormat.Component { .component("Y", 2) }
	/// year for week of year: 2022
	static var Y: DateFormat.Component { .component("Y", 1) }
	/// year for week of year: 2022
	static var YYYY: DateFormat.Component { .component("Y", 4) }
	/// milliseconds: 000
	static var SSS: DateFormat.Component { .component("S", 3) }
	/// milliseconds: 0000
	static var SSSS: DateFormat.Component { .component("S", 4) }
	/// time zone: +0300
	static var Z: DateFormat.Component { .component("Z", 1) }
	/// time zone: GMT+03:00
	static var zzzz: DateFormat.Component { .component("z", 4) }
	/// time zone: +03:00
	static var ZZZZZ: DateFormat.Component { .component("Z", 5) }
	/// time zone: GMT+3
	static var zzz: DateFormat.Component { .component("z", 3) }
	/// time zone: GMT+3
	static var timeZone: DateFormat.Component { .zzz }
}

public extension DateFormat.Component {

	enum Style: String, Codable, Hashable {

		case short, full, spellOut, abbreviated, narrow
	}

	static func calendarComponent(_ component: Calendar.Component, style: Style) -> DateFormat.Component {
		switch component {
		case .era:
			switch style {
			case .short, .narrow: return .component("G", 1)
			case .abbreviated: return .component("G", 3)
			case .full, .spellOut: return .component("G", 4)
			}
		case .year:
			switch style {
			case .short, .narrow: return .component("y", 2)
			case .abbreviated: return .component("y", 1)
			case .full, .spellOut: return .component("y", 4)
			}
		case .month:
			switch style {
			case .short: return .component("M", 1)
			case .full: return .component("M", 2)
			case .abbreviated: return .component("M", 3)
			case .spellOut: return .component("M", 4)
			case .narrow: return .component("M", 5)
			}
		case .day:
			switch style {
			case .short: return .component("d", 1)
			default: return .component("d", 2)
			}
		case .hour:
			switch style {
			case .short, .narrow: return .component("h", 1)
			case .full: return .component("h", 2)
			case .abbreviated: return .component("H", 1)
			default: return .component("H", 2)
			}
		case .minute:
			switch style {
			case .short, .narrow: return .component("m", 1)
			default: return .component("m", 2)
			}
		case .second:
			switch style {
			case .short: return .component("s", 1)
			default: return .component("s", 2)
			}
		case .weekday, .weekdayOrdinal:
			switch style {
			case .short, .abbreviated: return .component("E", 1)
			case .full, .spellOut: return .component("E", 4)
			case .narrow: return .component("E", 5)
			}
		case .quarter:
			switch style {
			case .short: return .component("Q", 1)
			case .full, .abbreviated, .narrow: return .component("Q", 3)
			case .spellOut: return .component("Q", 4)
			}
		case .weekOfMonth: return .component("W", 1)
		case .weekOfYear:
			switch style {
			case .short, .narrow: return .component("w", 1)
			default: return .component("w", 2)
			}
		case .yearForWeekOfYear:
			switch style {
			case .short, .narrow: return .component("Y", 2)
			case .abbreviated: return .component("Y", 1)
			case .full, .spellOut: return .component("Y", 4)
			}
		case .nanosecond:
			switch style {
			case .short, .narrow: return .component("S", 3)
			case .full, .spellOut, .abbreviated: return .component("S", 4)
			}
		case .timeZone, .calendar:
			switch style {
			case .short: return .component("Z", 1)
			case .abbreviated: return .component("Z", 5)
			case .full, .spellOut: return .component("z", 4)
			case .narrow: return .component("z", 3)
			}
		@unknown default: return .string("")
		}
	}
}

public extension DateFormat {

	static let iso8601: DateFormat = "\(.yyyy)-\(.MM)-\(.dd)T\(.HH):\(.mm):\(.ss).\(.SSS)\(.ZZZZZ)"
}
