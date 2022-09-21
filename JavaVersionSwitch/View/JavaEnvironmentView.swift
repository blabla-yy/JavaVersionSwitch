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

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(env.specificationVersion)
                    .font(.title2)
            }

            Form {
                Text("java.version: \(env.version)")
                Text("java.runtime.name: \(env.rtName)")
            }
            
        }
//        .onTapGesture {
//            isExpanded.toggle()
//        }
    }
}

struct JavaEnvironmentView_Previews: PreviewProvider {
    static var previews: some View {
        @State var isOn = false
        @State var selected = 1
        return
            List {
                //            Picker(selection: $selected, label: Text("JDK")) {
                JavaEnvironmentView(env: JavaEnvironment.mock).tag(1)
                JavaEnvironmentView(env: JavaEnvironment.mock).tag(2)
                JavaEnvironmentView(env: JavaEnvironment.mock).tag(3)
                JavaEnvironmentView(env: JavaEnvironment.mock).tag(4)
                //            }
                //            .pickerStyle(.radioGroup)
            }
    }
}
