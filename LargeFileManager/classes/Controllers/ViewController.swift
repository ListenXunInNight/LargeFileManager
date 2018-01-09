//
//  ViewController.swift
//  LargeFileManager
//
//  Created by xun on 2018/1/8.
//  Copyright © 2018年 xun. All rights reserved.
//

import Cocoa

enum Status {
    
    case compositing    //!< 正在组装
    case composited     //!< 组装完成
    case dividing       //!< 正在切割
    case divided        //!< 切割完成
    case free           //!< 空闲状态
}

class ViewController: NSViewController, DragDropViewDelegate, HandelFileDelegate {
    
    @IBOutlet weak var dragDropView: DragDropView!
    @IBOutlet weak var addBtn: NSButton!
    @IBOutlet weak var activityIncicator: NSProgressIndicator!
    @IBOutlet weak var infoLab: NSTextField!
    @IBOutlet weak var fileLab: NSTextField!
    
    var status: Status = .free
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dragDropView.delegate = self
        updateStatus(status: .free)
    }
    
    override func viewWillLayout() {
        super.viewWillLayout()
        
        self.setupActivityIncicator()
    }
    
    override var representedObject: Any? {
        didSet {
            
        }
    }

    @IBAction func clickedAddBtn(_ sender: NSButton) {
        
        let panel = NSOpenPanel.FilePanel()
        weak var weakpanel = panel
        panel.beginSheetModal(for: NSApplication.shared.keyWindow!) { (response) in
            
            guard weakpanel!.urls.count != 0 else {return}
            var paths = [String]()
            
            for url in weakpanel!.urls {
                paths.append(url.path)
            }
            self.dragDropFile(paths: paths, inView: self.dragDropView)
        }
    }
    
    func alert(msg: String, style: NSAlert.Style) {
        
        let alert = NSAlert()
        
        alert.alertStyle = style
        alert.addButton(withTitle: "知道了")
        alert.messageText = msg
        
        DispatchQueue.main.async {
            alert.beginSheetModal(for: NSApplication.shared.windows.first!, completionHandler: nil)
        }
    }
    
    // MARK: - UI
    func setupActivityIncicator() {
        
        activityIncicator.controlSize = .regular
        activityIncicator.usesThreadedAnimation = true
    }
    
    func updateStatus(status: Status) {
        self.status = status
        
        DispatchQueue.main.async {
            switch status {
            case .free:
                self.addBtn.isHidden = false
                self.infoLab.isHidden = true
                self.fileLab.isHidden = true
                self.dragDropView.isHidden = false
                self.activityIncicator.stopAnimation(nil)
                break
            case .compositing:
                self.addBtn.isHidden = true
                self.infoLab.isHidden = false
                self.fileLab.isHidden = false
                self.dragDropView.isHidden = true
                self.activityIncicator.startAnimation(nil)
                self.infoLab.stringValue = "正在组装..."
                break
            case .composited:
                self.alert(msg: self.fileLab.stringValue + "已组装完成", style: .informational)
                self.updateStatus(status: .free)
                break
            case .dividing:
                self.addBtn.isHidden = true
                self.infoLab.isHidden = false
                self.fileLab.isHidden = false
                self.dragDropView.isHidden = true
                self.activityIncicator.startAnimation(nil)
                self.infoLab.stringValue = "正在切割..."
                break
            case .divided:
                self.alert(msg: self.fileLab.stringValue + "已切割完成", style: .informational)
                self.updateStatus(status: .free)
                break
            }
        }
    }
    
    func updateFileLab(file: String) {
        DispatchQueue.main.async {
            self.fileLab.stringValue = (file as NSString).lastPathComponent
        }
    }
    
    // MARK: - DragDropViewDelegate
    func dragDropFile(paths: [String], inView: DragDropView) {
        
        DispatchQueue.global().async {
            
            for path in paths {
                do {
                    try FileManager.default.handlerFile(path: path, delegate: self)
                }
                catch {
                    switch error {
                    case ComponentsError.noneConfig:
                        self.alert(msg: path + "缺少配置文件", style: .critical)
                        self.updateStatus(status: .free)
                        break
                    case ComponentsError.littleFile:
                        self.updateFileLab(file: path)
                        self.alert(msg: path + "文件太小，无需切割", style: .informational)
                        self.updateStatus(status: .free)
                        break
                    case ComponentsError.errorComponents:
                        self.updateFileLab(file: path)
                        self.alert(msg: path + "文件切片错误", style: .critical)
                        self.updateStatus(status: .free)
                        break
                    case ComponentsError.lostComponents:
                        self.alert(msg: path + "遗失文件切片", style: .critical)
                        self.updateStatus(status: .free)
                        break
                    default:
                        self.updateStatus(status: .free)
                        break
                    }
                }
            }
        }
    }
    
    // MARK: - HandelFileDelegate
    
    func startDivideFile(file: String) {
        updateFileLab(file: file)
        updateStatus(status: .dividing)
    }
    func endDivideFile(file: String) {
        updateFileLab(file: file)
        updateStatus(status: .divided)
    }
    
    func startCompositFile(file: String) {
        updateFileLab(file: file)
        updateStatus(status: .compositing)
    }
    func endCompositFile(file: String) {
        updateFileLab(file: file)
        updateStatus(status: .composited)
    }
}

