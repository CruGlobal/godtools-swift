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
        
        if nodeClassType == TractModals.self ||
            nodeClassType == TractEmails.self ||
            nodeClassType == TractEmail.self {
            
            return nodeClassType.init(data: data, parent: self, dependencyContainer: dependencyContainer, isPrimaryRightToLeft: isPrimaryRightToLeft)
        }
        else {
            let element = nodeClassType.init(data: data, startOnY: yPosition, parent: self, elementNumber: elementNumber, dependencyContainer: dependencyContainer, isPrimaryRightToLeft: isPrimaryRightToLeft)
            return element
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
        
        switch listener {
        
        case "followup:send":
                        
            guard let form = BaseTractElement.getFormForElement(self) else {
                return .viewNotFound
            }
            
            if(!form.validateForm()) {
                return .failure
            }
            
            let params = form.getFormData()
            
            let name: String? = params["name"]
            let email: String? = params["email"]
            let destinationId: Int?
            let languageId: Int?
            
            if let destinationIdString = params["destination_id"] {
                destinationId = Int(destinationIdString)
            }
            else {
                destinationId = nil
            }
            
            if let languageIdString = params["language_id"] {
                languageId = Int(languageIdString)
            }
            else {
                languageId = nil
            }
            
            if let name = name, let email = email, let destinationId = destinationId, let languageId = languageId {
                
                let followUp = FollowUpModel(
                    name: name,
                    email: email,
                    destinationId: Int(destinationId),
                    languageId: Int(languageId)
                )
                
                _ = dependencyContainer.followUpsService.postNewFollowUp(followUp: followUp)
            }
            
            if let resource = form.tractConfigurations?.resource {
                
                let action: String?
                
                switch resource.abbreviation {
                case "kgp":
                    action = AdobeAnalyticsConstants.Values.kgpEmailSignUp
                case "fourlaws":
                    action = AdobeAnalyticsConstants.Values.fourLawsEmailSignUp
                default :
                    action = nil
                }
                
                if let actionName = action {
                    
                    dependencyContainer.analytics.trackActionAnalytics.trackAction(
                        screenName: nil,
                        actionName: actionName,
                        data: [:]
                    )
                }
            }
            
        default: break

        }
        
        return .success
    }
    
    @objc func receiveMessage() { }
    
    @objc func receiveDismissMessage() { }
    
    func getParentCard() -> TractCard? {
        return BaseTractElement.getParentCardForElement(self)
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
