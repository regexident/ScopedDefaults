// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public extension UserDefaults {
    public func get<T: UserDefaultProtocol>(for userDefault: T) -> T.Value {
        return self.get(for: userDefault, default: userDefault.defaultValue())
    }

    public func get<T: UserDefaultProtocol>(
        for userDefault: T,
        `default` defaultValue: @autoclosure () -> T.Value
    ) -> T.Value {
        guard let untypedValue = self.value(forKey: userDefault.keyPath) else {
            return defaultValue()
        }
        guard let typedValue = untypedValue as? T.Value else {
            let keyPath = userDefault.keyPath
            let expected = T.Value.self
            let found = type(of: untypedValue)
            print("Warning: Ignoring '\(keyPath)' (expected '\(expected)', found '\(found)'.")
            return defaultValue()
        }
        return typedValue
    }

    public func set<T: UserDefaultProtocol>(_ value: T.Value, for userDefault: T) {
        self.setValue(value, forKey: userDefault.keyPath)
    }

    public func removeValue<T: UserDefaultProtocol>(for userDefault: T) {
        self.removeObject(forKey: userDefault.keyPath)
    }
}
