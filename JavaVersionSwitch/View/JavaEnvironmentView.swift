//
//  JDKView.swift
//  JavaVersionSwitch
//
//  Created by wyy on 2022/9/21.
//

import SwiftUI

struct JavaEnvironmentView: View {
    let env: JavaEnvironment
    @State var isExpanded = false
    @EnvironmentObject var manager: JavaEnvironmentManager
    @Environment(\.managedObjectContext) var ctx

    var body: some View {
        HStack(spacing: 18) {
            VStack(alignment: .leading) {
                HStack {
                    Text(env.specificationVersion ?? "")
                        .font(.title)
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(env.version ?? "")
                            .lineLimit(1)
                        Text(env.rtName ?? "")
                            .lineLimit(1)
                    }
                }
            }
            Button(action: switchVersion, label: {
                Image(systemName: manager.current == env ? "record.circle" : "circle")
                    //                .imageScale(.large)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .scaledToFit()
                    .foregroundColor(.green)
            })
            .buttonStyle(.plain)
        }
    }

    func switchVersion() {
        Task {
            let vs = VersionSwitch(source: env)
            do {
                try await vs.process()
                manager.current = env
                _ = await ctx.saveAndLogError()
            } catch {
                Logger.shared.error("VersionSwitch process error \(error.localizedDescription)")
            }
        }
    }
}

//struct JavaEnvironmentView_Previews: PreviewProvider {
//    static var previews: some View {
//        @State var isOn = false
//        @State var selected = 1
//        return
//            List {
////                Picker(selection: $selected, label: Text("JDK")) {
//                ForEach(0 ..< 5) { i in
//                    JavaEnvironmentView(env: JavaEnvironment.mock).tag(i)
//                        .environmentObject(JavaEnvironmentManager.mock)
//                    Divider()
//                }
////                }
////                .pickerStyle(.radioGroup)
//            }
//    }
//}
