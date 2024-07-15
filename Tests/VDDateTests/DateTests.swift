import Foundation
@testable import VDDate
import XCTest

final class DateTests: XCTestCase {

	private let gmt = TimeZone(identifier: "GMT")!
	private let calendar: Calendar = {
		var result = Calendar(identifier: .gregorian)
		result.timeZone = TimeZone(identifier: "GMT")!
		return result
	}()

	func testInitWithParameters() {
		Calendar.default = calendar
		let targetDate = Date(timeIntervalSince1970: 1_691_843_633)
		let testableDate = Date(
			year: 2023,
			month: 8,
			day: 12,
			hour: 12,
			minute: 33,
			second: 53,
			timeZone: gmt
		)
		XCTAssertEqual(targetDate, testableDate)
	}

	func testInitWithComponents() {
		Calendar.default = calendar
		let targetDate = Date(timeIntervalSince1970: 1_691_843_633)
		var components = DateComponents()
		components.year = 2023
		components.month = 8
		components.day = 12
		components.hour = 12
		components.minute = 33
		components.second = 53
		components.timeZone = gmt
		let testableDate = Date(components: components)
		XCTAssertEqual(targetDate, testableDate)
	}

	func testInitFromString() {
		Calendar.default = calendar
		let targetDate = Date(timeIntervalSince1970: 1_691_843_633)
		let testableDate = Date(from: "2023-08-12 12:33:53", format: "yyyy-MM-dd HH:mm:ss", timeZone: gmt)
		XCTAssertEqual(targetDate, testableDate)
	}

	func testIsToday() {
		Calendar.default = calendar
		let testableDate1 = Date()
		XCTAssertTrue(testableDate1.isToday)

		let testableDate2 = Date(timeIntervalSince1970: 16_918_436)
		XCTAssertFalse(testableDate2.isToday)
	}

	func testIsYesterday() {
		Calendar.default = calendar
		let testableDate1 = Date(timeIntervalSinceNow: -86400)

		XCTAssertTrue(testableDate1.isYesterday)

		let testableDate2 = Date()
		XCTAssertFalse(testableDate2.isYesterday)
	}

	func testIsTomorrow() {
		Calendar.default = calendar
		let testableDate1 = Date(timeIntervalSinceNow: 86400)

		XCTAssertTrue(testableDate1.isTomorrow)

		let testableDate2 = Date()
		XCTAssertFalse(testableDate2.isTomorrow)
	}

	func testISO8601() {
		Calendar.default = calendar
		let testableDate = Date(timeIntervalSince1970: 1_691_843_633)
		let testableString = testableDate.iso8601
		XCTAssertEqual(testableString, "2023-08-12T12:33:53.000Z")
	}

	func testComponents() {
		Calendar.default = calendar
		let testableDate = Date(timeIntervalSince1970: 1_691_843_633)
		let testableComponents = testableDate.components
		XCTAssertEqual(testableComponents.year, 2023)
		XCTAssertEqual(testableComponents.month, 8)
		XCTAssertEqual(testableComponents.day, 12)
		XCTAssertEqual(testableComponents.hour, 12)
		XCTAssertEqual(testableComponents.minute, 33)
		XCTAssertEqual(testableComponents.second, 53)
		XCTAssertEqual(testableComponents.timeZone, gmt)
	}

	func testComponentSubscript() {
		Calendar.default = calendar
		var testableDate = Date(timeIntervalSince1970: 1_691_843_633)

		XCTAssertEqual(testableDate[.year], 2023)
		XCTAssertEqual(testableDate[.month], 8)
		XCTAssertEqual(testableDate[.day], 12)
		XCTAssertEqual(testableDate[.hour], 12)
		XCTAssertEqual(testableDate[.minute], 33)
		XCTAssertEqual(testableDate[.second], 53)

		testableDate[.year] = 2024
		XCTAssertEqual(testableDate, Date(timeIntervalSince1970: 1_723_466_033))
		testableDate[.month] = 9
		XCTAssertEqual(testableDate, Date(timeIntervalSince1970: 1_726_144_433))
		testableDate[.day] = 13
		XCTAssertEqual(testableDate, Date(timeIntervalSince1970: 1_726_230_833))
		testableDate[.hour] = 13
		XCTAssertEqual(testableDate, Date(timeIntervalSince1970: 1_726_234_433))
		testableDate[.minute] = 34
		XCTAssertEqual(testableDate, Date(timeIntervalSince1970: 1_726_234_493))
		testableDate[.second] = 54
		XCTAssertEqual(testableDate, Date(timeIntervalSince1970: 1_726_234_494))
	}

	func testComponentVariables() {
		Calendar.default = calendar
		var testableDate = Date(timeIntervalSince1970: 1_691_843_633)

		XCTAssertEqual(testableDate.year, 2023)
		XCTAssertEqual(testableDate.month, 8)
		XCTAssertEqual(testableDate.day, 12)
		XCTAssertEqual(testableDate.hour, 12)
		XCTAssertEqual(testableDate.minute, 33)
		XCTAssertEqual(testableDate.second, 53)

		testableDate.year = 2024
		XCTAssertEqual(testableDate, Date(timeIntervalSince1970: 1_723_466_033))
		testableDate.month = 9
		XCTAssertEqual(testableDate, Date(timeIntervalSince1970: 1_726_144_433))
		testableDate.day = 13
		XCTAssertEqual(testableDate, Date(timeIntervalSince1970: 1_726_230_833))
		testableDate.hour = 13
		XCTAssertEqual(testableDate, Date(timeIntervalSince1970: 1_726_234_433))
		testableDate.minute = 34
		XCTAssertEqual(testableDate, Date(timeIntervalSince1970: 1_726_234_493))
		testableDate.second = 54
		XCTAssertEqual(testableDate, Date(timeIntervalSince1970: 1_726_234_494))
	}

	func testStartOfComponent() {
		Calendar.default = calendar
		let testableDate = Date(timeIntervalSince1970: 1_691_843_633)

		XCTAssertEqual(testableDate.start(of: .second), Date(timeIntervalSince1970: 1_691_843_633))
		XCTAssertEqual(testableDate.start(of: .minute), Date(timeIntervalSince1970: 1_691_843_580))
		XCTAssertEqual(testableDate.start(of: .hour), Date(timeIntervalSince1970: 1_691_841_600))
		XCTAssertEqual(testableDate.start(of: .day), Date(timeIntervalSince1970: 1_691_798_400))
		XCTAssertEqual(testableDate.start(of: .week), Date(timeIntervalSince1970: 1_691_280_000))
		XCTAssertEqual(testableDate.start(of: .month), Date(timeIntervalSince1970: 1_690_848_000))
		XCTAssertEqual(testableDate.start(of: .year), Date(timeIntervalSince1970: 1_672_531_200))
	}

	func testEndOfComponent() {
		Calendar.default = calendar
		let testableDate = Date(timeIntervalSince1970: 1_691_843_633)

		XCTAssertEqual(testableDate.end(of: .second), Date(timeIntervalSince1970: 1_691_843_633))
		XCTAssertEqual(testableDate.end(of: .minute), Date(timeIntervalSince1970: 1_691_843_639))
		XCTAssertEqual(testableDate.end(of: .hour), Date(timeIntervalSince1970: 1_691_845_140))
		XCTAssertEqual(testableDate.end(of: .day), Date(timeIntervalSince1970: 1_691_881_200))
		XCTAssertEqual(testableDate.end(of: .week), Date(timeIntervalSince1970: 1_691_798_400))
		XCTAssertEqual(testableDate.end(of: .month), Date(timeIntervalSince1970: 1_693_440_000))
		XCTAssertEqual(testableDate.end(of: .year), Date(timeIntervalSince1970: 1_701_388_800))

		XCTAssertEqual(testableDate.end(of: .year, toGranularity: .day), Date(timeIntervalSince1970: 1_703_980_800))
	}

	func testMatches() {
		Calendar.default = calendar
		let testableDate = Date(timeIntervalSince1970: 1_691_843_633)
		XCTAssertTrue(testableDate.matches(DateComponents(year: 2023, month: 8)))
		XCTAssertTrue(testableDate.matches(DateComponents(day: 12, hour: 12)))
		XCTAssertFalse(testableDate.matches(DateComponents(hour: 15)))
	}

	func testIsInSame() {
		Calendar.default = calendar
		let testableDate = Date(timeIntervalSince1970: 1_691_843_633)
		XCTAssertTrue(testableDate.isInSame(.year, as: Date(timeIntervalSince1970: 1_691_843_633)))
		XCTAssertTrue(testableDate.isInSame(.day, as: Date(timeIntervalSince1970: 1_691_798_400)))
		XCTAssertTrue(testableDate.isInSame(.month, as: Date(timeIntervalSince1970: 1_692_144_000)))
		XCTAssertTrue(testableDate.isInSame(.week, as: Date(timeIntervalSince1970: 1_691_625_600)))
		XCTAssertFalse(testableDate.isInSame(.year, as: Date(timeIntervalSince1970: 1_723_248_000)))
		XCTAssertFalse(testableDate.isInSame(.month, as: Date(timeIntervalSince1970: 1_723_248_000)))
		XCTAssertFalse(testableDate.isInSame(.day, as: Date(timeIntervalSince1970: 1_723_420_800)))
		XCTAssertFalse(testableDate.isInSame(.week, as: Date(timeIntervalSince1970: 1_692_144_000)))
	}

	func testIsEaual() {
		Calendar.default = calendar
		let testableDate = Date(timeIntervalSince1970: 1_691_843_633)
		XCTAssertTrue(testableDate.isEqual(to: Date(timeIntervalSince1970: 1_691_849_513), toGranularity: .day))
		XCTAssertTrue(testableDate.isEqual(to: Date(timeIntervalSince1970: 1_691_841_713), toGranularity: .hour))
		XCTAssertFalse(testableDate.isEqual(to: Date(timeIntervalSince1970: 1_691_841_713), toGranularity: .minute))
	}

	func testNumberOfComponentFrom() {
		Calendar.default = calendar
		let testableDate = Date(timeIntervalSince1970: 1_691_843_633)
		XCTAssertEqual(testableDate.number(of: .second, from: testableDate), 0)
		XCTAssertEqual(testableDate.number(of: .day, from: Date(timeIntervalSince1970: 1_691_793_233)), 1)
		XCTAssertEqual(testableDate.number(of: .month, from: Date(timeIntervalSince1970: 1_691_793_233)), 0)
		XCTAssertEqual(testableDate.number(of: .day, from: Date(timeIntervalSince1970: 1_690_929_233)), 11)
		XCTAssertEqual(testableDate.number(of: .day, from: Date(timeIntervalSince1970: 1_692_830_033)), -11)
		XCTAssertEqual(testableDate.number(of: .week, from: Date(timeIntervalSince1970: 1_691_015_633)), 1)
	}

	func testRangeOfComponentIn() {
		Calendar.default = calendar
		let testableDate = Date(timeIntervalSince1970: 1_691_843_633)
		XCTAssertEqual(testableDate.range(of: .second, in: .hour), 0 ..< 60)
		XCTAssertEqual(testableDate.range(of: .day, in: .month), 1 ..< 32)
		XCTAssertEqual(testableDate.range(of: .week, in: .month), 31 ..< 36)
	}

	func testNumberOfComponent() {
		Calendar.default = calendar
		let testableDate = Date(timeIntervalSince1970: 1_691_843_633)
		XCTAssertEqual(testableDate.number(of: .second), 60)
		XCTAssertEqual(testableDate.number(of: .day), 31)
		XCTAssertEqual(testableDate.number(of: .weekOfMonth), 5)
	}

	func testNumberOfComponentIn() {
		Calendar.default = calendar
		let testableDate = Date(timeIntervalSince1970: 1_691_843_633)
		XCTAssertEqual(testableDate.number(of: .second, in: .hour), 3600)
		XCTAssertEqual(testableDate.number(of: .day, in: .month), 31)
		XCTAssertEqual(testableDate.number(of: .week, in: .month), 4)
	}

	func testString() {
		Calendar.default = calendar
		Locale.default = Locale(identifier: "en_US")
		TimeZone.default = gmt
		let testableDate = Date(timeIntervalSince1970: 1_691_843_633)
		XCTAssertEqual(testableDate.string(date: .short, time: .short, locale: Locale(identifier: "ru_RU")), "12.08.2023, 12:33")
	}

	func testStringRelative() {
		Calendar.default = calendar
		TimeZone.default = gmt
		Locale.default = Locale(identifier: "en_US")
		let testableDate = Date(timeIntervalSince1970: 1_691_843_633)
		let format = RelativeDateFormat<DateFormat>("dd.MM.yyyy")
			.at(.day(-1), "'Yesterday'")
			.at(.day(0), "'Today'")
			.at(.day(1), "'Tomorrow'")
			.at(.week(0), [.weekday])
			.at(.year(0), "dd.MM")

		XCTAssertEqual(
			testableDate.string(format: format, relativeTo: testableDate),
			"Today"
		)
		XCTAssertEqual(
			testableDate.string(format: format, relativeTo: Date(timeIntervalSince1970: 1_691_793_233)),
			"Tomorrow"
		)
		XCTAssertEqual(
			testableDate.string(format: format, relativeTo: Date(timeIntervalSince1970: 1_691_966_033)),
			"Yesterday"
		)
		XCTAssertEqual(
			testableDate.string(format: format, relativeTo: Date(timeIntervalSince1970: 1_691_698_660)),
			"Saturday"
		)
		XCTAssertEqual(
			testableDate.string(format: format, relativeTo: Date(timeIntervalSince1970: 1_688_769_233)),
			"12.08"
		)
		XCTAssertEqual(
			testableDate.string(format: format, relativeTo: Date(timeIntervalSince1970: 1_625_697_233)),
			"12.08.2023"
		)
	}

	func testNameOfComponent() {
		Calendar.default = calendar
		Locale.default = Locale(identifier: "en_US")
		TimeZone.default = gmt
		let testableDate = Date(timeIntervalSince1970: 1_691_843_633)
		XCTAssertEqual(testableDate.name(of: .month), "August")
		XCTAssertEqual(testableDate.name(of: .weekday), "Saturday")
	}

	func testOrdinality() {
		Calendar.default = calendar
		let testableDate = Date(timeIntervalSince1970: 1_691_843_633)
		XCTAssertEqual(testableDate.ordinality(of: .day, in: .week), 7)
	}

	func testComponentsFromDate() {
		Calendar.default = calendar
		TimeZone.default = gmt
		let testableDate = Date(timeIntervalSince1970: 1_691_843_633)

		let date1 = Date(timeIntervalSince1970: 1_691_757_233)
		XCTAssertEqual(date1.adding(testableDate.components(from: date1)), testableDate)
		let date2 = Date(timeIntervalSince1970: 1_691_757_233)
		XCTAssertEqual(date2.adding(testableDate.components(from: date2)), testableDate)
		let date3 = Date(timeIntervalSince1970: 1_723_379_632)
		XCTAssertEqual(testableDate.adding(date3.components(from: testableDate)), date3)
	}

	func testSubtract() {
		Calendar.default = calendar
		let date1 = Date(timeIntervalSince1970: 1_691_843_633)
		let date2 = Date(timeIntervalSince1970: 1_723_379_632)
		XCTAssertEqual(date2 - date1, 31_535_999.0)
	}

	func testAdd() {
		Calendar.default = calendar
		let testableDate = Date(timeIntervalSince1970: 1_691_843_633)
		XCTAssertEqual(testableDate.adding([.day: -1, .second: -1, .year: 1]), Date(timeIntervalSince1970: 1_723_379_632))
	}

	func testSetting() {
		Calendar.default = calendar
		var testableDate: Date? = Date(timeIntervalSince1970: 1_691_843_633)

		testableDate = testableDate?.setting(.year, 2024)
		XCTAssertEqual(testableDate, Date(timeIntervalSince1970: 1_723_466_033))
		testableDate = testableDate?.setting(.month, 9)
		XCTAssertEqual(testableDate, Date(timeIntervalSince1970: 1_726_144_433))
		testableDate = testableDate?.setting(.day, 13)
		XCTAssertEqual(testableDate, Date(timeIntervalSince1970: 1_726_230_833))
		testableDate = testableDate?.setting(.hour, 13)
		XCTAssertEqual(testableDate, Date(timeIntervalSince1970: 1_726_234_433))
		testableDate = testableDate?.setting(.minute, 34)
		XCTAssertEqual(testableDate, Date(timeIntervalSince1970: 1_726_234_493))
		testableDate = testableDate?.setting(.second, 54)
		XCTAssertEqual(testableDate, Date(timeIntervalSince1970: 1_726_234_494))
	}

	func testCompare() {
		Calendar.default = calendar
		let testableDate = Date(timeIntervalSince1970: 1_691_843_633)
		XCTAssertEqual(testableDate.compare(Date(timeIntervalSince1970: 1_691_843_633)), .orderedSame)
		XCTAssertEqual(testableDate.compare(Date(timeIntervalSince1970: 1_691_843_634)), .orderedAscending)
		XCTAssertEqual(testableDate.compare(Date(timeIntervalSince1970: 1_691_843_632)), .orderedDescending)
	}

	func testNextWeekend() {
		Calendar.default = calendar
		let testableDate = Date(timeIntervalSince1970: 1_691_843_633)
		let interval = DateInterval(start: Date(timeIntervalSince1970: 1_692_403_200), end: Date(timeIntervalSince1970: 1_692_576_000))
		XCTAssertEqual(testableDate.nextWeekend(), interval)
	}

	func testNextComponent() {
		Calendar.default = calendar
		let testableDate = Date(timeIntervalSince1970: 1_691_843_633)
		XCTAssertEqual(testableDate.next(.day), Date(timeIntervalSince1970: 1_691_884_800))
		XCTAssertEqual(testableDate.next(.month), Date(timeIntervalSince1970: 1_693_526_400))
		XCTAssertEqual(testableDate.next(.year), Date(timeIntervalSince1970: 1_704_067_200))
	}

	func testNearestComponents() {
		Calendar.default = calendar
		let testableDate = Date(timeIntervalSince1970: 1_691_843_633)
		XCTAssertEqual(testableDate.nearest([.weekday: 2]), Date(timeIntervalSince1970: 1_691_971_200))
	}

	func testRoundedComponentByValue() {
		Calendar.default = calendar
		let testableDate = Date(timeIntervalSince1970: 1_691_843_633)
		XCTAssertEqual(testableDate.rounded(.hour, by: 2), Date(timeIntervalSince1970: 1_691_841_600))
		XCTAssertEqual(testableDate.rounded(.day, by: 2), Date(timeIntervalSince1970: 1_691_798_400))
	}

	func testRoundedComponentByValueFromDate() {
		Calendar.default = calendar
		let testableDate = Date(timeIntervalSince1970: 1_691_843_633)
		XCTAssertEqual(
			testableDate.rounded(.hour, by: 2, from: Date(timeIntervalSince1970: 1_691_838_000)),
			Date(timeIntervalSince1970: 1_691_845_200)
		)
	}
}
