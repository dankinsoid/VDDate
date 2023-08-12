import Foundation

public extension Calendar {

	/// Default Calendar for all helper methods, can be overridden
	static var `default` = Calendar.autoupdatingCurrent

	func current(_ component: Component) -> Int {
		self.component(component, from: Date())
	}

	func name(forWeekday weekday: Int) -> String {
		standaloneWeekdaySymbols[weekday - firstWeekday]
	}
}
