// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

internal struct DefaultsEncodingError: Error {
    let error: Error
}

internal struct DefaultsDecodingError: Error {
    let error: Error
}

public extension UserDefaults {
    public func get<T: UserDefaultProtocol>(for userDefault: T) -> T.Value {
        return self.get(for: userDefault, default: userDefault.defaultValue())
    }

    public func get<T: UserDefaultProtocol>(
        for userDefault: T,
        `default` defaultValue: @autoclosure () -> T.Value
        ) -> T.Value {
        typealias ValueType = T.Value
        guard let plist = self.value(forKey: userDefault.keyPath) else {
            return defaultValue()
        }
        do {
            return try ValueType.fromPlist(plist)
        } catch let error {
            do {
                typealias ErrorType = DefaultsDecodingError
                let errorName = String(describing: ErrorType.self)
                print("Error: Encountered error while decoding user default from property list.")
                print("\"\(error)\"")
                print("Info: Use a \"Swift Error Breakpoint\" on type \"Defaults.\(errorName)\" to catch.")
                throw ErrorType(error: error)
            } catch {
                // intentionally left blank
            }
            return defaultValue()
        }
    }

    public func set<T: UserDefaultProtocol>(_ value: T.Value, for userDefault: T) {
        typealias ValueType = T.Value
        typealias ContainerType = PropertyListContainer<T.Value>
        do {
            let plist = try value.asPlist()
            self.setValue(plist, forKey: userDefault.keyPath)
        } catch let error {
            do {
                typealias ErrorType = DefaultsEncodingError
                let errorName = String(describing: ErrorType.self)
                print("Error: Encountered error while encoding user default to property list.")
                print("\"\(error)\"")
                print("Info: Use a \"Swift Error Breakpoint\" on type \"Defaults.\(errorName)\" to catch.")
                throw ErrorType(error: error)
            } catch {
                // intentionally left blank
            }
        }
    }

    public func removeValue<T: UserDefaultProtocol>(for userDefault: T) {
        self.removeObject(forKey: userDefault.keyPath)
    }
}

// Both `JSONEncoder` and `PropertyListEncoder` cannot encode top-level fragments.
// We thus wrap the value in a container type and then extract its encoded `contents`:
// Bug has been reported here:
// https://bugs.swift.org/browse/SR-7213
// https://bugs.swift.org/browse/SR-6163
private struct PropertyListContainer<T>: Encodable
    where
    T: Encodable
{
    enum CodingKeys: String, CodingKey {
        case contents
    }

    let contents: T

    init(_ contents: T) {
        self.contents = contents
    }
}

extension Encodable {
    func asPlist() throws -> Any {
        // See documentation for `PropertyListContainer` for why this is necessary for now:
        typealias ContainerType = PropertyListContainer<Self>
        let encoder = PropertyListEncoder()
        let container = ContainerType(self)
        let data = try encoder.encode(container)
        let containerPlist = try PropertyListSerialization.propertyList(
            from: data,
            options: [],
            format: nil
        ) as! [String : Any]
        let codingKey = ContainerType.CodingKeys.contents.rawValue
        let plist = containerPlist[codingKey]!
        return plist
    }
}

extension Decodable {
    static func fromPlist(_ plist: Any) throws -> Self {
        let data = try PropertyListSerialization.data(
            fromPropertyList: plist,
            format: .binary,
            options: 0
        )
        let value = try PropertyListDecoder().decode(Self.self, from: data)
        return value
    }
}
