# VDDate 📆

VDDate is a Swift library that offers a robust set of extensions for the Date struct, enhancing its capabilities and making date manipulation in Swift more intuitive and powerful.

## Features
### Date
- Convenience `Date.init`s with components parameters year, month, day etc.
- Convenience `Date.init`s from string with format.
- Helper vars: `iToday`, `isTomorrow`, `isYesterday`, `iso8601`.
- var `components`, var for each component: `day`, `month`, `year` etc, mutating subscript with `Calendar.Component`.
- `start(of: Calendar.Component) -> Date`.
- `end(of: Calendar.Component) -> Date`.
- `matches(DateComponents) -> Bool`.
- `isInSame(Calendar.Component) -> Bool`.
- `isCurrent(Calendar.Component) -> Bool`
- `isEqual(to: Date, toGranularity: Calendar.Component) -> Bool`.
- `number(of: Calendar.Component, from: Date) -> Int`
- `numbers(of components: Set<Calendar.Component>, from: Date) -> DateComponents`
- `components(_ components: Set<Calendar.Component>, from: Date) -> DateComponents`
- `range(of: Calendar.Component, in: Calendar.Component) -> Range<Int>` - range of component, for example `range(of: .day, in: .month)` returns smth like `1..<32`.
- `interval(byAdding: DateComponents) -> DateInterval`
- `interval(of: Calendar.Component, in: Calendar.Component) -> DateInterval`
- `number(of: Calendar.Component) -> Int`
- `number(of: Calendar.Component, in: Calendar.Component) -> Int`
- `DateFormat` struct with predefined format components.
- `string(DateFormat) -> String` Note: Deprecated since iOS 15.0 in favor of `formatted(FormatStyle)`.
- `string(date: DateFormatter.Style, time: DateFormatter.Style) -> String` Note: Deprecated since iOS 15.0 in favor of `formatted(FormatStyle)`.
- `string(format: RelativeDateFormat<DateFormat>)` - method for converting formatting date relative to current (or any other) date, example:
```swift
date.string(
  RelativeDateFormat(.iso8601)
    .at(.day(-1), "'Yesterday'")
    .at(.day(0), "'Today'")
    .at(.week(0), [.weekday])
    .at(.year(0), "dd.MM")
)
```
Note: Deprecated since iOS 15.0 in favor of `formatted(RelativeDateFormatStyle)`
- `formatted(RelativeDateFormatStyle)`
- `name(of: Calendar.Component) -> String`
- `ordinality(of: Calendar.Component, in: Calendar.Component) -> Int?` and convenience methods for each component like `day(in: Calendar.Component)`.
- Minus operator for date returns TimeInterval.
- `adding(DateComponents) -> Date`
- `adding(Int, Calendar.Component) -> Date`
- `setting(DateComponents) -> Date`
- `setting(Int, Calendar.Component) -> Date`
- `compare(with: Date, toGranularity: Calendar.Component) -> ComparasionResult`
- `nextWeekend(direction: Calendar.SearchDirection) -> DateInterval?`
- `next(Calendar.Component, direction: Calendar.SearchDirection) -> Date`
- `nearest(DateComponents) -> Date?`
- `rounded(Calendar.Component, by: Int) -> Date` date rounded by some component, useful when you deal with regular time intervals.
#### Note
All methods accept a `Calendar` parameter and, in some cases, `TimeZone` or `Locale`.\
I've introduced static variables: `Calendar.default`, `TimeZone.default`, and `Locale.default`.\
These variables serve as the default values for each respective method. You can modify each `default` variable either globally or specifically for a given method.
### TimeInterval
- `DatesCollection` struct and function `each(Int, Calendar.Component) -> DatesCollection`.
### DateComponents
- Arithmetic operators: +, - between `DateComponents`, +, -, /, * between `DateComponents` and `Int`, +, - between `DateComponents` and `Date`.
- Convenience static methods for each component like `.day(3)`.
- Extensions on `BinaryInteger` like `2.days`, so now it possible to write `date + 2.days`.
- `DateComponents` now is expressible by dictionary literal like `[.day: 2, .month: 1]`
- mutating subscript  with `Calendar.Components`.
- `rawValue: [Calendar.Component: Int]` - dictionary with components.

## Installation

1. [Swift Package Manager](https://github.com/apple/swift-package-manager)

Create a `Package.swift` file.
```swift
// swift-tools-version:5.7
import PackageDescription

let package = Package(
  name: "SomeProject",
  dependencies: [
    .package(url: "https://github.com/dankinsoid/VDDate.git", from: "0.9.0")
  ],
  targets: [
    .target(name: "SomeProject", dependencies: ["VDDate"])
  ]
)
```
```ruby
$ swift build
```

## Author

dankinsoid, voidilov@gmail.com

## License

VDDate is available under the MIT license. See the LICENSE file for more info.
