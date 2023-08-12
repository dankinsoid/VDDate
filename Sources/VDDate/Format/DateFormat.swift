import Foundation

public struct DateFormat: MutableCollection, RandomAccessCollection, ExpressibleByArrayLiteral, ExpressibleByStringInterpolation, Equatable, Hashable, Codable, CustomStringConvertible {

	public typealias FormatInput = Date
	public typealias FormatOutput = String

	public var elements: [Element]
	public var startIndex: Int { elements.startIndex }
	public var endIndex: Int { elements.endIndex }

	public var format: String {
		elements.map { $0.format }.joined()
	}

	public var description: String {
		format
	}

	public var parseStrategy: Strategy {
		Strategy(format)
	}

	public init(arrayLiteral elements: Element...) {
		self.elements = elements
	}

	public init<T: Collection>(_ elements: T) where T.Element == Element {
		self.elements = Array(elements)
	}

	public init(stringInterpolation: StringInterpolation) {
		elements = stringInterpolation.elements
	}

	public init(stringLiteral value: String) {
		elements = [Element(value)]
	}

	public subscript(position: Int) -> Element {
		get { elements[position] }
		set { elements[position] = newValue }
	}

	public func index(after i: Int) -> Int {
		elements.index(after: i)
	}

	public func format(_ value: Date) -> String {
		value.string(format)
	}

	public func date(from string: String) -> Date? {
		try? parseStrategy.parse(string)
	}

	public enum Element: ExpressibleByStringLiteral, Equatable, Hashable, Codable {
		case string(String), component(Calendar.Component, style: Style), custom(String)

		public var string: String? {
			if case let .string(string) = self {
				return string
			}
			return nil
		}

		public var component: Calendar.Component? {
			if case let .component(component, _) = self {
				return component
			}
			return nil
		}

		public var style: Style? {
			if case let .component(_, style) = self {
				return style
			}
			return nil
		}

		public enum Style: String, Codable, Hashable {
			case short, full, spellOut, abbreviated, narrow
		}

		public var format: String {
			switch self {
			case let .string(string):
				return "'\(string)'"
			case let .custom(format):
				return format
			case let .component(component, style):
				switch component {
				case .era:
					switch style {
					case .short, .narrow: return "G"
					case .abbreviated: return "GGG"
					case .full, .spellOut: return "GGGG"
					}
				case .year:
					switch style {
					case .short, .narrow: return "yy"
					case .abbreviated: return "y"
					case .full, .spellOut: return "yyyy"
					}
				case .month:
					switch style {
					case .short: return "M"
					case .full: return "MM"
					case .abbreviated: return "MMM"
					case .spellOut: return "MMMM"
					case .narrow: return "MMMMM"
					}
				case .day:
					switch style {
					case .short: return "d"
					default: return "dd"
					}
				case .hour:
					switch style {
					case .short, .narrow: return "h"
					case .full: return "hh"
					case .abbreviated: return "H"
					default: return "HH"
					}
				case .minute:
					switch style {
					case .short, .narrow: return "m"
					default: return "mm"
					}
				case .second:
					switch style {
					case .short: return "s"
					default: return "ss"
					}
				case .weekday, .weekdayOrdinal:
					switch style {
					case .short: return "E"
					case .full, .spellOut: return "EEEE"
					case .abbreviated: return "E"
					case .narrow: return "EEEEE"
					}
				case .quarter:
					switch style {
					case .short: return "Q"
					case .full, .abbreviated, .narrow: return "QQQ"
					case .spellOut: return "QQQQ"
					}
				case .weekOfMonth: return "W"
				case .weekOfYear:
					switch style {
					case .short, .narrow: return "w"
					default: return "ww"
					}
				case .yearForWeekOfYear:
					switch style {
					case .short, .narrow: return "YY"
					case .abbreviated: return "Y"
					case .full, .spellOut: return "YYYY"
					}
				case .nanosecond:
					switch style {
					case .short, .narrow: return "SSS"
					case .full, .spellOut, .abbreviated: return "SSSS"
					}
				case .timeZone, .calendar:
					switch style {
					case .short: return "Z"
					case .full: return "zzzz"
					case .abbreviated: return "ZZZZZ"
					case .spellOut: return "zzzz"
					case .narrow: return "zzz"
					}
				@unknown default: return ""
				}
			}
		}

		public init(_ component: Calendar.Component, style: Style) {
			self = .component(component, style: style)
		}

		public init(_ string: String) {
			self = .string(string)
		}

		public init(stringLiteral value: String.StringLiteralType) {
			self = Element(value)
		}

		//		public func format(_ value: Int) -> String {
		//			guard let component = component else {
		//				return string ?? "\(value)"
		//			}
		//			guard let date = Date(components: [component: value]) else {
		//
		//			}
		//			let formatter = DateComponentsFormatter()
		//			formatter.allowedUnits = [.weekOfYear]
		//		formatter.unitsStyle.rawValue
		//			formatter.
		//			formatter.string(from: [component: value])
		//			return date.string(format)
		//		}
	}

	public struct StringInterpolation: StringInterpolationProtocol {
		public typealias StringLiteralType = String
		public var elements: [Element]

		public init(literalCapacity: Int, interpolationCount: Int) {
			elements = []
			elements.reserveCapacity(literalCapacity + interpolationCount)
		}

		public mutating func appendLiteral(_ literal: String) {
			if !literal.isEmpty {
				elements.append(Element(literal))
			}
		}

		public mutating func appendInterpolation(_ element: Element) {
			elements.append(element)
		}

		public mutating func appendInterpolation(_ component: Calendar.Component, style: DateFormat.Element.Style) {
			elements.append(.component(component, style: style))
		}
	}

	public static func == (_ lhs: DateFormat, _ rhs: DateFormat) -> Bool {
		lhs.count == rhs.count && lhs.elements == rhs.elements
	}
}

extension DateComponentsFormatter.UnitsStyle: Decodable {}
extension DateComponentsFormatter.UnitsStyle: Encodable {}

public extension DateFormat {

	struct Strategy {
		public typealias ParseInput = FormatOutput
		public typealias ParseOutput = FormatInput

		public var format: String

		public init(_ format: String) {
			self.format = format
		}

		public func parse(_ value: DateFormat.FormatOutput) throws -> DateFormat.FormatInput {
			if let result = Date(from: value, format: format) {
				return result
			}
			throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Invalid date format \(format)", underlyingError: nil))
		}
	}
}

public extension DateFormat.Element {
	/// AM/PM
	static var am_pm: DateFormat.Element { .custom("a") }
	// era: AD
	static var G: DateFormat.Element { .init(.era, style: .short) }
	// era: AD
	static var GGG: DateFormat.Element { .init(.era, style: .abbreviated) }
	// era: Anno Domini
	static var GGGG: DateFormat.Element { .init(.era, style: .spellOut) }
	// year: 22
	static var yy: DateFormat.Element { .init(.year, style: .short) }
	// year: 2022, recomended
	static var y: DateFormat.Element { .init(.year, style: .abbreviated) }
	// year: 2022
	static var year: DateFormat.Element { .y }
	// year: 2022
	static var yyyy: DateFormat.Element { .init(.year, style: .full) }
	// month: 1
	static var M: DateFormat.Element { .init(.month, style: .short) }
	// month: 01
	static var MM: DateFormat.Element { .init(.month, style: .full) }
	// month: Jan
	static var MMM: DateFormat.Element { .init(.month, style: .abbreviated) }
	// month: January
	static var MMMM: DateFormat.Element { .init(.month, style: .spellOut) }
	// month: January
	static var month: DateFormat.Element { .MMMM }
	// month: J
	static var MMMMM: DateFormat.Element { .init(.month, style: .narrow) }
	// day: 1
	static var d: DateFormat.Element { .init(.day, style: .short) }
	// day: 1
	static var day: DateFormat.Element { .d }
	// day: 01
	static var dd: DateFormat.Element { .init(.day, style: .full) }
	/// 12 hour format: 1
	static var h: DateFormat.Element { .init(.hour, style: .short) }
	/// 12 hour format: 01
	static var hh: DateFormat.Element { .init(.hour, style: .full) }
	/// 24 hour format: 1
	static var H: DateFormat.Element { .init(.hour, style: .abbreviated) }
	/// 24 hour format: 01
	static var HH: DateFormat.Element { .init(.hour, style: .spellOut) }
	// minute: 1
	static var m: DateFormat.Element { .init(.minute, style: .short) }
	// minute: 01
	static var mm: DateFormat.Element { .init(.minute, style: .full) }
	// second: 1
	static var s: DateFormat.Element { .init(.second, style: .short) }
	// second: 01
	static var ss: DateFormat.Element { .init(.second, style: .full) }
	// weekday: Thu
	static var E: DateFormat.Element { .init(.weekday, style: .short) }
	// weekday: Thursday
	static var EEEE: DateFormat.Element { .init(.weekday, style: .full) }
	// weekday: Thursday
	static var weekday: DateFormat.Element { .EEEE }
	// weekday: T
	static var EEEEE: DateFormat.Element { .init(.weekday, style: .narrow) }
	// quarter: 1
	static var Q: DateFormat.Element { .init(.quarter, style: .short) }
	// quarter: Q1
	static var QQQ: DateFormat.Element { .init(.quarter, style: .full) }
	// quarter: 1st quarter
	static var QQQQ: DateFormat.Element { .init(.quarter, style: .spellOut) }
	/// week of month: 5
	static var W: DateFormat.Element { .init(.weekOfMonth, style: .short) }
	/// week of year: 5
	static var w: DateFormat.Element { .init(.weekOfYear, style: .short) }
	/// week of year: 05
	static var ww: DateFormat.Element { .init(.weekOfYear, style: .full) }
	/// year for week of year: 22
	static var YY: DateFormat.Element { .init(.yearForWeekOfYear, style: .short) }
	/// year for week of year: 2022
	static var Y: DateFormat.Element { .init(.yearForWeekOfYear, style: .abbreviated) }
	/// year for week of year: 2022
	static var YYYY: DateFormat.Element { .init(.yearForWeekOfYear, style: .full) }
	// miliseconds: 000
	static var SSS: DateFormat.Element { .init(.nanosecond, style: .short) }
	// miliseconds: 0000
	static var SSSS: DateFormat.Element { .init(.nanosecond, style: .full) }
	/// time zone: +0300
	static var Z: DateFormat.Element { .init(.timeZone, style: .short) }
	/// time zone: GMT+03:00
	static var zzzz: DateFormat.Element { .init(.timeZone, style: .full) }
	/// time zone: +03:00
	static var ZZZZZ: DateFormat.Element { .init(.timeZone, style: .abbreviated) }
	/// time zone: GMT+3
	static var zzz: DateFormat.Element { .init(.timeZone, style: .narrow) }
	/// time zone: GMT+3
	static var timeZone: DateFormat.Element { .zzz }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension DateFormat.Strategy: ParseStrategy {}

/// A type that can convert a given data type into a representation.
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension DateFormat: FormatStyle, ParseableFormatStyle {}

///// A type that can convert a given data type into a representation.
// @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
// extension DateFormat.Element: FormatStyle {
//	public typealias FormatInput = Int
//	public typealias FormatOutput = String
// }
