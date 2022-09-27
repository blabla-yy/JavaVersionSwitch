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
        if !FileManager.default.fileExists(atPath: source.home) || !FileManager.default.fileExists(atPath: source.home + "/bin") {
            return
        }
        // 第一次创建时
        let _ = try await ProcessUtil.execute(shell: """
        [ ! $JAVA_VERSION_SWITCH ] && echo '\nJAVA_VERSION_SWITCH="$HOME/.JavaVersionSwitch"\nexport PATH="$JAVA_VERSION_SWITCH/bin:$PATH"' >> $HOME/.zshrc
        """)
        .value
        if FileManager.default.fileExists(atPath: VersionSwitch.targetDir.path) {
            try FileManager.default.removeItem(at: VersionSwitch.targetDir)
            try FileManager.default.createDirectory(at: VersionSwitch.targetDir, withIntermediateDirectories: true)
        }

        try Files.createLink(targetDir: VersionSwitch.targetDir.path, sourceDir: source.home + "/bin")
    }
}
