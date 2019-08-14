//
//  FolderRequest.swift
//  Followal Task
//
//  Created by iMac on 31/07/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import SwiftyJSON


class FolderRequest : Codable {
    
    var folderName = ""
    var folderID = ""

    enum CodingKeys: String, CodingKey {
        case folderName = "FolderName"
        case folderID = "FolderID"

        
    }
}
class DeleteFolderRequest : Codable {
    
    var folderID = ""
    
    enum CodingKeys: String, CodingKey {
        case folderID = "FolderID"
        
        
    }
}

class DeleteTaskRequest : Codable {
    
    var taskLocalId = ""
    
    enum CodingKeys: String, CodingKey {
        case taskLocalId = "TaskLocalId"
        
        
    }
}

class DeleteCommentRequest : Codable {
    
    var commentId = ""
    var taskId = ""

    enum CodingKeys: String, CodingKey {
        case commentId = "CommentId"
        case taskId = "TaskId"

        
    }
}


class FolderList : Codable {
    
    
}

