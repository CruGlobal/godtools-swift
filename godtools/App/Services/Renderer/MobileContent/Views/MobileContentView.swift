//
//  MobileContentView.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentView: UIView, MobileContentStackChildViewType {
    
    private weak var parent: MobileContentView?
    
    private(set) var children: [MobileContentView] = Array()
    
    func renderChild(childView: MobileContentView) {
        
        childView.parent = self
        
        children.append(childView)
    }
    
    func finishedRenderingChildren() {
        
    }
    
    func viewDidAppear() {
        
    }
    
    func viewDidDisappear() {
        
    }
    
    // MARK: - MobileContentStackChildViewType
    
    var view: UIView {
        return self
    }
    
    var contentStackHeightConstraintType: MobileContentStackChildViewHeightConstraintType {
        return .constrainedToChildren
    }
}
