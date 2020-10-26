//
//  ContentParagraphRenderer.swift
//  godtools
//
//  Created by Levi Eggert on 10/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ContentParagraphRenderer: RendererViewType {
    
    private let stackView: UIStackView = UIStackView()
    
    required init() {
        
        stackView.axis = .vertical
    }
    
    var view: UIView {
        return stackView
    }
    
    func render(node: RendererContentParagraphNode) {
        
        for child in node.childNodes {
            
            // instantiate child view and add to parent
            
        }
    }
}
