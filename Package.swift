// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "VDDate",
	products: [
		.library(name: "VDDate", targets: ["VDDate"]),
	],
	targets: [
		.target(name: "VDDate"),
		.testTarget(name: "VDDateTests", dependencies: ["VDDate"]),
	]
)
