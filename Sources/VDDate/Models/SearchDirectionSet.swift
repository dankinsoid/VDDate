import Foundation

public extension Calendar.SearchDirection {

	enum Set: UInt8, OptionSet {

		case future = 1, past = 2, both = 3, none = 0

		public init(rawValue: UInt8) {
			switch rawValue % 4 {
			case 0: self = .none
			case 1: self = .future
			case 2: self = .past
			default: self = .both
			}
		}
	}
}
