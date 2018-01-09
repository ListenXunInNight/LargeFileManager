//
//  FileManager.swift
//  LargeFileManager
//
//  Created by xun on 2018/1/8.
//  Copyright © 2018年 xun. All rights reserved.
//

import Foundation
import SwiftyJSON

class File {
    
    let name: String
    let size: UInt64
    var components: [File]? = nil
    
    init(name: String, size: UInt64) {
        self.name = name
        self.size = size
    }
    
    static let noneFile = File()
    
    private convenience init() {
        self.init(name: "", size: 0)
    }
}

extension File {
    convenience init(json: JSON) {
        
        let dict = json.dictionaryValue
        
        let name = dict["name"]!.stringValue
        let size = dict["size"]!.uInt64Value
        
        self.init(name: name, size: size)
    }
    
    func jsonString() -> String {
        
        var json = "{"
        
        json += "\"name\": "
        json += "\"\(name)\","
        
        json += "\"size\": "
        json += "\(size)"
        
        if components != nil {
            
            json += ",\"components\": ["
            
            for file in components! {
                json += file.jsonString()
                json += ","
            }
            json.remove(at: json.index(before: json.endIndex))
            json += "]"
        }
        
        json += "}"
        
        return json
    }
    
    func valid() -> Bool {
        
        var size: UInt64 = 0
        for component in components! {
            size += component.size
            
            if !component.CRC32Valid() {return false}
        }
        
        return size == self.size
    }
    
    private func CRC32Valid() -> Bool {
        
        return true
    }
}

enum ComponentsError: Error {
    
    /// 丢失切片
    case lostComponents
    /// 切片错误
    case errorComponents
    /// 没有配置文件
    case noneConfig
    /// 文件太小
    case littleFile
}

protocol HandelFileDelegate {
    
    func startDivideFile(file: String)
    func endDivideFile(file: String)
    
    func startCompositFile(file: String)
    func endCompositFile(file: String)
}

extension FileManager {
    
    static let ConfigFilePath = "config.ini"
    
    static let MB: UInt64 = 1024 * 1024
    static var sliceSize:UInt64  {
        get {
            if UserDefaults.standard.sliceSize == nil {
                return 50 * MB
            }
            return UserDefaults.standard.sliceSize!
        }
    }
    
    func handlerFile(path: String, delegate:HandelFileDelegate) throws {
        
        guard self.fileExists(atPath: path) else {
            return
        }
        
        let attribute = try! attributesOfItem(atPath: path)
        
        let string = attribute[FileAttributeKey("NSFileType")] as! String
        
        if string == "NSFileTypeDirectory" {
            delegate.startCompositFile(file: path)
            try compositFiles(directory: path)
            delegate.endCompositFile(file: path)
        }
        else {
            delegate.startDivideFile(file: path)
            try divideFile(path: path)
            delegate.endDivideFile(file: path)
        }
    }
    
    func divideFile(path: String) throws {
        
        let attribute = try! self.attributesOfItem(atPath: path)
        
        let size = attribute[FileAttributeKey("NSFileSize")]! as! UInt64
        
        if size <= FileManager.sliceSize {
            throw ComponentsError.littleFile
        }
        
        let nsstring = path as NSString
        let directory = nsstring.deletingPathExtension
        
        try! self.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
        
        var offset: UInt64 = 0
        
        let fh = FileHandle(forReadingAtPath: path)!
        
        var index = 0
        
        let sliceSize = FileManager.sliceSize
        
        let file = File(name: nsstring.lastPathComponent, size:size)
        file.components = [File]()
        
        repeat {

            let component = File(name: "slice_" + "\(index)", size: sliceSize)
            file.components?.append(component)
            
            let data = fh.readData(ofLength: Int(sliceSize))
            
            try! data.write(to: URL(fileURLWithPath: directory + "/" + component.name))
            
            index += 1
            offset += sliceSize
            
            fh.seek(toFileOffset: offset)
            
        } while offset < size - sliceSize
        
        let component = File(name: "slice_" + "\(index)", size: size - offset)
        file.components?.append(component)
        
        try! fh.readDataToEndOfFile().write(to: URL(fileURLWithPath: directory + "/" + component.name))
        fh.closeFile()
        
        try! file.jsonString().write(to: URL(fileURLWithPath: directory + "/" + FileManager.ConfigFilePath), atomically: true, encoding: String.Encoding.utf8)
    }
    
    func compositFiles(directory: String) throws {
        
        let file = try prepareCompositFiles(directory: directory)
        
        if file.valid() {
            
            let path = directory + "/" + file.name
            
            self.createFile(atPath: path, contents: nil, attributes: nil)
            
            let fh = FileHandle(forWritingAtPath: path)!
            
            for component in file.components! {
                
                let componentPath = directory + "/" + component.name
                
                let componentFH = FileHandle(forReadingAtPath: componentPath)!
                
                fh.write(componentFH.availableData)
                
                componentFH.closeFile()
                
                fh.seekToEndOfFile()
            }
            
            fh.closeFile()
        }
        else {
            throw ComponentsError.errorComponents
        }
    }
    
    private func prepareCompositFiles(directory: String) throws -> File {
        
        let configPath = directory + "/" + FileManager.ConfigFilePath
        
        guard self.fileExists(atPath: configPath) else {
            throw ComponentsError.noneConfig
        }
        
        let config = try! String(contentsOfFile: configPath)
        
        let json = JSON(parseJSON: config)
    
        let file = File(json: json)
    
        var components = [File]()
        
        for jsonDict in json["components"].arrayValue {
            
            components.append(File(json: jsonDict))
        }
        
        file.components = components
        
        return file
    }
}
