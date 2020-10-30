//
//  MobileContentStackViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class MobileContentStackViewModel {
    
    private let node: MobileContentXmlNode
    
    required init(node: MobileContentXmlNode) {
        
        self.node = node
    }
    
    func render(didRenderView: ((_ view: UIView) -> Void)) {
        for childNode in node.children {
            let childView: UIView = recurseAndRender(node: childNode)
            didRenderView(childView)
        }
    }
    
    func recurseAndRender(node: MobileContentXmlNode) -> UIView {
        
        if let paragraphNode = node as? ContentParagraphNode {
            
            let viewModel = MobileContentStackViewModel(node: paragraphNode)
            
            let view = MobileContentStackView(
                viewModel: viewModel,
                viewSpacing: 20,
                scrollIsEnabled: false
            )
            
            return view
        }
        else if let textNode = node as? ContentTextNode {
            
            return getLabel(text: textNode.text)
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
        label.textColor = UIColor.hexColor(hexValue: 0x5A5A5A)
        label.font = UIFont(name: "Helvetica", size: 18)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        label.setLineSpacing(lineSpacing: 4)
        
        return label
    }
}
