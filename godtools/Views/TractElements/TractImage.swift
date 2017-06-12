//
//  TractImage.swift
//  godtools
//
//  Created by Devserker on 5/11/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractImage: BaseTractElement {
    
    // MARK: Positions constants
    
    static let xMarginConstant: CGFloat = 0.0
    
    // MARK: - Positions and Sizes
    
    var xPosition: CGFloat {
        return CGFloat(0.0)
    }
    
    override var width: CGFloat {
        return (self.parent?.width)! - (self.xPosition * CGFloat(2))
    }
    
    // MARK: - Object properties
    
    var imageView = UIImageView()
    var align = "center"
    
    // MARK: - Setup
    
    var properties = TractImageProperties()
    
    override func setupView(properties: [String: Any]) {
        self.imageView = UIImageView(image: loadImage(properties: properties))
        var width = self.imageView.frame.size.width
        var height = self.imageView.frame.size.height
        var xPosition: CGFloat = 0.0
        let yPosition: CGFloat = 0.0
        
        if width > self.width {
            height = self.width * height / width
            width = self.width
        } else {
            switch self.align {
            case "center":
                xPosition = (self.width - width) / 2
            case "left":
                xPosition = TractImage.xMarginConstant
            case "right":
                xPosition = self.width - width - TractImage.xMarginConstant
            default:
                xPosition = (self.width - width) / 2
            }
            
        }
        
        self.imageView.frame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
        self.addSubview(self.imageView)
        self.frame = buildFrame()
        self.height = height
    }
    
    override func loadFrameProperties() {
        let yMarginConstant: CGFloat = 16.0
        
        self.elementFrame.x = self.xPosition
        self.elementFrame.y = self.elementFrame.yOrigin
        self.elementFrame.width = self.width
        self.elementFrame.height = self.height
        self.elementFrame.yMarginTop = yMarginConstant
        self.elementFrame.yMarginBottom = yMarginConstant
    }
    
    // MARK: - Helpers
    
    func loadImage(properties: [String: Any]) -> UIImage {
        let resource = properties["resource"] as! String?
        self.align = properties["align"] as? String ?? "center"
        
        guard let image = UIImage(named: resource!) else {
            return UIImage()
        }
        return image
    }

}
