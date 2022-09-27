//
//  CoreDataEx.swift
//  JavaVersionSwitch
//
//  Created by 王跃洋 on 2022/9/27.
//

import CoreData

typealias Then = (Bool) -> Void

extension NSManagedObjectContext {
    func fetchAndLog<T>(_ request: NSFetchRequest<T>) async -> [T] where T: NSFetchRequestResult {
        do {
            return try await perform {
                try self.fetch(request)
            }
        } catch {
            Logger.shared.error("fetch coredata error \(error.localizedDescription)")
            return []
        }
    }

    func saveAndLogError() async -> Bool {
        if !hasChanges {
            print("no changes")
            return true
        }
        do {
            try await perform {
                try self.save()
            }
        } catch {
            Logger.shared.error("save coredata error \(error.localizedDescription)")
            await perform {
                self.rollback()
            }
            return false
        }
        return true
    }
}
