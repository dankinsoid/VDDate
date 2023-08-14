import Foundation

public struct AnyDateFormatStyle {

	private let _format: (Date) -> String

	public init(_ format: @escaping (Date) -> String) {
		_format = format
	}

	public func format(_ date: Date) -> String {
		_format(date)
	}
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension AnyDateFormatStyle {

	init<S: FormatStyle>(_ style: S) where S.FormatInput == Date, S.FormatOutput == String {
		self.init(style.format)
	}
}
