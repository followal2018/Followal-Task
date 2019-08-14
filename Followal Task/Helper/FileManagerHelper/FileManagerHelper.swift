//
//  FileManagerHelper.swift
//  RXdemo
//
//  Created by om on 3/1/18.
//  Copyright © 2018 Dignizant. All rights reserved.
//

import Foundation

class FileManagerHelper {
    
    static var documentDirectoryPath: String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    }
    
   static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    static func searchFile(with name: String) -> URL? {
        
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        let enumerator = FileManager.default.enumerator(atPath: documentDirectoryPath)
        let filePaths = enumerator?.allObjects as? [String]
        if let strName = name.removingPercentEncoding{
            if let file = (filePaths?.filter{$0.contains(strName)})?.first {
                 return FileManagerHelper.getDocumentsDirectory().appendingPathComponent(file)
            }
        }

        return nil
    }
    
    static func isFileExist(_ name: String) -> Bool {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent(name) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                return true
            } else {
                print("FILE NOT AVAILABLE")
            }
        } else {
            print("FILE PATH NOT AVAILABLE")
        }
        return false
    }
    
   static func rootUnzipPath() -> String? {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        let url = URL(fileURLWithPath: path)
        
        return url.path
    }
    
    static func getAllFiles() -> [Any] {
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!

        let files = FileManager.default.enumerator(atPath: documentDirectoryPath)
        
        var fileArray: [Any] = []
        
        while let file = files?.nextObject() {
            fileArray.append(file)
        }
        
        return fileArray
    }
    
    static func clearAllFile() {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: getDocumentsDirectory().appendingPathComponent("Followal", isDirectory: true))
        } catch {
            return
        }
    }
    
    static func writeFile(at url: URL, data: Data) {
        do {
            try data.write(to: url)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    static func writeFile(with name: String, data: Data) -> URL {
        let writeURL = getDocumentsDirectory().appendingPathComponent(name)
        
        do {
            try data.write(to: writeURL)
        } catch {
            print(error.localizedDescription)
        }
        
        return writeURL
    }
    
    static func renameFileName(oldName: String, newName: String) {
        do {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let documentDirectory = URL(fileURLWithPath: path)
            let originPath = documentDirectory.appendingPathComponent(oldName)
            let destinationPath = documentDirectory.appendingPathComponent(newName)
            try FileManager.default.moveItem(at: originPath, to: destinationPath)
        } catch {
            print(error)
        }
    }
    
    static func renameFileName(at urlPath: String, oldName: String, newName: String) {
        do {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let documentDirectory = URL(fileURLWithPath: path).appendingPathComponent(urlPath)
            let originPath = documentDirectory.appendingPathComponent(oldName)
            let destinationPath = documentDirectory.appendingPathComponent(newName)
            try FileManager.default.moveItem(at: originPath, to: destinationPath)
        } catch {
            print(error)
        }
    }
    
   static func copyFile(at srcURL: URL, to dstURL: URL) -> Bool {
        do {
            if FileManager.default.fileExists(atPath: dstURL.path) {
                try FileManager.default.removeItem(at: dstURL)
            }
            try FileManager.default.copyItem(at: srcURL, to: dstURL)
        } catch (let error) {
            print("Cannot copy item at \(srcURL) to \(dstURL): \(error)")
            return false
        }
        return true
    }
    
}
