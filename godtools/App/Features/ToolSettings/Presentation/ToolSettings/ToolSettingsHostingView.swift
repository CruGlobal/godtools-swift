//
//  ToolSettingsHostingView.swift
//  godtools
//
//  Created by Levi Eggert on 5/12/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI
import UIKit

class ToolSettingsHostingView: UIHostingController<ToolSettingsView> {
    
    required init(view: ToolSettingsView) {
        
        super.init(rootView: view)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ToolSettingsHostingView: TransparentModalCustomView {
    
    var modal: UIView {
        return view
    }
    
    var modalInsets: UIEdgeInsets {
        return .zero
    }
    
    var modalLayoutType: TransparentModalCustomViewLayoutType {
        return .definedInCustomViewProtocol
    }
    
    func addToParentForCustomLayout(parent: UIView) {
        
        parent.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.constrainEdgesToView(view: parent)
    }
    
    func transparentModalDidLayout() {
        
    }
    
    func transparentModalParentWillAnimateForPresented() {
        
    }
    
    func transparentModalParentWillAnimateForDismissed() {
        
    }
}
