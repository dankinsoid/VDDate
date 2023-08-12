import Foundation

public struct RelativeDateFormat: Hashable, Codable {

	public var defaultFormat: DateFormat
	public var relativeFormats: [DateComponents: DateFormat]

	public init(
		_ defaultFormat: DateFormat,
		relative: [DateComponents: DateFormat]
	) {
		self.defaultFormat = defaultFormat
		relativeFormats = relative
	}
}
