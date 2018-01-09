//
//  DragDropView.swift
//  LargeFileManager
//
//  Created by xun on 2018/1/8.
//  Copyright © 2018年 xun. All rights reserved.
//

import Cocoa

protocol DragDropViewDelegate {
    
    func dragDropFile(paths: [String], inView: DragDropView)
}

class DragDropView: NSView {

    var delegate: DragDropViewDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
    registerForDraggedTypes([NSPasteboard.PasteboardType("NSFilenamesPboardType")])
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        
        let pasteboard = sender.draggingPasteboard()
        
        if (pasteboard.types?.contains(NSPasteboard.PasteboardType("NSFilenamesPboardType")))! {
          
            return .copy
        }
        return NSDragOperation.init(rawValue: 0)
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return true
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        
        let pboard = sender.draggingPasteboard()
        
        let list: Any? = pboard.propertyList(forType: NSPasteboard.PasteboardType("NSFilenamesPboardType"))
        
        delegate?.dragDropFile(paths: (list as! [String]), inView: self)
        
        return true
    }
}
