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
        let result = try await ProcessUtil.execute(shell: "/opt/homebrew/opt/openjdk/bin/java --version")
        if !result.hasError {
            print("Success: \(result)")
        }
    }

    func testJavaEnvironmentMannagerAddExample() async throws {
        let env = JavaEnvironmentMannager()
        try await env.add(url: URL(fileURLWithPath: "/opt/homebrew/Cellar/openjdk/18.0.2.1/libexec/openjdk.jdk/Contents/Home"))
    }

    func testParse() async throws {
        let result = try await ProcessUtil.execute(shell: "java -XshowSettings:properties -version")
        XCTAssert(!result.hasError)
        if result.hasError {
            return
        }
        let env = JavaEnvironment.parse(propertiesCmdOut: result.data)
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
