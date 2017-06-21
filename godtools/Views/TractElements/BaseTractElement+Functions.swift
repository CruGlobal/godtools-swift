//
//  BaseTractElement+Functions.swift
//  godtools
//
//  Created by Devserker on 5/1/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

extension BaseTractElement {
    
    func buildElementForDictionary(_ data: XMLIndexer, startOnY yPosition: CGFloat) -> BaseTractElement {
        let xmlManager = XMLManager()
        let nodeClassType = xmlManager.parser.getNodeClass(data)
        
        if nodeClassType == TractModals.self || nodeClassType == TractEmails.self || nodeClassType == TractEmail.self {
            return nodeClassType.init(data: data, parent: self)
        } else {
            return nodeClassType.init(data: data, startOnY: yPosition, parent: self)
        }
    }
    
    func buildScaledImageView(parentView: UIView, image: UIImage, aligns: [TractImageConfig.ImageAlign], scaleType: TractImageConfig.ImageScaleType) -> UIImageView {
        let viewWidth = parentView.frame.size.width
        let viewHeight = parentView.frame.size.height
        let viewRatio = viewWidth / viewHeight
        var imageWidth = image.size.width
        var imageHeight = image.size.height
        let imageRatio = imageWidth / imageHeight
        
        let imageView = UIImageView(image: image)
        
        if viewRatio == imageRatio {
            imageWidth = viewWidth
            imageHeight = viewHeight
        } else {
            switch scaleType {
            case .fill:
                if viewRatio > imageRatio {
                    imageHeight = imageHeight * viewWidth / imageWidth
                    imageWidth = viewWidth
                } else {
                    imageWidth = imageWidth * viewHeight / imageHeight
                    imageHeight = viewHeight
                }
            case .fit:
                if viewRatio > imageRatio {
                    imageWidth = imageWidth * viewHeight / imageHeight
                    imageHeight = viewHeight
                } else {
                    imageHeight = imageHeight * viewWidth / imageWidth
                    imageWidth = viewWidth
                }
            case .fillX:
                imageHeight = imageHeight * viewWidth / imageWidth
                imageWidth = viewWidth
            case .fillY:
                imageWidth = imageWidth * viewHeight / imageHeight
                imageHeight = viewHeight
            }
        }
        
        var xPosition: CGFloat = 0.0
        var yPosition: CGFloat = 0.0
        
        if aligns.contains(.top) {
            yPosition = 0.0
        } else if aligns.contains(.bottom) {
            yPosition = viewHeight - imageHeight
        }
        
        if aligns.contains(.end) {
            xPosition = viewWidth - imageWidth
        } else if aligns.contains(.start) {
            xPosition = 0.0
        }
        
        if aligns.contains(.center) {
            xPosition = (viewWidth - imageWidth) / CGFloat(2.0)
            yPosition = (viewHeight - imageHeight) / CGFloat(2.0)
        }
        
        imageView.frame = CGRect(x: xPosition,
                                 y: yPosition,
                                 width: imageWidth,
                                 height: imageHeight)
        return imageView
    }
    
    func elementListeners() -> [String]? {
        return nil
    }
    
    func elementDismissListeners() -> [String]? {
        return nil
    }
    
    func sendMessageToElement(listener: String) {
        if TractBindings.bindings[listener] != nil {
            guard let view = TractBindings.bindings[listener] else { return }
            view.receiveMessage()
        }
        
        if TractBindings.dismissBindings[listener] != nil {
            guard let view = TractBindings.dismissBindings[listener] else { return }
            view.receiveDismissMessage()
        }
        
        if TractBindings.pageBindings[listener] != nil {
            NotificationCenter.default.post(name: .moveToPageNotification, object: nil, userInfo: ["pageListener": listener])
        }
    }
    
    func receiveMessage() { }
    
    func receiveDismissMessage() { }
    
}
