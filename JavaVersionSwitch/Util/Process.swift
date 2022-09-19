//
//  Process.swift
//  JavaVersionSwitch
//
//  Created by 王跃洋 on 2022/9/19.
//

import Foundation

struct ProcessResult {
    let hasError: Bool
    let data: String
}

struct ProcessUtil {
    static let zsh = URL(fileURLWithPath: "/bin/zsh")
    
    static func execute(shell: String) async throws -> ProcessResult {
        let process = Process()

        let stdout = Pipe()
        let stderr = Pipe()

        process.standardOutput = stdout
        process.standardError = stderr
        process.executableURL = zsh

        let arguments = ["-c", shell]
        print("Arguments: \(arguments)")
        process.arguments = arguments

        let outLine = stdout.fileHandleForReading.bytes.lines
        let errorLine = stderr.fileHandleForReading.bytes.lines

        try process.run()
        var outData = ""
        var errorData = ""

        
        for try await line in outLine {
            outData += line
        }
        if process.isRunning {
            for try await line in errorLine {
                errorData += line
            }
        }
        //TODO
        process.waitUntilExit()
        if process.terminationStatus == 0 {
            return ProcessResult(hasError: false, data: outData)
        } else {
            Logger.shared.error("execute \(shell) error, code: \(process.terminationStatus), stderr: \(errorData)")
            return ProcessResult(hasError: true, data: errorData)
        }
    }
}
