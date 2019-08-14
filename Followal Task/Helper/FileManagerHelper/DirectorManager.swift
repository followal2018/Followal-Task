//
//  DirectorManager.swift
//  followal
//
//  Created by Vivek Gadhiya on 10/03/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import Foundation

class Directory {
    
    static func createPath(_ fileType: AttachmentType, fileName: String, isSender: Bool = false) -> URL {
        
        var fileURL: URL!
        
        if isSender {
            fileURL = getPathOf(fileType).appendingPathComponent("Sent").appendingPathComponent(fileName)
        } else {
            fileURL = getPathOf(fileType).appendingPathComponent(fileName)
        }
        createIntermediate(path: fileURL.path)
        return fileURL
    }

    static func getRooPath() -> URL {
        return FileManagerHelper.getDocumentsDirectory().appendingPathComponent("Followal")
    }
    
    static func getStatusPath(_ name: String) -> URL {
        var statusPath = getRooPath().appendingPathComponent("Status")
        statusPath.appendPathComponent(name)
        createIntermediate(path: statusPath.path)
        print(FileManagerHelper.getAllFiles())
        return statusPath
    }
    
    static func getPathOf(_ fileType: AttachmentType) -> URL {
        if fileType == .document {
            return getRooPath().appendingPathComponent("Document")
        } else if fileType == .audio {
            return getRooPath().appendingPathComponent("Audio")
        } else if fileType == .image {
            return getRooPath().appendingPathComponent("Image")
        } else if fileType == .video {
            return getRooPath().appendingPathComponent("Video")
        }
        return getRooPath()
    }
    
    static func createIntermediate(path: String) {
        let directory = (path as NSString).deletingLastPathComponent
        if (exist(path: directory) == false) {
            create(directory: directory)
        }
    }
    
    static func exist(path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
    
    static func create(directory: String) {
        do {
            try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
