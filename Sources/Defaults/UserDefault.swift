// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public protocol AnyUserDefault {
    var keyPath: String { get }
    var anyDefaultValue: () -> Any? { get }
}

public protocol UserDefaultProtocol {
    associatedtype Value: Codable

    var keyPath: String { get }
    var defaultValue: () -> Value { get }
}

public struct ScopedUserDefault<Scope, Value>: UserDefaultProtocol, AnyUserDefault
    where
    Scope: UserDefaultsScope,
    Value: Codable
{
    public let key: String
    public let defaultValue: () -> Value

    public var keyPath: String {
        let keyPath = Scope.keyPath
        if keyPath.isEmpty {
            return self.key
        } else {
            return "\(keyPath).\(self.key)"
        }
    }

    public var anyDefaultValue: () -> Any? {
        return self.defaultValue
    }

    public init(key: String, defaultValue: @escaping @autoclosure () -> Value) {
        self.key = key
        self.defaultValue = defaultValue
    }
}

extension ScopedUserDefault: Equatable {
    public static func ==<Value>(
        lhs: ScopedUserDefault<Scope, Value>,
        rhs: ScopedUserDefault<Scope, Value>
        ) -> Bool {
        return lhs.key == rhs.key
    }
}

public struct UserDefault<Value: Codable>: UserDefaultProtocol, AnyUserDefault {
    public let key: String
    public let defaultValue: () -> Value

    public var keyPath: String {
        return self.key
    }

    public var anyDefaultValue: () -> Any? {
        return self.defaultValue
    }

    public init(key: String, defaultValue: @escaping @autoclosure () -> Value) {
        self.key = key
        self.defaultValue = defaultValue
    }
}

extension UserDefault: Equatable {
    public static func ==<Value>(
        lhs: UserDefault<Value>,
        rhs: UserDefault<Value>
        ) -> Bool {
        return lhs.key == rhs.key
    }
}
