//
//  JavaVersionSwitchApp.swift
//  JavaVersionSwitch
//
//  Created by wyy on 2022/9/19.
//

import SwiftUI

@main
struct JavaVersionSwitchApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
