//
//  Link.swift
//  JavaVersionSwitch
//
//  Created by wyy on 2022/9/21.
//

import Foundation

struct Files {
    static func getFileNames(path: String, includeDir: Bool = false) throws -> [String] {
        var filePaths = [String]()
        do {
            let array = try FileManager.default.contentsOfDirectory(atPath: path)
            for fileName in array {
                if fileName == ".DS_Store" {
                    continue
                }
                var isDir: ObjCBool = true
                if FileManager.default.fileExists(atPath: "\(path)/\(fileName)", isDirectory: &isDir) {
                    if !includeDir && !isDir.boolValue {
                        filePaths.append(fileName)
                    } else if includeDir {
                        filePaths.append(fileName)
                    }
                }
            }

            if filePaths.isEmpty {
                Logger.shared.info("\(path) no files")
            }
        } catch {
            Logger.shared.error("get file names error \(error.localizedDescription)")
            throw error
        }
        return filePaths
    }

    static func createLink(targetDir: String, sourceDir: String) throws {
        do {
            let fileNames = try getFileNames(path: sourceDir)

            for fileName in fileNames {
                try FileManager.default.createSymbolicLink(atPath: "\(targetDir)/\(fileName)", withDestinationPath: "\(sourceDir)/\(fileName)")
            }
        } catch {
            Logger.shared.error("createSymbolicLink error \(error.localizedDescription)")
            throw error
        }
    }
}
