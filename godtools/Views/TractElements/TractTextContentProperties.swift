//
//  TractTextContentProperties.swift
//  godtools
//
//  Created by Devserker on 5/8/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractTextContentProperties: TractElementProperties {
    
    var i18nId: String?
    var color: UIColor = .gtBlack
    var scale: CGFloat?
    var align: NSTextAlignment = .left
    var width: CGFloat = 0.0
    var height: CGFloat = 0.0
    var xMargin: CGFloat = BaseTractElement.xMargin
    var yMargin: CGFloat = BaseTractElement.yMargin
    var value: String?
    var font = UIFont.gtRegular(size: 15.0)
    
    override func load(_ properties: [String: Any]) {
        super.load(properties)
        
        for property in properties.keys {
            switch property {
            case "text-color":
                self.color = (properties[property] as? String)!.getRGBAColor()
            case "text-align":
                self.align = convertTextAlignmentString(properties[property] as! String?)
            default: break
            }
        }
    }
    
    private func convertTextAlignmentString(_ string: String?) -> NSTextAlignment {
        guard let string = string else {
            return .left
        }
        
        switch string {
            case "start": return .left
            case "end": return .right
            case "center": return .center
        default: return .left
        }
    }

}
