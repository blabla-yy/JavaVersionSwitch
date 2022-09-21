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
    @ObservedObject private var manager = JavaEnvironmentMannager()

    var body: some View {
        List {
            Button("检测当前环境", action: detectCurrentEnvironment)
            ForEach(manager.all) { item in
                VStack {
                    Text(item.version)
                }
                .frame(minHeight: 100)
                .background(Color.red)
                
            }
        }
        .frame(minWidth: 200, minHeight: 400)
        .onDrop(of: [.fileURL], isTargeted: $isTargeted, perform: self.dropDelegate)
    }
    
    func detectCurrentEnvironment() {
        Task {
            do {
                _ = try await manager.detectCurrentJavaEnvironment()
            } catch {
                Logger.shared.error("open file error, \(error.localizedDescription)")
                return
            }
        }
    }

    func dropDelegate(_ providers: [NSItemProvider]) -> Bool {
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
                    _ = try await manager.add(url: url)
                }
            } catch {
                Logger.shared.error("open file error, \(error.localizedDescription)")
                return
            }
        }
        return true
    }
}
