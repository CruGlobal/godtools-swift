//
//  ToolPageContentStackViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageContentStackViewModel {
    
    private let node: MobileContentXmlNode
    
    let itemSpacing: CGFloat
    let scrollIsEnabled: Bool
    let defaultPrimaryColor: UIColor
    let defaultPrimaryTextColor: UIColor
    
    required init(node: MobileContentXmlNode, itemSpacing: CGFloat, scrollIsEnabled: Bool, defaultPrimaryColor: UIColor, defaultPrimaryTextColor: UIColor) {
        
        self.node = node
        self.itemSpacing = itemSpacing
        self.scrollIsEnabled = scrollIsEnabled
        self.defaultPrimaryColor = defaultPrimaryColor
        self.defaultPrimaryTextColor = defaultPrimaryTextColor
    }
    
    func render(didRenderView: ((_ view: UIView) -> Void)) {
        for childNode in node.children {
            let childView: UIView = recurseAndRender(node: childNode)
            didRenderView(childView)
        }
    }
    
    private func recurseAndRender(node: MobileContentXmlNode) -> UIView {
        
        if let paragraphNode = node as? ContentParagraphNode {
            
            let viewModel = ToolPageContentStackViewModel(
                node: paragraphNode,
                itemSpacing: 20,
                scrollIsEnabled: false,
                defaultPrimaryColor: defaultPrimaryColor,
                defaultPrimaryTextColor: defaultPrimaryTextColor
            )
            
            let view = ToolPageContentStackView(viewModel: viewModel)
            
            return view
        }
        else if let textNode = node as? ContentTextNode {
            
            let textLabel: UILabel = getLabel(text: textNode.text)
            textLabel.textColor = textNode.getTextColor()?.color ?? defaultPrimaryColor
            
            return textLabel
        }
        else if let headingNode = node as? HeadingNode {
            
            let headingLabel: UILabel = getLabel(text: headingNode.text)
            headingLabel.textColor = headingNode.getTextColor()?.color ?? defaultPrimaryColor
            
            return headingLabel
        }
        
        return UIView(frame: .zero)
    }
    
    private func getButton(title: String?) -> UIButton {
        
        let button: UIButton = UIButton(type: .custom)
        button.backgroundColor = .clear
        button.setTitle(title, for: .normal)
        
        return button
    }
    
    private func getLabel(text: String?) -> UILabel {
        
        let label: UILabel = UILabel()
        label.backgroundColor = UIColor.clear
        label.text = text
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        label.setLineSpacing(lineSpacing: 4)
        
        return label
    }
}
