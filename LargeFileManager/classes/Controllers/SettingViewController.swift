//
//  SettingViewController.swift
//  LargeFileManager
//
//  Created by xun on 2018/1/9.
//  Copyright © 2018年 xun. All rights reserved.
//

import Cocoa

class SettingViewController: NSViewController, NSTextFieldDelegate {

    @IBOutlet weak var slider: NSSlider!
    @IBOutlet weak var sizeLab: NSTextField!
    lazy var numberFormatter: NumberFormatter = {
        
        let formatter = NumberFormatter()
        
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.positiveSuffix = "MB"
        
        return formatter
    }()

    var sizes: [UInt64] = [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        slider.floatValue = getFloatValue()
        self.sliderValueChanged(slider)
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        UserDefaults.standard.sliceSize = UInt64(Float(FileManager.MB) * numberFormatter.number(from: sizeLab.stringValue)!.floatValue)
        UserDefaults.standard.synchronize()
    }
    
    @IBAction func sliderValueChanged(_ sender: NSSlider) {
        
        let sizeLevel = Int(sender.intValue)
        let size = Float(Int(sizes[sizeLevel]))
        let percent = sender.floatValue - Float(sender.intValue)
        
        sizeLab.stringValue = numberFormatter.string(from: NSNumber(value: size + size * percent))!
    }
    
    private func getFloatValue() -> Float {
        
        let sliceSize = UserDefaults.standard.sliceSize
        
        guard sliceSize != nil else {return Float(5.0)}
        
        let mb = sliceSize! / FileManager.MB
        
        var level = 0
        
        for size in sizes {
            if size <= mb / 2 {level += 1}
            else {break}
        }
        
        return Float(level) + Float(Float(mb / sizes[level]) - Float(1))
    }
}

extension UserDefaults {
    
    var sliceSize: UInt64? {
        
        get {return value(forKey: "SegmentSize") as? UInt64}
        set {
            setValue(newValue, forKey: "SegmentSize")
        }
    }
}
