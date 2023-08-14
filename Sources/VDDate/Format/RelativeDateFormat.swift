import Foundation

public struct RelativeDateFormat<Format> {

	public let defaultFormat: Format
	private var relativeFormats: [DateComponents: Format]

	private init(
		defaultFormat: Format
	) {
		self.defaultFormat = defaultFormat
		relativeFormats = [:]
	}

	private func _at(_ components: DateComponents, _ format: Format) -> RelativeDateFormat {
		var new = self
		new.relativeFormats[components] = format
		return new
	}

	public var isEmpty: Bool {
		relativeFormats.isEmpty
	}

	public func format(from start: Date, to end: Date, calendar: Calendar = .default) -> Format {
		guard !isEmpty else { return defaultFormat }
		let difference = end.numbers(of: Set(relativeFormats.flatMap(\.key.rawValue.keys)), from: start, calendar: calendar)
		return format(difference: difference)
	}

	public func format(difference: DateComponents) -> Format {
		for (comp, format) in relativeFormats.sorted(by: { $0.key.minComponent() < $1.key.minComponent() }) {
			if difference.contains(comp) {
				return format
			}
		}
		return defaultFormat
	}
}

public typealias RelativeDateFormatStyle = RelativeDateFormat<AnyDateFormatStyle>

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension RelativeDateFormatStyle {

	init<S: FormatStyle>(_ format: S) where S.FormatInput == Date, S.FormatOutput == String {
		self.init(defaultFormat: AnyDateFormatStyle(format))
	}

	func at<S: FormatStyle>(_ components: DateComponents, _ format: S) -> RelativeDateFormat where S.FormatInput == Date, S.FormatOutput == String {
		_at(components, AnyDateFormatStyle(format))
	}
}

public extension RelativeDateFormat<DateFormat> {

	init(
		_ defaultFormat: DateFormat
	) {
		self.init(defaultFormat: defaultFormat)
	}

	func at(_ components: DateComponents, _ format: DateFormat) -> RelativeDateFormat {
		_at(components, format)
	}
}

extension RelativeDateFormat: Equatable where Format: Equatable {}
extension RelativeDateFormat: Hashable where Format: Hashable {}
extension RelativeDateFormat: Encodable where Format: Encodable {}
extension RelativeDateFormat: Decodable where Format: Decodable {}
