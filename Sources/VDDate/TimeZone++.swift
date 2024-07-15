import Foundation

public extension TimeZone {

    /// UTC TimeZone
    static var utc: TimeZone {
        TimeZone(secondsFromGMT: 0)!
    }

    /// Default TimeZone for all helper methods, can be overridden
    /// - Note: This value is not thread-safe
    static var `default`: TimeZone {
        get { _default() }
        @available(*, deprecated, renamed: "TimeZone.bootstrap")
        set { TimeZone.bootstrap(default: newValue) }
    }
    
    /// Sets the default TimeZone for all helper methods
    /// - Parameter timeZone: The default TimeZone
    /// - Example:
    /// ```swift
    /// public extension TimeZone {
    ///   @TaskLocal static var taskLocalDefault: TimeZone = .autoupdatingCurrent
    /// }
    ///
    /// TimeZone.bootstrap {
    ///    TimeZone.taskLocalDefault
    /// }
    /// ```
    /// - Note: This method is not thread-safe
    static func bootstrap(default timeZone: @escaping () -> TimeZone) {
        _default = timeZone
    }
    
    /// Sets the default TimeZone for all helper methods
    /// - Parameter timeZone: The default Locale
    /// - Example:
    /// ```swift
    /// public extension TimeZone {
    ///   @TaskLocal static var taskLocalDefault: TimeZone = .autoupdatingCurrent
    /// }
    ///
    /// TimeZone.bootstrap(default: .taskLocalDefault)
    /// ```
    /// - Note: This value is not thread-safe
    static func bootstrap(default timeZone: @escaping @autoclosure () -> TimeZone) {
        bootstrap(default: timeZone)
    }
}

private extension TimeZone {
    
    static var _default: () -> TimeZone = { .autoupdatingCurrent }
}
