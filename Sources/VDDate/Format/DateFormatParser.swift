import Foundation

final class DateFormatParser {

	private let string: String
	private var index: String.Index

	init(_ string: String) {
		self.string = string
		index = string.startIndex
	}

	func parse() -> [DateFormat.Component] {
		index = string.startIndex
		var array: [DateFormat.Component] = []
		var current = ""
		while index < string.endIndex {
			let char = string[index]
			switch char {
			case "'":
				appendCurrent()
				array.append(parseShield())

			default:
				let char = string[index]
				if DateFormat.Component.characterSet.contains(char) {
					appendCurrent()
					array.append(parse(char: char))
				} else {
					current.append(string[index])
					index = string.index(after: index)
				}
			}
		}
		appendCurrent()

		func appendCurrent() {
			if !current.isEmpty {
				array.append(.string(current))
				current = ""
			}
		}

		return array
	}

	private func parseShield() -> DateFormat.Component {
		var result = ""
		index = string.index(after: index)
		while index < string.endIndex, string[index] != "'" {
			result.append(string[index])
		}
		if index < string.endIndex {
			index = string.index(after: index)
		}
		return .string(result)
	}

	private func parse(char: Character) -> DateFormat.Component {
		var count = 0
		while index < string.endIndex, string[index] == char {
			count += 1
			index = string.index(after: index)
		}
		return .component(char, count)
	}
}
