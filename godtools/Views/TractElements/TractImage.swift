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
    
    static let xMarginConstant: CGFloat = 8.0
    static let yMarginConstant: CGFloat = 16.0
    
    // MARK: - Object properties
    
    var imageView = UIImageView()
    var align = "center"
    
    // MARK: - Setup
    
    override func propertiesKind() -> TractProperties.Type {
        return TractImageProperties.self
    }
    
    override func setupView(properties: [String: Any]) {
        self.imageView = UIImageView(image: loadImage(properties: properties))
        let viewWidth = self.elementFrame.finalWidth()
        var width = self.imageView.frame.size.width
        var height = self.imageView.frame.size.height
        var xPosition: CGFloat = 0.0
        
        if width > viewWidth {
            height = viewWidth * height / width
            width = viewWidth
        } else {
            switch self.align {
            case "center":
                xPosition = (viewWidth - width) / 2
            case "left":
                xPosition = TractImage.xMarginConstant
            case "right":
                xPosition = viewWidth - width - TractImage.xMarginConstant
            default:
                xPosition = (viewWidth - width) / 2
            }
        }
        
        self.imageView.frame = CGRect(x: xPosition, y: 0.0, width: width, height: height)
        self.addSubview(self.imageView)
        self.height = height
        updateFrameHeight()
    }
    
    override func loadFrameProperties() {
        self.elementFrame.x = 0.0
        self.elementFrame.width = parentWidth()
        self.elementFrame.yMarginTop = TractImage.yMarginConstant
        self.elementFrame.yMarginBottom = TractImage.yMarginConstant
    }
    
    // MARK: - Helpers
    
    func imageProperties() -> TractImageProperties {
        return self.properties as! TractImageProperties
    }
    
    func loadImage(properties: [String: Any]) -> UIImage {
        let resource = properties["resource"] as! String
        self.align = properties["align"] as? String ?? "center"
        
        let imagePath = self.manifestProperties.getResourceForFile(filename: resource)
        
        guard let data = NSData(contentsOfFile: imagePath) else {
            return UIImage()
        }
        
        guard let image = UIImage(data: data as Data) else {
            return UIImage()
        }
        
        return image
    }

}
