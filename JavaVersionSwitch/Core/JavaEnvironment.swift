//
//  JavaEnvironment.swift
//  JavaVersionSwitch
//
//  Created by wyy on 2022/9/19.
//

import Foundation
import SwiftUI

@MainActor
class JavaEnvironmentMannager: ObservableObject {
    @Published var current: JavaEnvironment?
    @Published var all: [JavaEnvironment] = []
}

struct JavaEnvironment {
    let home: String
    let version: String
    let specificationVersion: String
    let vmName: String
    let rtName: String
    
    static let mock = JavaEnvironment(home: "/path", version: "1.8.0_202", specificationVersion: "1.8", vmName: "OpenJDK", rtName: "Java(TM) SE Runtime Environment")
}

extension JavaEnvironment: Identifiable {
    var id: String {
        home
    }
}

enum JError: Error {
    case invalidURL
    case executeCmdError
}

extension JavaEnvironmentMannager {
    static let runtimeVersionCmd =
        """
        java -XshowSettings:properties -version 2>&1 | \
          awk -F= '$1~"java.version " {sub(/^[ ]+/, "", $2); print $2}'
        """
    static let specificationVersionCmd =
        """
        java -XshowSettings:properties -version 2>&1 | \
           awk -F= '$1~"java.vm.specification.version" {sub(/^[ ]+/, "", $2); print $2}'
        """
    static let vmNameCmd =
        """
        java -XshowSettings:properties -version 2>&1 | \
           awk -F= '$1~"java.vm.name" {sub(/^[ ]+/, "", $2); print $2}'
        """
    static let javaHomeCmd =
        """
        java -XshowSettings:properties -version 2>&1 | \
           awk -F= '$1~"java.home" {sub(/^[ ]+/, "", $2); print $2}'
        """

    func detectCurrentJavaEnvironment() async throws -> JavaEnvironment? {
        let result = try await ProcessUtil.execute(shell: JavaEnvironmentMannager.javaHomeCmd)
        if result.hasError || result.data.isEmpty {
            return nil
        }
        self.current = try await add(url: URL(fileURLWithPath: result.data))
        return self.current
    }

    func add(url: URL) async throws -> JavaEnvironment {
        let javaPath = url.path + "/bin/"
        if !FileManager.default.fileExists(atPath: javaPath) {
            throw JError.invalidURL
        }

        let rtVersionResult = try await ProcessUtil.execute(shell: javaPath + JavaEnvironmentMannager.runtimeVersionCmd)
        if rtVersionResult.hasError || rtVersionResult.data.isEmpty {
            throw JError.executeCmdError
        }

        let specResult = try await ProcessUtil.execute(shell: javaPath + JavaEnvironmentMannager.specificationVersionCmd)
        if specResult.hasError || rtVersionResult.data.isEmpty {
            throw JError.executeCmdError
        }

        let vmNameResult = try await ProcessUtil.execute(shell: javaPath + JavaEnvironmentMannager.specificationVersionCmd)
        if vmNameResult.hasError || rtVersionResult.data.isEmpty {
            throw JError.executeCmdError
        }

        let env = JavaEnvironment(home: url.path,
                                  version: rtVersionResult.data.trimmingCharacters(in: .whitespacesAndNewlines),
                                  specificationVersion: specResult.data.trimmingCharacters(in: .whitespacesAndNewlines),
                                  vmName: vmNameResult.data.trimmingCharacters(in: .whitespacesAndNewlines),
                                  rtName: ""
        )
        all.append(env)
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
