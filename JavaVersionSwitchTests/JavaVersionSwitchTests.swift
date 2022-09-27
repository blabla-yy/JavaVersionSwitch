//
//  JavaVersionSwitchTests.swift
//  JavaVersionSwitchTests
//
//  Created by 王跃洋 on 2022/9/19.
//

import XCTest

final class JavaVersionSwitchTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() async throws {
        let result = try await ProcessUtil.execute(shell: "/opt/homebrew/opt/openjdk/bin/java --version").result.get()
        if !result.stdout.isEmpty {
            print("Success: \(result)")
        }
    }

    func testJavaEnvironmentManagerAddExample() async throws {
        let env = await JavaEnvironmentManager()
        _ = try await env.add(url: URL(fileURLWithPath: "/opt/homebrew/Cellar/openjdk/18.0.2.1/libexec/openjdk.jdk/Contents/Home"))
    }

    func testParse() async throws {
        let result = try await ProcessUtil.execute(shell: "java -XshowSettings:properties -version").result.get()
        XCTAssert(!result.stdout.isEmpty || !result.stderr.isEmpty)
        if result.stdout.isEmpty && result.stderr.isEmpty {
            return
        }
        let data = result.stdout + "\n" + result.stderr
        print("output: \(data)")
        let env = JavaEnvironment.parse(propertiesCmdOut: data)
        XCTAssert(env != nil)
        if env == nil {
            return
        }
        print("env: \(env!)")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
}
