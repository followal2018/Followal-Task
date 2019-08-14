//
//  PHAsset + Extension.swift
//  followal
//
//  Created by iMac on 22/05/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import Foundation
import Photos
import UIKit
extension PHAsset {
    
    func getThumbnailUIImage() -> UIImage? {
        
        var img: UIImage?
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .original
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true

        manager.requestImage(for: self, targetSize: CGSize(width: SCREEN_WIDTH/6, height: SCREEN_WIDTH/6), contentMode: .aspectFill, options: options) { (image, _) in
            if let image = image {
                img = image
            }
        }
        
        return img
    }
    
    func getUIImage() -> UIImage? {
        var img: UIImage?
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .current
        options.isSynchronous = true
        manager.requestImageData(for: self, options: options) { data, _, _, _ in
            if let data = data {
                img = UIImage(data: data)
            }
        }
        return img
    }
    
    func getUIImage(completion: @escaping (UIImage?) -> ()) {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .current
        options.deliveryMode = .fastFormat
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        options.isSynchronous = true
        //        let mytargetSize = CGSize(width: self.pixelWidth/4, height: self.pixelHeight/4)
        //
        //        let _ = manager.requestImage(for: self, targetSize: mytargetSize, contentMode: .aspectFill, options: options, resultHandler: {(result, info) in
        //            DispatchQueue.main.async {
        //                completion(result)
        //            }
        //
        //        })
        manager.requestImageData(for: self, options: options) { data, _, _, _ in
            if let data = data {
                completion(UIImage(data: data, scale: 1.0))
            } else {
                completion(nil)
            }
        }
    }
//    func getUIImage(completion: @escaping (UIImage?) -> ()) {
//        var img: UIImage?
//        let manager = PHImageManager.default()
//        let options = PHImageRequestOptions()
//        options.version = .current
//        options.deliveryMode = .fastFormat
//        options.resizeMode = .exact
//        options.isNetworkAccessAllowed = true
//        options.isSynchronous = true
//        let mytargetSize = CGSize(width: self.pixelWidth/4, height: self.pixelHeight/4)
//
//        let _ = manager.requestImage(for: self, targetSize: mytargetSize, contentMode: .aspectFill, options: options, resultHandler: {(result, info) in
//            DispatchQueue.main.async {
//                completion(result)
//            }
//
//        })
////        manager.requestImageData(for: self, options: options) { data, _, _, _ in
////            if let data = data {
////                DispatchQueue.main.async {
////                    completion(UIImage(data: data))
////                }
////            } else {
////                completion(nil)
////            }
////        }
//    }
    
    func getVideo() -> URL? {
        
        var url: URL?
        let manager = PHImageManager.default()
        let options = PHVideoRequestOptions()
        options.version = .original
        manager.requestAVAsset(forVideo: self, options: options) { (asset, mix, dic) in
            if(asset != nil)
            {
                let avAsset = asset as! AVURLAsset
                url = avAsset.url
            }
        }
        return url
    }
}
