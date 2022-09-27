//
//  ContentView.swift
//  JavaVersionSwitch
//
//  Created by wyy on 2022/9/19.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State var isTargeted = false

    @FetchRequest(entity: JavaEnvironmentManager.entity(),
                  sortDescriptors: [],
                  predicate: NSPredicate(format: "id == %@", argumentArray: [JavaEnvironmentManager.singletonID]))
    var manager: FetchedResults<JavaEnvironmentManager>
    @Environment(\.managedObjectContext) var ctx

    var body: some View {
        VStack {
            if manager.first != nil {
                MainView()
                    .onDrop(of: [.fileURL], isTargeted: $isTargeted, perform: self.dropDelegate)
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
                    .onAppear(perform: createSingleton)
            }
        }
        .frame(minWidth: 600, minHeight: 400)
    }

    func createSingleton() {
        Task {
            let singleton = JavaEnvironmentManager(context: ctx)
            singleton.id = JavaEnvironmentManager.singletonID
            singleton.all = NSSet()
            _ = await ctx.saveAndLogError()
        }
    }

    func dropDelegate(_ providers: [NSItemProvider]) -> Bool {
        guard let manager = manager.first else {
            return false
        }
        Task {
            do {
                for item in providers {
                    let data = try await item.loadItem(forTypeIdentifier: UniformTypeIdentifiers.UTType.fileURL.identifier, options: nil)
                    guard let data = data as? Data,
                          let url = URL(dataRepresentation: data, relativeTo: nil) else {
                        Logger.shared.error("open file success but data is nil")
                        return
                    }
                    Logger.shared.info("add url: \(url)")
                    _ = try await manager.add(url: url, context: ctx)
                    _ = await ctx.saveAndLogError()
                }
            } catch {
                Logger.shared.error("open file error, \(error.localizedDescription)")
                return
            }
        }
        return true
    }
}
