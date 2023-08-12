import Foundation

/// Weekdays enum
public enum Weekdays: Int, CustomStringConvertible {

	case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday

	public var description: String {
		switch self {
		case .sunday: return "sunday"
		case .monday: return "monday"
		case .tuesday: return "tuesday"
		case .wednesday: return "wednesday"
		case .thursday: return "thursday"
		case .friday: return "friday"
		case .saturday: return "saturday"
		}
	}
}
