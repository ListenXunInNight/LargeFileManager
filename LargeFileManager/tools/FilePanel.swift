//
//  FilePanel.swift
//  LargeFileManager
//
//  Created by xun on 2018/1/9.
//  Copyright © 2018年 xun. All rights reserved.
//

import Cocoa

extension NSOpenPanel {

    class func FilePanel() -> NSOpenPanel {
        
        let panel = NSOpenPanel()
        
        panel.prompt = "选择"
        panel.showsToolbarButton = false
        panel.allowsMultipleSelection = true
        
        let btn = panel.value(forKey: "_cancelButton") as! NSButton
        btn.title = "取消"
        
        panel.canChooseDirectories = true
        panel.canChooseFiles = true
    
        return panel
    }
}
