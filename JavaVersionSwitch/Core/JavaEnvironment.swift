//
//  JavaEnvironment.swift
//  JavaVersionSwitch
//
//  Created by wyy on 2022/9/19.
//

import Foundation
import SwiftUI

//@MainActor
//class JavaEnvironmentManager: ObservableObject {
//    @Published var current: JavaEnvironment?
//    @Published var all: [JavaEnvironment] = []
//
//
//    static let mock: JavaEnvironmentManager = {
//        let manager = JavaEnvironmentManager()
////        manager.current = JavaEnvironment.mock
////        manager.all = [JavaEnvironment.mock]
//        return manager
//    }()
//}

//struct JavaEnvironment {
//    let home: String
//    let version: String
//    let specificationVersion: String
//    let vmName: String
//    let rtName: String
//
//    static let mock = JavaEnvironment(home: "/path", version: "1.8.0_202", specificationVersion: "1.8", vmName: "OpenJDK", rtName: "Java(TM) SE Runtime Environment")
//}

//extension JavaEnvironment: Identifiable, Equatable {
//    var id: String {
//        home
//    }
//
//    // 仅对比JavaHome即可
//    static func == (lhs: JavaEnvironment, rhs: JavaEnvironment) -> Bool {
//        return lhs.id == rhs.id
//    }
//}

enum JError: Error {
    case invalidURL
    case executeCmdError
    case parseError
}

extension JavaEnvironmentManager {
    static let javaHomeCmd =
        """
        java -XshowSettings:properties -version 2>&1 | \
           awk -F= '$1~"java.home" {sub(/^[ ]+/, "", $2); print $2}'
        """

    func detectCurrentJavaEnvironment() async throws -> JavaEnvironment? {
        let result = try await ProcessUtil.execute(shell: JavaEnvironmentManager.javaHomeCmd).result.get()
        if result.stdout.isEmpty {
            return nil
        }
        current = try await add(url: URL(fileURLWithPath: result.stdout))
        return current
    }

    func add(url: URL) async throws -> JavaEnvironment {
        let javaPath = url.path + "/bin/"
        if !FileManager.default.fileExists(atPath: javaPath) {
            throw JError.invalidURL
        }

        let result = try await ProcessUtil.execute(shell: javaPath + "java -XshowSettings:properties -version").result.get()
        if result.stdout.isEmpty && result.stderr.isEmpty {
            throw JError.executeCmdError
        }
        let data = result.stdout + "\n" + result.stderr
        print("output: \(data)")
        let env = JavaEnvironment.parse(propertiesCmdOut: data)
        guard let env = env else {
            throw JError.parseError
        }
        all.append(env)
        objectWillChange.send()
        return env
    }
}

extension JavaEnvironment {
    static func parse(propertiesCmdOut: String) -> JavaEnvironment? {
        if propertiesCmdOut.isEmpty {
            return nil
        }
        let lines = propertiesCmdOut.split(whereSeparator: \.isNewline)

        var version = ""
        var specificationVersion = ""
        var vmName = ""
        var rtName = ""
        var home = ""
        for line in lines {
            // 多行的不展示
            let parts = line.split(separator: "=", maxSplits: 1)
            if parts.isEmpty || parts.count != 2 {
                continue
            }
            let key = parts[0].trimmingCharacters(in: .whitespaces)
            let value = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
            switch key {
            case "java.version":
                version = value
            case "java.specification.version":
                specificationVersion = value
            case "java.vm.name":
                vmName = value
            case "java.runtime.name":
                rtName = value
            case "java.home":
                home = value
            default: break
            }
        }
        if version.isEmpty || specificationVersion.isEmpty || home.isEmpty {
            return nil
        }
        return JavaEnvironment(home: home, version: version, specificationVersion: specificationVersion, vmName: vmName, rtName: rtName)
    }
}
