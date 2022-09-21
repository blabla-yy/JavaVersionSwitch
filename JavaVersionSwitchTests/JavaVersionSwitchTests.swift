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
        try await env.add(url: URL.init(fileURLWithPath: "/opt/homebrew/Cellar/openjdk/18.0.2.1/libexec/openjdk.jdk/Contents/Home") )
    }
    
    func testFileNames() async throws {
        let names = try Files.getFileNames(path: "/Users/wyy/Documents/")
        print("files: \(names)")
        XCTAssert(!names.isEmpty)
    }

    func testLink() async throws {
        try Files.createLink(target: "/Users/wyy/Desktop/bin", source: "/Users/wyy/Documents/")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
}
