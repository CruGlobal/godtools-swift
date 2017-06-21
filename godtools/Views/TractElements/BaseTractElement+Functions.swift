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
        var width = image.size.width
        var height = image.size.height
        
        let imageView = UIImageView(image: image)
        
        switch scaleType {
        case .fill:
            width = viewWidth
            height = viewHeight
            imageView.contentMode = .scaleAspectFill
        case .fit:
            width = viewWidth
            height = viewHeight
            imageView.contentMode = .scaleAspectFit
        case .fillX:
            height = height * viewWidth / width
            width = viewWidth
        case .fillY:
            width = width * viewHeight / height
            height = viewHeight
        }
        
        var xPosition: CGFloat = 0.0
        var yPosition: CGFloat = 0.0
        
        if aligns.contains(.top) {
            yPosition = 0.0
        } else if aligns.contains(.bottom) {
            yPosition = viewHeight - height
        }
        
        if aligns.contains(.end) {
            xPosition = viewWidth - width
        } else if aligns.contains(.start) {
            xPosition = 0.0
        }
        
        if aligns.contains(.center) {
            xPosition = (viewWidth - width) / CGFloat(2.0)
            yPosition = (viewHeight - height) / CGFloat(2.0)
        }
        
        imageView.frame = CGRect(x: xPosition,
                                 y: yPosition,
                                 width: width,
                                 height: height)
        
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
