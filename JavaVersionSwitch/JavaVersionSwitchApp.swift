//
//  JavaVersionSwitchApp.swift
//  JavaVersionSwitch
//
//  Created by wyy on 2022/9/19.
//

import SwiftUI

@main
struct JavaVersionSwitchApp: App {
    #if DEBUG
    let persistenceController = PersistenceController.preview
    #else
    let persistenceController = PersistenceController.shared
    #endif
    

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
