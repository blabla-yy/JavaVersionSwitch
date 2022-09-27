//
//  Switch.swift
//  JavaVersionSwitch
//
//  Created by wyy on 2022/9/27.
//

import Foundation

struct VersionSwitch {
    let source: JavaEnvironment
    static let targetDir: URL = {
        FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("/.JavaVersionSwitch/bin")
    }()

    static let envDir: URL = {
        FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("/.JavaVersionSwitch")
    }()

    func process() async throws {
        guard let sourceHome = source.home else {
            return
        }
        if !FileManager.default.fileExists(atPath: sourceHome) || !FileManager.default.fileExists(atPath: sourceHome + "/bin") {
            return
        }
        if !FileManager.default.fileExists(atPath: VersionSwitch.envDir.path) {
            try FileManager.default.createDirectory(at: VersionSwitch.envDir, withIntermediateDirectories: false)
        }
        if FileManager.default.fileExists(atPath: VersionSwitch.targetDir.path) {
            try FileManager.default.removeItem(at: VersionSwitch.targetDir)
        }
        try FileManager.default.createDirectory(at: VersionSwitch.targetDir, withIntermediateDirectories: true)

        // 第一次创建时
        let _ = try await ProcessUtil.execute(shell: """
        [ ! $JAVA_VERSION_SWITCH ] && echo '\nexport JAVA_VERSION_SWITCH="$HOME/.JavaVersionSwitch"\nexport PATH="$JAVA_VERSION_SWITCH/bin:$PATH"' >> $HOME/.zshrc
        """)
        .value
        
        try Files.createLink(targetDir: VersionSwitch.targetDir.path, sourceDir: sourceHome + "/bin")
    }
}
