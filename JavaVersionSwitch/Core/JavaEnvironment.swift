//
//  JavaEnvironment.swift
//  JavaVersionSwitch
//
//  Created by wyy on 2022/9/19.
//

import Foundation

struct JavaEnvironmentMannager {
    let current: JavaEnvironment
    let all: [JavaEnvironment]
}

struct JavaEnvironment {
    let fullPath: String
    let version: String
    let version_num: Int
}

enum JError: Error {
    case invalidURL
}

extension JavaEnvironmentMannager {
    func add(url: URL) throws -> JavaEnvironment? {
        var isDir: ObjCBool = true
        if !FileManager.default.fileExists(atPath: url.absoluteString, isDirectory: &isDir) {
            throw JError.invalidURL
        }
        if !isDir.boolValue {
            throw JError.invalidURL
        }
//        url.appendingPathComponent("/bin/java")
        return nil
    }
}

func shell(_ command: String) throws -> String {
    let task = Process()
    let pipe = Pipe()

    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    task.launchPath = "/bin/zsh"
    task.standardInput = nil
    try task.run()

//    pipe.fileHandleForReading.rea
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
//    pipe.fileHandleForReading.
    let output = String(data: data, encoding: .utf8)!
//    task.terminationStatus
    return output
}


actor ProcessWithStream {
    private let process = Process()
    private let stdin = Pipe()
    private let stdout = Pipe()
    private let stderr = Pipe()
    private var buffer = Data()

    init(url: URL) {
        process.standardInput = stdin
        process.standardOutput = stdout
        process.standardError = stderr
        process.executableURL = url
    }

    func start() throws {
        try process.run()
    }

    func terminate() {
        process.terminate()
    }

    func send(_ string: String) {
        guard let data = "\(string)\n".data(using: .utf8) else { return }
        stdin.fileHandleForWriting.write(data)
    }

    func stream() -> AsyncStream<Data> {
        AsyncStream(Data.self) { continuation in
            stdout.fileHandleForReading.readabilityHandler = { handler in
                continuation.yield(handler.availableData)
            }
            process.terminationHandler = { handler in
                continuation.finish()
            }
        }
    }
}
