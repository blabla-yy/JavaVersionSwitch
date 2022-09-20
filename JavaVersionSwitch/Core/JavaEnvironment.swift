//
//  JavaEnvironment.swift
//  JavaVersionSwitch
//
//  Created by wyy on 2022/9/19.
//

import Foundation
import SwiftUI

class JavaEnvironmentMannager: ObservableObject {
    @Published var current: JavaEnvironment?
    @Published var all: [JavaEnvironment] = []
}

struct JavaEnvironment {
    let fullPath: String
    let version: String
    let specificationVersion: String
    let vmName: String
}
extension JavaEnvironment: Identifiable {
    var id: String {
        fullPath
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

        let env = JavaEnvironment(fullPath: url.path,
                                  version: rtVersionResult.data.trimmingCharacters(in: .whitespacesAndNewlines),
                                  specificationVersion: specResult.data.trimmingCharacters(in: .whitespacesAndNewlines),
                                  vmName: vmNameResult.data.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        self.all.append(env)
        return env
    }
}
