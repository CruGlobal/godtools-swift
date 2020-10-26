//
//  ContextTextRenderer.swift
//  godtools
//
//  Created by Levi Eggert on 10/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ContextTextRenderer: RendererViewType {
    
    private let label: UILabel = UILabel()
    
    required init() {
        
    }
    
    var view: UIView {
        return label
    }
    
    func render(node: RendererContentTextNode) {
        
    }
}
