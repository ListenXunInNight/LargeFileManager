//
//  AppDelegate.swift
//  LargeFileManager
//
//  Created by xun on 2018/1/8.
//  Copyright © 2018年 xun. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
    
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

extension AppDelegate {
    
    @IBAction func clickedPreferencesMenuItem(_ sender: NSMenuItem) {
        
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        
        let settingsVC = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "SettingsVC")) as! NSViewController
        
        let vc = NSApplication.shared.windows[0].contentViewController!
        
        vc.presentViewController(settingsVC, asPopoverRelativeTo: vc.view.bounds, of: vc.view, preferredEdge: .maxX, behavior: NSPopover.Behavior.transient)
    }
    @IBAction func clickedHelpMenuItem(_ sender: NSMenuItem) {
        print("帮助")
    }
}
