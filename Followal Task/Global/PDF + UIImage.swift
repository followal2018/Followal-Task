//
//  PDF + UIImage.swift
//  followal
//
//  Created by Vivek Gadhiya on 12/02/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    static func fromPDF(filename: String, size: CGSize) -> UIImage? {
        guard let path = Bundle.main.path(forResource: filename, ofType: "pdf") else { return nil }
        let url = URL(fileURLWithPath: path)
        guard let document = CGPDFDocument(url as CFURL) else { return nil }
        guard let page = document.page(at: 1) else { return nil }
        
        let imageRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(size: size)
            let img = renderer.image { ctx in
                UIColor.white.withAlphaComponent(0).set()
                ctx.fill(imageRect)
                ctx.cgContext.translateBy(x: 0, y: size.height)
                ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
                ctx.cgContext.concatenate(page.getDrawingTransform(.artBox, rect: imageRect, rotate: 0, preserveAspectRatio: true))
                ctx.cgContext.drawPDFPage(page);
            }
            
            return img
        } else {
            // Fallback on earlier versions
            UIGraphicsBeginImageContextWithOptions(size, false, 2.0)
            if let context = UIGraphicsGetCurrentContext() {
                context.interpolationQuality = .high
                context.setAllowsAntialiasing(true)
                context.setShouldAntialias(true)
                context.setFillColor(red: 1, green: 1, blue: 1, alpha: 0)
                context.fill(imageRect)
                context.saveGState()
                context.translateBy(x: 0.0, y: size.height)
                context.scaleBy(x: 1.0, y: -1.0)
                context.concatenate(page.getDrawingTransform(.cropBox, rect: imageRect, rotate: 0, preserveAspectRatio: true))
                context.drawPDFPage(page)
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                return image
            }
            return nil
        }
    }
}


extension UIButton {
    
    static func with(pdf image: String, size: CGSize) -> UIButton {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        btn.setImage(UIImage.fromPDF(filename: image, size: size), for: .normal)
        return btn
    }
    
    static func barButton(pdf image: UIImage?) -> (UIBarButtonItem, UIButton) {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        btn.setImage(image?.resized(toWidth: 22), for: .normal)
        return (UIBarButtonItem(customView: btn), btn)
    }
}
