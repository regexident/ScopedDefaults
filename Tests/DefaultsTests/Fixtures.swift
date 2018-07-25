//
//  Fixtures.swift
//  Defaults
//
//  Created by Vincent Esche on 7/25/18.
//

import Foundation

@testable import Defaults

enum Defaults: EnumerableUserDefaultsScope {
    public typealias Default<Value> = ScopedUserDefault<Defaults, Value>

    static let outer: UserDefaultsScope.Type? = nil
    static let key: String = "settings"

    static let inner: [EnumerableUserDefaultsScope.Type] = [
        FooDefaults.self,
        BazDefaults.self,
    ]
    static let defaults: [AnyUserDefault] = [
        Defaults.answer,
    ]

    static let answer: Default<Int> = .init(
        key: "answer", defaultValue: 42
    )

    final class Proxy {
        lazy var foo: FooDefaults.Proxy = .init(from: self.userDefaults)
        lazy var baz: BazDefaults.Proxy = .init(from: self.userDefaults)

        var answer: Int {
            get { return self.userDefaults.get(for: Defaults.answer) }
            set { return self.userDefaults.set(newValue, for: Defaults.answer) }
        }

        private let userDefaults: UserDefaults
        
        init(from userDefaults: UserDefaults = .standard) {
            self.userDefaults = userDefaults
        }
    }
}

enum FooDefaults: EnumerableUserDefaultsScope {
    public typealias Default<Value> = ScopedUserDefault<FooDefaults, Value>

    static let outer: UserDefaultsScope.Type? = Defaults.self
    static let key: String = "foo"

    static let inner: [EnumerableUserDefaultsScope.Type] = []
    static let defaults: [AnyUserDefault] = [
        FooDefaults.bar,
    ]

    static let bar: Default<Bool> = .init(
        key: "bar", defaultValue: false
    )

    final class Proxy {
        var bar: Bool {
            get { return self.userDefaults.get(for: FooDefaults.bar) }
            set { return self.userDefaults.set(newValue, for: FooDefaults.bar) }
        }

        private let userDefaults: UserDefaults

        init(from userDefaults: UserDefaults = .standard) {
            self.userDefaults = userDefaults
        }
    }
}

enum BazDefaults: EnumerableUserDefaultsScope {
    public typealias Default<Value> = ScopedUserDefault<BazDefaults, Value>

    static let outer: UserDefaultsScope.Type? = Defaults.self
    static let key: String = "baz"

    static let inner: [EnumerableUserDefaultsScope.Type] = []
    static let defaults: [AnyUserDefault] = [
        BazDefaults.blee,
    ]

    static let blee: Default<Bool> = .init(
        key: "blee", defaultValue: true
    )

    final class Proxy {
        var blee: Bool {
            get { return self.userDefaults.get(for: BazDefaults.blee) }
            set { return self.userDefaults.set(newValue, for: BazDefaults.blee) }
        }

        private let userDefaults: UserDefaults

        init(from userDefaults: UserDefaults = .standard) {
            self.userDefaults = userDefaults
        }
    }
}
