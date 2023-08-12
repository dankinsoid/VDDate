import Foundation

public extension TimeZone {

	/// Default TimeZone for all helper methods, can be overridden
	static var `default` = TimeZone.autoupdatingCurrent
}
