//
//  TractButton.swift
//  godtools
//
//  Created by Devserker on 5/11/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit
import Crashlytics

class TractButton: BaseTractElement {
    
    // MARK: Positions constants
    
    static let standardMarginConstant: CGFloat = 24.0
    static let modalMarginConstant: CGFloat = 50.0
    static let textPaddingConstant: CGFloat = 8.0
    
    // MARK: - Object properties
    
    var button: GTButton = GTButton()
    
    // MARK: - Setup
    
    override func propertiesKind() -> TractProperties.Type {
        return TractButtonProperties.self
    }
    
    override func loadElementProperties(_ properties: [String: Any]) {
        super.loadElementProperties(properties)
        
        let properties = buttonProperties()
        properties.analyticsButtonUserInfo = self.analyticsUserInfo

        let pageProperties = page?.pageProperties()
        
        properties.backgroundColor = properties.buttonColor ?? pageProperties?.primaryColor ?? manifestProperties.primaryColor
    }
    
    override func loadStyles() {
        self.button = GTButton()
        if BaseTractElement.isModalElement(self) {
            configureAsModalButton()
        } else {
            configureAsStandardButton()
        }
        
        self.addTargetToButton()
        
        self.addSubview(self.button)
    }
    
    override func loadFrameProperties() {
        self.elementFrame.x = 0.0
        self.elementFrame.width = parentWidth()
        self.elementFrame.yMarginTop = 0
    }
    
    override func render() -> UIView {
        guard let elements = self.elements else { return self }
        
        for element in elements {
            if let textElement = element as? TractTextContent {
                let label = textElement.label
                
                if let text = label.text {
                    self.button.setTitle(text, for: .normal)
                    self.button.titleLabel?.font = label.font
                }
                let textColorProperty = buttonTextColor(localColor: textElement.textProperties().localTextColor)
                
                self.button.setTitleColor(textColorProperty, for: .normal)
                self.button.setTitleColor(textColorProperty.withAlphaComponent(0.5), for: .highlighted)
                
                self.button.titleLabel?.lineBreakMode = .byWordWrapping
                self.button.titleLabel?.textAlignment = .center
            } else {
                self.addSubview(element.render())
            }
            
        }
        
        TractBindings.addBindings(self)
        return self
    }
    
    func buttonTextColor(localColor: UIColor?) -> UIColor {
        return localColor ?? page?.pageProperties().primaryTextColor ?? manifestProperties.primaryTextColor
    }
    
    override func textStyle() -> TractTextContentProperties {
        let properties = self.properties.getTextProperties()
        properties.xMargin = TractButton.textPaddingConstant
        properties.yMargin = 0.0
        properties.height = 22.0
        return properties
    }
    
    // MARK: - Helpers
    
    func addTargetToButton() {
        let properties = buttonProperties()
        
        if properties.type == .event || properties.type == .url {
            self.button.addTarget(self, action: #selector(buttonTarget), for: .touchUpInside)
        }
    }
    
    func buttonProperties() -> TractButtonProperties {
        return self.properties as! TractButtonProperties
    }
}

// MARK: - Actions

@objc extension TractButton {

    func buttonTarget() {
        getParentCard()?.endCardEditing()
        let properties = buttonProperties()

        
        if properties.type == .event {
            let events = properties.events.components(separatedBy: " ")
            for analyticEvent in properties.analyticsButtonUserInfo {
                let userInfo = TractAnalyticEvent.convertToDictionary(from: analyticEvent)
                sendNotificationForAction(userInfo: userInfo)
            }
            for event in events {
                if sendMessageToElement(listener: event) == .failure {
                    break
                }
            }
        } else if properties.type == .url {
            let propertiesString = properties.url
            let stringWithProtocol = prependProtocolToURLStringIfNecessary(propertiesString)
            if let url = URL(string: stringWithProtocol) {
                var userInfo: [String: Any] = [AdobeAnalyticsProperties.CodingKeys.exitLink.rawValue: stringWithProtocol]
                userInfo["action"] = AdobeAnalyticsConstants.Values.exitLink
                sendNotificationForAction(userInfo: userInfo)
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    
    func sendNotificationForAction(userInfo: [String: Any]) {
        NotificationCenter.default.post(name: .actionTrackNotification,
                                        object: nil,
                                        userInfo: userInfo)
    }
    
    private func prependProtocolToURLStringIfNecessary(_ original: String) -> String {
        if original.hasPrefix("http://") || original.hasPrefix("https://") {
            return original
        }
        
        return "http://\(original)"
    }
}

// MARK: - UI

extension TractButton {
    
    func configureAsModalButton() {
        let properties = buttonProperties()
        let width = self.elementFrame.finalWidth() - (TractButton.modalMarginConstant * 2.0)
        let height = properties.height
        self.button.designAsTractModalButton()
        self.button.frame = CGRect(x: TractButton.modalMarginConstant,
                                   y: TractButton.modalMarginConstant,
                                   width: width,
                                   height: height)
        
        
        self.height = height + TractButton.modalMarginConstant
        updateFrameHeight()
    }
    
    func configureAsStandardButton() {
        let properties = buttonProperties()
        let width = self.elementFrame.finalWidth() - (TractButton.standardMarginConstant * 2.0)
        let height = properties.height
        button.cornerRadius = properties.cornerRadius
        button.backgroundColor = properties.backgroundColor
        self.button.frame = CGRect(x: TractButton.standardMarginConstant,
                                   y: 0.0,
                                   width: width,
                                   height: height)
        
        self.height = height
        updateFrameHeight()
        
    }
}
