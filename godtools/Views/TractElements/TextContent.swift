//
//  TextContent.swift
//  godtools
//
//  Created by Ryan Carlson on 4/26/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class TextContent: BaseTractElement {
    
    var textScale = CGFloat(1.0)
    var textColor = UIColor.black
    var text = ""
    
    override func setupView(properties: Dictionary<String, Any>) {
        let label = UILabel(frame: createLabelFrameForHeight(self.height))
        
        label.font = UIFont(name: "Helvetica", size: CGFloat(16.0) * textScale)
        label.text = text
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        label.backgroundColor = .yellow
        
        if BaseTractElement.isParagraphElement(self) {
            label.frame = createLabelFrameForHeight(label.frame.size.height + CGFloat(20.0))
        }
        
        self.view = label
    }
    
    fileprivate func createLabelFrameForHeight(_ height: CGFloat) -> CGRect {
        return CGRect(x: BaseTractElement.Standards.xPadding,
                      y: self.yStartPosition,
                      width: BaseTractElement.Standards.textContentWidth,
                      height: height)
    }
    
}
