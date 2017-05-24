//
//  TractModal.swift
//  godtools
//
//  Created by Devserker on 5/16/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractModal: BaseTractElement {
    
    // MARK: - Positions and Sizes
    
    override func yEndPosition() -> CGFloat {
        return self.height
    }
    
    // MARK: - Object properties
    
    var properties = TractModalProperties()
    
    // MARK: - Setup
    
    override func setupView(properties: [String: Any]) {
        loadElementProperties(properties: properties)
        
        self.frame = buildFrame()
        setupStyle()
    }
    
    func setupStyle() {
        self.backgroundColor = .gtBlack
    }
    
    override func getListener() -> String {
        return self.properties.listener != nil ? self.properties.listener! : ""
    }
    
    override func render() -> UIView {
        for element in self.elements! {
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
    
    fileprivate func buildFrame() -> CGRect {
        return (UIApplication.shared.keyWindow?.frame)!
    }

}
