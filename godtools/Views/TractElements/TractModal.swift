//
//  TractModal.swift
//  godtools
//
//  Created by Devserker on 5/16/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractModal: BaseTractElement {
    
    // MARK: Positions constants
    
    static let contentWidth: CGFloat = 275.0
    
    // MARK: - Positions and Sizes
    
    override func yEndPosition() -> CGFloat {
        return self.height
    }
    
    // MARK: - Object properties
    
    var properties = TractModalProperties()
    var modalOpen = false
    
    // MARK: - Setup
    
    override func setupView(properties: [String: Any]) {
        loadElementProperties(properties: properties)
        TractBindings.addBindings(self)
        
        self.frame = buildFrame()
        setupStyle()
    }
    
    func setupStyle() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    }
    
    override func elementListener() -> String {
        return self.properties.listener != nil ? self.properties.listener! : ""
    }
    
    override func render() -> UIView {
        let modalHeight = UIApplication.shared.keyWindow?.frame.size.height
        let startYPosition = (modalHeight! - self.height) / CGFloat(2)
        
        for element in self.elements! {
            let xPosition = element.frame.origin.x
            let yPosition = element.frame.origin.y + startYPosition
            let width = element.frame.size.width
            let height = element.frame.size.height
            element.frame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
            self.addSubview(element.render())
        }
        
        return self
    }
    
    // MARK: - Helpers
    
    func loadElementProperties(properties: [String: Any]) {
        for property in properties.keys {
            switch property {
            case "listener":
                self.properties.listener = properties[property] as! String?
            default: break
            }
        }
    }
    
    override func receiveMessage() {
        if self.modalOpen {
            for view in self.subviews {
                view.removeFromSuperview()
            }
            
            self.alpha = CGFloat(0.0)
            UIView.animate(withDuration: 0.35,
                           delay: 0.0,
                           options: UIViewAnimationOptions.curveEaseInOut,
                           animations: { self.alpha = CGFloat(0.0) },
                           completion: nil )
            
            self.removeFromSuperview()
        } else {
            _ = render()
            
            let currentWindow = UIApplication.shared.keyWindow
            currentWindow?.addSubview(self)
            
            self.alpha = CGFloat(0.0)
            UIView.animate(withDuration: 0.35,
                           delay: 0.0,
                           options: UIViewAnimationOptions.curveEaseInOut,
                           animations: { self.alpha = CGFloat(1.0) },
                           completion: nil )
        }
        
        self.modalOpen = !self.modalOpen
    }
    
    fileprivate func buildFrame() -> CGRect {
        return (UIApplication.shared.keyWindow?.frame)!
    }

}
