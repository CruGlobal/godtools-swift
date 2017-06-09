//
//  TractTextContentProperties.swift
//  godtools
//
//  Created by Devserker on 5/8/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractTextContentProperties: XMLNode {
    
    var i18nId: String = ""
    var color: UIColor = .gtBlack
    var scale: CGFloat?
    var textAlign: NSTextAlignment = .left
    var width: CGFloat = 0.0
    var height: CGFloat = 0.0
    var xMargin: CGFloat = BaseTractElement.xMargin
    var yMargin: CGFloat = BaseTractElement.yMargin
    var value: String = ""
    var font = UIFont.gtRegular(size: 15.0)
    
    override func performCustomProperty(propertyName: String, value: String) {
        switch propertyName {
        case "textAlign":
            setupTextAlign(value)
        default: break
        }
    }
    
    func setupTextAlign(_ string: String) {
        switch string {
        case "start":
            self.textAlign = .left
        case "end":
            self.textAlign = .right
        case "center":
            self.textAlign = .center
        default:
            self.textAlign = .left
        }
    }

}
