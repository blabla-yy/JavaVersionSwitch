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
    @EnvironmentObject var manager: JavaEnvironmentMannager

    var body: some View {
        HStack(spacing: 18) {
            VStack(alignment: .leading) {
                HStack {
                    Text(env.specificationVersion)
                        .font(.title)
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("\(env.version)")
                            .lineLimit(1)
                        Text("\(env.rtName)")
                            .lineLimit(1)
                    }
                }
            }
            Button(action: {
                manager.current = env
            }, label: {
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
}

struct JavaEnvironmentView_Previews: PreviewProvider {
    static var previews: some View {
        @State var isOn = false
        @State var selected = 1
        return
            List {
//                Picker(selection: $selected, label: Text("JDK")) {
                ForEach(0 ..< 5) { i in
                    JavaEnvironmentView(env: JavaEnvironment.mock).tag(i)
                        .environmentObject(JavaEnvironmentMannager.mock)
                    Divider()
                }
//                }
//                .pickerStyle(.radioGroup)
            }
    }
}
