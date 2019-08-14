//
//  FileType + Extension.swift
//  followal
//
//  Created by Vivek Gadhiya on 15/03/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import Foundation
import MobileCoreServices

extension URL {
    
    func getFileType() -> String? {
        
        let ext = self.pathExtension.lowercased()

        let videoType = ["3g2","3gp","avi","flv","h264","m4v","mkv","mov","mp4","mpg","mpeg","rm","swf","vob","wmv"]
        if videoType.contains(ext) {
            return "video"
        }
        
        let audioType = ["aac","aif", "cda", "mid", "mp3", "mpa", "ogg", "wav", "wma", "wpl"]
        if audioType.contains(ext) {
            return "audio"
        }
        
        let imageType = ["ai","bmp","gif","ico","jpeg","jpg","png","ps","psd","svg","tif","tiff"]
        if imageType.contains(ext) {
            return "image"
        }
  
        let excelType = ["ods", "xlr", "xls", "xlsx"]
        if excelType.contains(ext) {
            return "excel"
        }
        
        let zipType = ["7z","arj","deb","pkg","rar","rpm","tar.gz","z","zip"]
        if zipType.contains(ext) {
            return "zip"
        }
        
        if ext == "txt" {
            return "text"
        }

        if ext == "pdf" {
            return "pdf"
        }
        
        let docType = ["doc","docx","odt","rtf","wpd","wps", "tex", "wks"]
        if docType.contains(ext)  {
            return "word"
        }
        
        return nil
    }
    
}
