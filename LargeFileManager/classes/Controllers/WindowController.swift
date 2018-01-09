//
//  WindowController.swift
//  LargeFileManager
//
//  Created by xun on 2018/1/8.
//  Copyright © 2018年 xun. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.window?.titlebarAppearsTransparent =  true
        self.window?.titleVisibility = .hidden
        self.window?.standardWindowButton(.zoomButton)?.isHidden = true
    }
    
}
