//
//  JDKView.swift
//  JavaVersionSwitch
//
//  Created by wyy on 2022/9/21.
//

import SwiftUI

struct JavaEnvironmentView: View {
    let env: JavaEnvironment
    var body: some View {
        VStack {
            Text("Version: \(env.specificationVersion)")
            Spacer()
        }
//        .frame(minHeight: 100)
    }
}

struct JavaEnvironmentView_Previews: PreviewProvider {
    static var previews: some View {
        JavaEnvironmentView(env: JavaEnvironment.mock)
    }
}
