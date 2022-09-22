//
//  MainView.swift
//  JavaVersionSwitch
//
//  Created by wyy on 2022/9/22.
//

import SwiftUI

struct MainView: View {
    @StateObject var manager: JavaEnvironmentMannager
    var body: some View {
        List {
            Section("当前环境", content: {
                if manager.current != nil {
                    CurrentEnvironmentView(current: manager.current!)
                } else {
                    Text("")
                }
            })
            Button("检测当前环境", action: detectCurrentEnvironment)
//            Divider()
            Section("JDK") {
                ForEach(manager.all, id: \.id) {
                    JavaEnvironmentView(env: $0)
                        .environmentObject(manager)
//                    if manager.all.last != $0 {
//                        Divider()
//                    }
                }
            }
        }
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
//        VStack {
        Table(DetailTableData.parse(env: current), columns: {
            TableColumn("", value: \.key)
            TableColumn("", value: \.value)
        })
        .frame(height: 200)
//        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(manager: .mock)
    }
}
