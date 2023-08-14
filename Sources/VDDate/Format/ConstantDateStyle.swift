import Foundation

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public struct ConstantDateStyle: FormatStyle {

	public let value: String

	public init(_ value: String) {
		self.value = value
	}

	public func format(_: Date) -> String {
		value
	}
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension FormatStyle where Self == ConstantDateStyle {

	static func constant(_ value: String) -> ConstantDateStyle {
		ConstantDateStyle(value)
	}
}
