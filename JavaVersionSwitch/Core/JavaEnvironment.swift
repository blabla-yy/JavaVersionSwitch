//
//  JavaEnvironment.swift
//  JavaVersionSwitch
//
//  Created by wyy on 2022/9/19.
//

import Foundation

class JavaEnvironmentMannager {
    var current: JavaEnvironment? = nil
    var all: [JavaEnvironment] = []
}

struct JavaEnvironment {
    let fullPath: String
    let version: String
}

enum JError: Error {
    case invalidURL
}

extension JavaEnvironmentMannager {
    func add(url: URL) async throws -> JavaEnvironment? {
        var isDir: ObjCBool = true
        if !FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) {
            throw JError.invalidURL
        }
        if !isDir.boolValue {
            throw JError.invalidURL
        }
        let shell = url.path + "/bin/java --version"
        let result = try await ProcessUtil.execute(shell: shell)
        if !result.hasError {
            print(result.data)
        }
        return nil
    }
}
