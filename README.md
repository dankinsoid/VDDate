# VDDate

[![CI Status](https://img.shields.io/travis/dankinsoid/VDDate.svg?style=flat)](https://travis-ci.org/dankinsoid/VDDate)
[![Version](https://img.shields.io/cocoapods/v/VDDate.svg?style=flat)](https://cocoapods.org/pods/VDDate)
[![License](https://img.shields.io/cocoapods/l/VDDate.svg?style=flat)](https://cocoapods.org/pods/VDDate)
[![Platform](https://img.shields.io/cocoapods/p/VDDate.svg?style=flat)](https://cocoapods.org/pods/VDDate)


## Description
This repository provides

## Example

```swift

```
## Usage

 
## Installation

1. [Swift Package Manager](https://github.com/apple/swift-package-manager)

Create a `Package.swift` file.
```swift
// swift-tools-version:5.7
import PackageDescription

let package = Package(
  name: "SomeProject",
  dependencies: [
    .package(url: "https://github.com/dankinsoid/VDDate.git", from: "0.4.0")
  ],
  targets: [
    .target(name: "SomeProject", dependencies: ["VDDate"])
  ]
)
```
```ruby
$ swift build
```

2.  [CocoaPods](https://cocoapods.org)

Add the following line to your Podfile:
```ruby
pod 'VDDate'
```
and run `pod update` from the podfile directory first.

## Author

dankinsoid, voidilov@gmail.com

## License

VDDate is available under the MIT license. See the LICENSE file for more info.
