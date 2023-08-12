import Foundation

public enum DateDifference: Hashable, Equatable, Comparable, ExpressibleByDictionaryLiteral {

	case interval(TimeInterval)
	case dates(from: Date, to: Date)
	case components([Calendar.Component: Int])

	public var eras: Int { component(.era) }
	public var years: Int { component(.year) }
	public var quarters: Int { component(.quarter) }
	public var months: Int { component(.month) }
	public var weeks: Int { component(.week) }
	public var days: Int { component(.day) }
	public var hours: Int { component(.hour) }
	public var minutes: Int { component(.minute) }
	public var seconds: Int { component(.second) }
	public var nanoseconds: Int { component(.nanosecond) }

	public subscript(_ component: Calendar.Component, calendar: Calendar = .default) -> Int {
		self.component(component, calendar: calendar)
	}

	public var interval: TimeInterval {
		switch self {
		case let .dates(from, to):
			return to.timeIntervalSince(from)
		case let .interval(interval):
			return interval
		case let .components(dict):
			return dict.reduce(0) { $0 + TimeInterval($1.value) * $1.key.inSeconds }
		}
	}

	public func dateComponents(calendar: Calendar = .default) -> DateComponents {
		DateComponents(
			rawValue: Dictionary(
				Calendar.Component.allCases.map {
					($0, component($0, calendar: calendar))
				},
				uniquingKeysWith: { _, p in p }
			)
		)
	}

	public func component(_ component: Calendar.Component, calendar: Calendar = .default) -> Int {
		switch self {
		case let .interval(seconds):
			return Int(Calendar.Component.second.as(component) * seconds)
		case let .dates(from, to):
			return to.interval(of: component, from: from, calendar: calendar)
		case let .components(dict):
			return Int(dict.reduce(0) { $0 + Double($1.value) * $1.key.as(component) })
		}
	}

	public init(dictionaryLiteral elements: (Calendar.Component, Int)...) {
		let dict = Dictionary(elements, uniquingKeysWith: { _, s in s })
		self = .components(dict)
	}

	public init(components: DateComponents) {
		self = .components(components.rawValue)
	}

	public static var era: DateDifference { .eras(1) }
	public static var year: DateDifference { .years(1) }
	public static var quarter: DateDifference { .quarters(1) }
	public static var month: DateDifference { .months(1) }
	public static var week: DateDifference { .weeks(1) }
	public static var day: DateDifference { .days(1) }
	public static var hour: DateDifference { .hours(1) }
	public static var minute: DateDifference { .minutes(1) }
	public static var second: DateDifference { .seconds(1) }
	public static var nanosecond: DateDifference { .nanoseconds(1) }

	public static func eras(_ value: Int) -> DateDifference { [.era: value] }
	public static func years(_ value: Int) -> DateDifference { [.year: value] }
	public static func quarters(_ value: Int) -> DateDifference { [.quarter: value] }
	public static func months(_ value: Int) -> DateDifference { [.month: value] }
	public static func weeks(_ value: Int) -> DateDifference { [.week: value] }
	public static func days(_ value: Int) -> DateDifference { [.day: value] }
	public static func hours(_ value: Int) -> DateDifference { [.hour: value] }
	public static func minutes(_ value: Int) -> DateDifference { [.minute: value] }
	public static func seconds(_ value: Int) -> DateDifference { [.second: value] }
	public static func nanoseconds(_ value: Int) -> DateDifference { [.nanosecond: value] }

	public static func + (_ lhs: DateDifference, _ rhs: DateDifference) -> DateDifference {
		operation(lhs, rhs, +, +)
	}

	public static func += (_ lhs: inout DateDifference, _ rhs: DateDifference) {
		lhs = lhs + rhs
	}

	public static func - (_ lhs: DateDifference, _ rhs: DateDifference) -> DateDifference {
		operation(lhs, rhs, -, -)
	}

	public static func -= (_ lhs: inout DateDifference, _ rhs: DateDifference) {
		lhs = lhs - rhs
	}

	public static func / (_ lhs: DateDifference, _ rhs: Int) -> DateDifference {
		operation(lhs, rhs, /, /)
	}

	public static func /= (_ lhs: inout DateDifference, _ rhs: Int) {
		lhs = lhs / rhs
	}

	public static func * (_ lhs: DateDifference, _ rhs: Int) -> DateDifference {
		operation(lhs, rhs, *, *)
	}

	public static func * (_ lhs: Int, _ rhs: DateDifference) -> DateDifference {
		rhs * lhs
	}

	public static func *= (_ lhs: inout DateDifference, _ rhs: Int) {
		lhs = lhs * rhs
	}

	public static func < (lhs: DateDifference, rhs: DateDifference) -> Bool {
		compare(lhs: lhs, rhs: rhs, operation: <)
	}

	public static func == (lhs: DateDifference, rhs: DateDifference) -> Bool {
		compare(lhs: lhs, rhs: rhs, operation: ==)
	}

	private static func compare(lhs: DateDifference, rhs: DateDifference, operation: (TimeInterval, TimeInterval) -> Bool) -> Bool {
		switch (lhs, rhs) {
		case (.dates, .dates):
			return operation(lhs.interval, rhs.interval)
		case let (.dates(from, to), _):
			return operation(to.timeIntervalSince(from), from.adding(rhs).timeIntervalSince(from))
		case let (_, .dates(from, to)):
			return operation(from.adding(lhs).timeIntervalSince(from), to.timeIntervalSince(from))
		default:
			return operation(lhs.interval, rhs.interval)
		}
	}

	fileprivate static func operation(_ lhs: DateDifference, _ rhs: DateDifference, _ block1: (TimeInterval, TimeInterval) -> TimeInterval, _ block2: (Int, Int) -> Int) -> DateDifference {
		switch (lhs, rhs) {
		case let (.components(left), .components(right)):
			var result = left
			right.forEach {
				result[$0.key] = block2(result[$0.key] ?? 0, $0.value)
			}
			return .components(result)
		case let (.interval(left), .interval(right)):
			return .interval(block1(left, right))
		case let (.dates(from, to), .interval(interval)):
			return .dates(from: from, to: from.addingTimeInterval(block1(to.timeIntervalSince(from), interval)))
		case let (.interval(interval), .dates(from, to)):
			return .dates(from: from, to: from.addingTimeInterval(block1(interval, to.timeIntervalSince(from))))
		default:
			return operation(.interval(lhs.interval), .interval(rhs.interval), block1, block2)
		}
	}

	fileprivate static func operation(_ lhs: DateDifference, _ rhs: Int, _ block1: (TimeInterval, TimeInterval) -> TimeInterval, _ block2: (Int, Int) -> Int) -> DateDifference {
		switch lhs {
		case let .interval(interval):
			return .interval(block1(interval, TimeInterval(rhs)))
		case let .dates(from, to):
			return .dates(from: from, to: from.addingTimeInterval(block1(to.timeIntervalSince(from), TimeInterval(rhs))))
		case let .components(lhs):
			return .components(lhs.mapValues { block2($0, rhs) })
		}
	}

	fileprivate static func operation(_ operation: (Int, Int) -> Int, _ lhs: DateDifference, _ rhs: Int, at keyPath: KeyPath<DateDifference, Int>) -> Int {
		operation(lhs[keyPath: keyPath], rhs)
	}

	fileprivate static func operation(_ operation: (Int, Int) -> Int, _ lhs: DateDifference, _ rhs: DateDifference, at keyPath: KeyPath<DateDifference, Int>) -> Int {
		operation(lhs[keyPath: keyPath], rhs[keyPath: keyPath])
	}
}

public extension BinaryInteger {

	var eras: DateDifference { .eras(Int(self)) }
	var years: DateDifference { .years(Int(self)) }
	var quarters: DateDifference { .quarters(Int(self)) }
	var months: DateDifference { .months(Int(self)) }
	var weeks: DateDifference { .weeks(Int(self)) }
	var days: DateDifference { .days(Int(self)) }
	var hours: DateDifference { .hours(Int(self)) }
	var minutes: DateDifference { .minutes(Int(self)) }
	var seconds: DateDifference { .seconds(Int(self)) }
	var nanoseconds: DateDifference { .nanoseconds(Int(self)) }
}

public prefix func - (_ rhs: DateDifference) -> DateDifference {
	-1 * rhs
}

public func + (_ lhs: Date, _ rhs: DateDifference) -> Date {
	lhs.adding(rhs)
}

public func - (_ lhs: Date, _ rhs: DateDifference) -> Date {
	lhs.adding(-rhs)
}

public func += (_ lhs: inout Date, _ rhs: DateDifference) {
	lhs = lhs + rhs
}

public func -= (_ lhs: inout Date, _ rhs: DateDifference) {
	lhs = lhs - rhs
}

@available(iOS 10.0, macOS 10.12, *)
public extension DateInterval {

	var difference: DateDifference {
		end - start
	}
}
