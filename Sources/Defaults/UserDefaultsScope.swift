// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public protocol UserDefaultsScope {
    static var outer: UserDefaultsScope.Type? { get }

    static var key: String { get }
}

public extension UserDefaultsScope {
    public static var keyPath: String {
        if let outer = Self.outer {
            return "\(outer.keyPath).\(Self.key)"
        } else {
            return Self.key
        }
    }
}

public struct RootScope: UserDefaultsScope {
    public static let outer: UserDefaultsScope.Type? = nil

    public static let key: String = ""
}

public protocol EnumerableUserDefaultsScope: UserDefaultsScope {
    static var inner: [EnumerableUserDefaultsScope.Type] { get }
    static var defaults: [AnyUserDefault] { get }
}

public extension EnumerableUserDefaultsScope {
    public static func factoryDefaults() -> [String : Any] {
        var dictionary: [String : Any] = [:]

        let defaults: [(String, Any)] = self.defaults.compactMap { userDefault in
            guard let value = userDefault.anyDefaultValue() else {
                return nil
            }
            return (key: userDefault.keyPath, value: value)
        }
        dictionary.merge(defaults, uniquingKeysWith: { $1 })

        for scope in self.inner {
            let defaults = scope.factoryDefaults()
            dictionary.merge(defaults, uniquingKeysWith: { $1 })
        }

        return dictionary
    }

    public static func register(on userDefaults: UserDefaults) {
        let dictionary = self.factoryDefaults()
        userDefaults.register(defaults: dictionary)
    }
}
