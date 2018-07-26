import XCTest

@testable import ScopedDefaults

final class DefaultsTests: XCTestCase {
    static let userDefaultsSuiteName = "DefaultsTests"
    var userDefaults: UserDefaults!

    override func setUp() {
        super.setUp()

        self.userDefaults = UserDefaults(suiteName: DefaultsTests.userDefaultsSuiteName)
    }

    override func tearDown() {
        self.userDefaults.removePersistentDomain(forName: DefaultsTests.userDefaultsSuiteName)

        super.tearDown()
    }

    func testFactoryDefaults() {
        let factoryDefaults: [String : Any] = Defaults.factoryDefaults()
        XCTAssertEqual(
            Set(factoryDefaults.keys),
            Set(["settings.answer", "settings.foo.bar", "settings.baz.blee"])
        )
    }

    func testRegisterDefaults() {
        let defaults: UserDefaults = self.userDefaults

        Defaults.register(on: defaults)
        let settings = Defaults.Proxy(from: defaults)

        XCTAssertEqual(settings.answer, 42)

        XCTAssertEqual(settings.foo.bar, false)
        XCTAssertEqual(settings.baz.blee, true)
    }

    func testDefaults() {
        let settings = Defaults.Proxy(from: self.userDefaults)

        print(settings)

        XCTAssertEqual(settings.foo.bar, false)
        XCTAssertEqual(settings.baz.blee, true)

        settings.foo.bar = true
        XCTAssertEqual(settings.foo.bar, true)

        settings.baz.blee = false
        XCTAssertEqual(settings.baz.blee, false)
    }

    static var allTests = [
        ("testFactoryDefaults", testFactoryDefaults),
        ("testRegisterDefaults", testRegisterDefaults),
        ("testDefaults", testDefaults),
    ]
}
