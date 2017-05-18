//
//  ImageContent.swift
//  godtools
//
//  Created by Devserker on 5/11/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractImage: BaseTractElement {
    
    static let xMarginConstant: CGFloat = 0.0
    static let yMarginConstant: CGFloat = 16.0
    
    var align = "center"
    
    var xPosition: CGFloat {
        return CGFloat(0.0)
    }
    var yPosition: CGFloat {
        return self.yStartPosition + TractImage.yMarginConstant
    }
    override var width: CGFloat {
        return (self.parent?.width)! - (self.xPosition * CGFloat(2))
    }
    
    var imageView = UIImageView()
    
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
    
    override func yEndPosition() -> CGFloat {
        return self.yPosition + self.height + TractImage.yMarginConstant
    }
    
    // MARK: - Helpers
    
    fileprivate func buildFrame() -> CGRect {
        return CGRect(x: self.xPosition,
                      y: self.yPosition,
                      width: self.width,
                      height: self.height)
    }
    
    func loadImage(properties: [String: Any]) -> UIImage {
        let resource = properties["resource"] as! String?
        self.align = properties["align"] as! String
        
        guard let image = UIImage(named: resource!) else {
            return UIImage()
        }
        return image
    }

}
