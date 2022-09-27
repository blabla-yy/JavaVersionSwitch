//
//  JavaEnvironment.swift
//  JavaVersionSwitch
//
//  Created by wyy on 2022/9/19.
//

import Foundation
import SwiftUI

enum JError: Error {
    case invalidURL
    case executeCmdError
    case parseError
}

extension JavaEnvironmentManager {
    static let singletonID: Int32 = 1
    static let javaHomeCmd =
        """
        java -XshowSettings:properties -version 2>&1 | \
           awk -F= '$1~"java.home" {sub(/^[ ]+/, "", $2); print $2}'
        """

    func detectCurrentJavaEnvironment(context: NSManagedObjectContext) async throws -> Bool {
        let result = try await ProcessUtil.execute(shell: JavaEnvironmentManager.javaHomeCmd).result.get()
        if result.stdout.isEmpty {
            return false
        }
        current = try await add(url: URL(fileURLWithPath: result.stdout), context: context)
        return await context.saveAndLogError()
    }

    func add(url: URL, context: NSManagedObjectContext) async throws -> JavaEnvironment {
        let javaPath = url.appendingPathComponent("/bin/").path
        if !FileManager.default.fileExists(atPath: javaPath) {
            throw JError.invalidURL
        }

        let result = try await ProcessUtil.execute(shell: javaPath + "/java -XshowSettings:properties -version").result.get()
        if result.stdout.isEmpty && result.stderr.isEmpty {
            throw JError.executeCmdError
        }
        let data = result.stdout + "\n" + result.stderr
        print("output: \(data)")
        let subContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        subContext.parent = context
        let env = JavaEnvironment.parse(propertiesCmdOut: data)
        guard let env = env else {
            throw JError.parseError
        }

        if all == nil {
            all = NSSet()
        }
        let found = all?.filter {
            ($0 as! JavaEnvironment).home == env.home
        }
        if let exists = found?.first {
            return exists as! JavaEnvironment
        } else {
            let envObject = JavaEnvironment(context: context)
            envObject.home = env.home
            envObject.rtName = env.rtName
            envObject.vmName = env.vmName
            envObject.specificationVersion = env.specificationVersion
            envObject.version = env.version
            envObject.manager = self
            all?.adding(env)
            return envObject
        }
    }
}

fileprivate struct _JavaEnvironment {
    let home: String
    let version: String
    let specificationVersion: String
    let vmName: String
    let rtName: String
}

extension JavaEnvironment {
    fileprivate static func parse(propertiesCmdOut: String) -> _JavaEnvironment? {
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
        return _JavaEnvironment(home: home, version: version, specificationVersion: specificationVersion, vmName: vmName, rtName: rtName)
    }
}
