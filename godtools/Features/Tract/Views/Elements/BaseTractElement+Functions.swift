//
//  BaseTractElement+Functions.swift
//  godtools
//
//  Created by Devserker on 5/1/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

enum EventResult {
    case success, failure, viewNotFound
}

extension BaseTractElement {
    
    func buildElementForDictionary(_ data: XMLIndexer, startOnY yPosition: CGFloat, elementNumber: Int) -> BaseTractElement {
        
        let xmlManager = XMLManager()
        let nodeClassType = xmlManager.parser.getNodeClass(data)
        
        if let restrictToText = data.element?.allAttributes["restrictTo"]?.text {
            if !restrictToText.isEmpty && !restrictToText.contains("mobile") {
                //return nil
            }
        }
        
        if nodeClassType == TractModals.self ||
            nodeClassType == TractEmails.self ||
            nodeClassType == TractEmail.self {
            
            return nodeClassType.init(data: data, parent: self)
        }
        else {
            return nodeClassType.init(data: data, startOnY: yPosition, parent: self, elementNumber: elementNumber)
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
        
        var xPosition: CGFloat = (viewWidth - imageWidth) / CGFloat(2.0)
        var yPosition: CGFloat = (viewHeight - imageHeight) / CGFloat(2.0)
        
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
        
        imageView.frame = CGRect(x: xPosition,
                                 y: yPosition,
                                 width: imageWidth,
                                 height: imageHeight)
        return imageView
    }
    
    @objc func elementListeners() -> [String]? {
        return nil
    }
    
    @objc func elementDismissListeners() -> [String]? {
        return nil
    }
    
    func sendMessageToElement(listener: String) -> EventResult {
        let relay = AnalyticsRelay.shared
        if TractBindings.bindings[listener] != nil {
            guard let view = TractBindings.bindings[listener] else { return .viewNotFound }
            view.receiveMessage()
            relay.viewListener = listener
        }
        
        if TractBindings.dismissBindings[listener] != nil {
            guard let view = TractBindings.dismissBindings[listener] else { return .viewNotFound }
            view.receiveDismissMessage()
            relay.viewListener = listener
        }
        
        if TractBindings.pageBindings[listener] != nil {
            NotificationCenter.default.post(name: .moveToPageNotification, object: nil, userInfo: ["pageListener": listener])
            relay.viewListener = listener
        }
        
        return GTGlobalTractBindings.listen(listener: listener, element: self)        
    }
    
    @objc func receiveMessage() { }
    
    @objc func receiveDismissMessage() { }
    
    func getParentCard() -> TractCard? {
        return BaseTractElement.getParentCardForElement(self)
    }
    
    func inspectImage(data: XMLIndexer) -> Bool {
        guard let imageAttributes = data.element?.allAttributes else { return true }
        
        var imageDictionary = [String: String]()
        for (_, dictionary) in (imageAttributes.enumerated()) {
            imageDictionary[dictionary.key] = dictionary.value.text
        }
        
        guard let imageValue = imageDictionary["restrictTo"] else { return true }
        
        return imageValue.contains("mobile")
    }
    
    func filteredNonMobileElement(element: BaseTractElement) -> BaseTractElement {
        element.elementFrame.height = 0
        element.elementFrame.yMarginTop = 0
        element.elementFrame.yMarginBottom = 0
        element.isHidden = true
        return element
    }
    
    // MARK: - Form Functions
    
    func attachToForm() {
        if let form = BaseTractElement.getFormForElement(self) {
            form.attachElementToForm(element: self)
        }
    }
    
    @objc func formName() -> String {
        return ""
    }
    
    @objc func formValue() -> String {
        return ""
    }
}
