//
//  Attachment.swift
//  Followal Task
//
//  Created by iMac on 17/07/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import ObjectMapper
import RealmSwift
import CoreServices
@objc enum AttachmentType: Int {
    
    case document = 0
    case image = 1
    case video = 2
    case audio = 3
    
    static func getAttchmentType(_ string: String) -> AttachmentType {
        
        switch string {
        case "Document":
            return .document
            
        case "Image":
            return .image
            
        case "Video":
            return .video
            
        case "Audio":
            return .audio
            
        default:
            return .image
        }
    }
    
    func getAttchmentType(_ type: AttachmentType) -> String {
        switch type {
        case .document:
            return "Document"
            
        case .image:
            return "Image"
            
        case .video:
            return "Video"
            
        case .audio:
            return "Audio"
            
        }
    }
}

extension AttachmentType {
    var textValue: String {
        if self.rawValue == 0 {
            return "Document"
        } else if self.rawValue == 1 {
            return "Image"
        } else if self.rawValue == 2 {
            return "Video"
        } else if self.rawValue == 3 {
            return "Audio"
        }
        
        return "Image"
    }
}
@objc enum AttachmentStatus: Int {
    case pending = 0
    case uploaded = 1
    case uploading = 2
    case cancel = 3
    case downloading = 4
    case downloaded = 5
    
    var label:String? {
        let mirror = Mirror(reflecting: self)
        return mirror.children.first?.label
    }
}
class Attachment: Object, Mappable {
    
    @objc dynamic var fileName: String = ""
    @objc dynamic var filePath: String = ""
    @objc dynamic var fileURL: String = ""
    
    @objc dynamic var temporaryPath: String = ""
    @objc dynamic var fileType: AttachmentType = .document
    @objc dynamic var fileSize: Int = 0
    @objc dynamic var caption: String = ""
    @objc dynamic var imageByte: String = ""
    @objc dynamic var status: AttachmentStatus = .pending
    @objc dynamic var progress: Double = 0.0
    @objc dynamic var pages: Int = 0
    
    
    required convenience init?(map: Map) {
        self.init()
    }
    func mapping(map: Map) {
        fileURL <- map["fileUrl"]
        status = .pending
        pages <- map["pages"]
        imageByte <- map["imageByte"]
        caption <- map["caption"]
        fileType = AttachmentType.getAttchmentType(map["fileType"].currentValue as? String ?? "0")
        fileSize = Int(map["fileSize"].currentValue as? String ?? "0") ?? 0
        if fileSize == 0 {
            fileSize = map["fileSize"].currentValue as? Int ?? 0
        }
        fileName <- map["fileName"]
        
    }
    
    func formattedFileSize() -> String {
        let strFileSize = String().formateFileSize(byteCount: fileSize)
        return strFileSize == "0 B" ? "" : strFileSize
    }
    
    func mimeTypeOf(filePath: String) -> String {
        let url = NSURL(fileURLWithPath: filePath)
        let pathExtension = url.pathExtension
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension! as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
    
    var isPDFDocument: Bool {
        return mimeTypeOf(filePath: filePath.isEmpty ? fileURL : filePath) == "application/pdf"
    }
    
    func getPageCount() -> Int {
        if isPDFDocument {
            if filePath.isEmpty {
                return pages
            } else {
                let url = filePath.toURL()!
                return CGPDFDocument.init(url as CFURL)?.numberOfPages ?? 0
            }
        }
        return 0
    }
    
    func getFileType() -> String? {
        return (filePath.isEmpty ? fileURL : filePath).toURL()?.getFileType()
    }
}
