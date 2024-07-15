import Foundation

public extension Locale {

	/// Default Locale for all helper methods, can be overridden
    /// - Note: This value is not thread-safe
    static var `default`: Locale {
        get { _default() }
        @available(*, deprecated, renamed: "Locale.bootstrap")
        set { Locale.bootstrap(default: newValue) }
    }

    /// Sets the default Locale for all helper methods
    /// - Parameter locale: The default Locale
    /// - Example:
    /// ```swift
    /// public extension Locale {
    ///   @TaskLocal static var taskLocalDefault: Locale = .autoupdatingCurrent
    /// }
    ///
    /// Locale.bootstrap {
    ///    Locale.taskLocalDefault
    /// }
    /// ```
    /// - Note: This method is not thread-safe
    static func bootstrap(default locale: @escaping () -> Locale) {
        _default = locale
    }

    /// Sets the default Locale for all helper methods
    /// - Parameter locale: The default Locale
    /// - Example:
    /// ```swift
    /// public extension Locale {
    ///   @TaskLocal static var taskLocalDefault: Locale = .autoupdatingCurrent
    /// }
    ///
    /// Locale.bootstrap(default: .taskLocalDefault)
    /// ```
    /// - Note: This value is not thread-safe
    static func bootstrap(default locale: @escaping @autoclosure () -> Locale) {
        bootstrap(default: locale)
    }
}

private extension Locale {

    static var _default: () -> Locale = { .autoupdatingCurrent }
}
