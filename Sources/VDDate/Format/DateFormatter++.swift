import Foundation

public extension DateFormatter {

	convenience init(_ format: String) {
		self.init()
		dateFormat = format
		locale = .default
	}
}
