//
//  TransparentModalBottomView.swift
//  godtools
//
//  Created by Levi Eggert on 4/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import UIKit
import SwiftUI

class TransparentModalBottomView<Content: View>: AppHostingController<Content> {
            
    private var modalBottomToParent: NSLayoutConstraint?
    private var modalHeightConstraint: NSLayoutConstraint?
    
    init(view: Content, navigationBar: AppNavigationBar?) {
                
        super.init(rootView: view, navigationBar: navigationBar)
                
        setupLayout()
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        view.backgroundColor = .clear
    }
}

extension TransparentModalBottomView: TransparentModalCustomViewInterface {
    
    private func setModalHidden(hidden: Bool, animated: Bool, layoutIfNeeded: Bool = true) {
        
        guard let bottomConstraint = modalBottomToParent, let heightConstraint = modalHeightConstraint else {
            return
        }
                
        bottomConstraint.constant = hidden ? heightConstraint.constant - 50 : 0
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                if layoutIfNeeded {
                    self.view.superview?.layoutIfNeeded()
                }
            }, completion: nil)
        }
        else {
            if layoutIfNeeded {
                view.superview?.layoutIfNeeded()
            }
        }
    }
    
    private func getModalHeight() -> CGFloat? {
        return modalHeightConstraint?.constant
    }
    
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
        
        let modalHeight: CGFloat = getModalHeight() ?? floor(UIScreen.main.bounds.size.height * 0.5)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        _ = view.constrainLeadingToView(view: parent)
        _ = view.constrainTrailingToView(view: parent)
        modalBottomToParent = view.constrainBottomToView(view: parent, constant: 0)
        modalHeightConstraint = view.addHeightConstraint(constant: modalHeight, priority: 500)
                
        setModalHidden(hidden: true, animated: false, layoutIfNeeded: false)
    }
    
    func transparentModalDidLayout() {
        
    }
    
    func transparentModalParentWillAnimateForPresented() {
        
        setModalHidden(hidden: true, animated: false)
        setModalHidden(hidden: false, animated: true)
    }
    
    func transparentModalParentWillAnimateForDismissed() {
        
        setModalHidden(hidden: true, animated: true)
    }
}
