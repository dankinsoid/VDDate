import Foundation

public struct DatesCollection: Collection, RandomAccessCollection {

	public var array: [Date] { Array(self) }
	public var startIndex: Int { 0 }
	public var endIndex: Int { count }
	public var start: Date
	public var count: Int
	public var component: Calendar.Component
	public var step: Int
	public var calendar: Calendar = .default

	public init(from date: Date, count: Int, component: Calendar.Component, step: Int, calendar: Calendar = .default) {
		start = date
		self.component = component
		self.step = step
		self.count = count
		self.calendar = calendar
	}

	public subscript(position: Int) -> Date {
		calendar.date(byAdding: component, value: position * step, to: start) ?? start
	}

	public func index(after i: Int) -> Int {
		i + 1
	}

	public func index(_ i: Int, offsetBy distance: Int) -> Int {
		i + distance
	}
}

@available(iOS 10.0, macOS 10.12, *)
public extension DateInterval {

	func each(_ step: Int = 1, _ component: Calendar.Component, calendar: Calendar = .default) -> DatesCollection {
		(start ..< end).each(step, component, calendar: calendar)
	}
}

public extension ClosedRange where Bound == Date {

	func each(_ step: Int = 1, _ component: Calendar.Component, calendar: Calendar = .default) -> DatesCollection {
		let count = upperBound.number(of: component, from: lowerBound) + 1
		return DatesCollection(from: lowerBound, count: count, component: component, step: step, calendar: calendar)
	}
}

public extension Range where Bound == Date {

	func each(_ step: Int = 1, _ component: Calendar.Component, calendar: Calendar = .default) -> DatesCollection {
		let count = upperBound.number(of: component, from: lowerBound)
		return DatesCollection(from: lowerBound, count: count, component: component, step: step, calendar: calendar)
	}
}
