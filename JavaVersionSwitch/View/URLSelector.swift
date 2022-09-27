//
//  URLSelector.swift
//  JavaVersionSwitch
//
//  Created by wyy on 2022/9/27.
//

import AppKit

enum SelectorType {
    case file
    case folder
    case all
}

struct URLSelector {
    var type: SelectorType
    var select: (URL?, Bool) -> Void

    func selectModal() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = true
        panel.canCreateDirectories = true
        if type == .file {
            panel.canChooseDirectories = false
        }
        if type == .folder {
            panel.canChooseFiles = false
        }
        panel.allowsMultipleSelection = false
        let running = panel.runModal()
        if running != .OK {
            Logger.shared.warning("cannot run panel modal")
            select(nil, false)
        }
        select(panel.url, true)
    }
}
