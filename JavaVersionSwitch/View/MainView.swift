//
//  MainView.swift
//  JavaVersionSwitch
//
//  Created by wyy on 2022/9/22.
//

import SwiftUI

struct MainView: View {
    @StateObject var manager: JavaEnvironmentManager
    var body: some View {
        List {
            Section(content: {
                if manager.current != nil {
                    CurrentEnvironmentView(current: manager.current!)
                } else {
                    EmptyView()
                }
            }, header: {
                HStack {
                    Text("当前环境")
                    Spacer()
                    Button("检测当前环境", action: detectCurrentEnvironment)
                }
            })
            Section(content: {
                ForEach(manager.all, id: \.id) {
                    JavaEnvironmentView(env: $0)
                        .environmentObject(manager)
                }
            }, header: {
                HStack {
                    Text("JDK")
                    Spacer()
                    Button("添加", action: openFile)
                }
            })
        }
    }
    
    func openFile() {
        URLSelector(type: .folder, select: { url, flag in
            if let selected = url, flag {
                Logger.shared.info("add url: \(selected)")
                Task {
                    _ = try await manager.add(url: selected)
                }
            }
        }).selectModal()
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
}

struct DetailTableData: Identifiable {
    let id = UUID()
    let key: String
    let value: String

    static func parse(env: JavaEnvironment) -> [DetailTableData] {
        return [
            DetailTableData(key: "SpecificationVersion", value: env.specificationVersion),
            DetailTableData(key: "Version", value: env.version),
            DetailTableData(key: "JavaHome", value: env.home),
            DetailTableData(key: "VMName", value: env.vmName),
            DetailTableData(key: "JavaRuntimeName", value: env.rtName),
        ]
    }
}

struct CurrentEnvironmentView: View {
    var current: JavaEnvironment
    var body: some View {
        LazyVStack {
            ForEach(DetailTableData.parse(env: current)) { item in
                HStack {
                    Text(item.key)
                        .bold()
                    Spacer()
                    Text(item.value)
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(manager: .mock)
    }
}
