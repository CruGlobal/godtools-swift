//
//  ToolPageViewFactory.swift
//  godtools
//
//  Created by Levi Eggert on 11/4/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageViewFactory {
    
    static let numberFormatter: NumberFormatter = NumberFormatter()
    
    private let fontService: FontService
    
    required init(fontService: FontService) {
        
        self.fontService = fontService
    }
    
    // MARK: - ContentTextNode
    
    func getContentTextNodeLabel(textNode: ContentTextNode?, fontSize: CGFloat, fontWeight: UIFont.Weight, textColor: UIColor) -> UILabel {
        
        let label: UILabel = UILabel()
        
        styleContentTextNodeLabel(
            textNode: textNode,
            label: label,
            fontSize: fontSize,
            fontWeight: fontWeight,
            textColor: textColor
        )
        
        return label
    }
    
    func styleContentTextNodeLabel(textNode: ContentTextNode?, label: UILabel, fontSize: CGFloat, fontWeight: UIFont.Weight, textColor: UIColor) {
        
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
                
        let fontScale: CGFloat
        
        if let textScaleString = textNode?.textScale,
            !textScaleString.isEmpty,
            let number = ToolPageViewFactory.numberFormatter.number(from: textScaleString) {
            
            fontScale = CGFloat(truncating: number)
        }
        else {
            fontScale = 1
        }
        
        label.font = fontService.getFont(size: fontSize * fontScale, weight: fontWeight)
        label.text = textNode?.text
        label.textColor = textColor
        label.textAlignment = .left
        
        label.setLineSpacing(lineSpacing: 2)
    }
}
