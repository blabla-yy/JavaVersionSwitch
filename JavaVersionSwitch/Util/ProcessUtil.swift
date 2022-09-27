//
//  Process.swift
//  JavaVersionSwitch
//
//  Created by 王跃洋 on 2022/9/19.
//

import Foundation

struct ProcessResult {
    let code: Int
    let stdout: String
    let stderr: String
}

struct ProcessUtil {
    static let zsh = URL(fileURLWithPath: "/bin/zsh")

    static func execute(shell: String) -> Task<ProcessResult, any Error> {
        return Task.detached {
            let process = Process()

            let stdout = Pipe()
            let stderr = Pipe()

            process.standardOutput = stdout
            process.standardError = stderr
            process.executableURL = zsh

            let arguments = ["-l", "-i", "-c", shell]
            print("Arguments: \(arguments)")
            process.arguments = arguments

            try process.run()
            process.waitUntilExit()

            let outData = String(data: try stdout.fileHandleForReading.readToEnd() ?? .init(), encoding: .utf8) ?? ""
            let errorData = String(data: try stderr.fileHandleForReading.readToEnd() ?? .init(), encoding: .utf8) ?? ""

            if process.terminationStatus != 0 || !errorData.isEmpty {
                Logger.shared.error("execute \(shell) has error, code: \(process.terminationStatus), stderr: \(errorData)")
            }
            return ProcessResult(code: Int(process.terminationStatus),
                                 stdout: outData.trimmingCharacters(in: .whitespacesAndNewlines),
                                 stderr: errorData.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }
}
