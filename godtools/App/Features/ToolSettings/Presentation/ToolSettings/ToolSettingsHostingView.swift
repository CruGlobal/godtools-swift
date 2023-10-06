//
//  ToolSettingsHostingView.swift
//  godtools
//
//  Created by Levi Eggert on 5/12/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI
import UIKit

class ToolSettingsHostingView: AppHostingController<ToolSettingsView> {
    
    private let modalHeightPercentageOfScreen: CGFloat = 0.6
    private let modalHorizontalPadding: CGFloat = 12
    private let modalCornerRadius: CGFloat = 12
    
    private var modalBottomToParent: NSLayoutConstraint?
    
    init(view: ToolSettingsView, navigationBar: AppNavigationBar?) {
        
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

extension ToolSettingsHostingView: TransparentModalCustomView {
    
    private func setModalHidden(hidden: Bool, animated: Bool, layoutIfNeeded: Bool = true) {
        
        guard let bottomConstraint = modalBottomToParent else {
            return
        }
                
        bottomConstraint.constant = hidden ? getModalHeight() - 50 : 0
        
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
    
    private func getModalHeight() -> CGFloat {
        return UIScreen.main.bounds.size.height * modalHeightPercentageOfScreen
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
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.constrainLeadingToView(view: parent, constant: modalHorizontalPadding)
        view.constrainTrailingToView(view: parent, constant: modalHorizontalPadding)
        modalBottomToParent = view.constrainBottomToView(view: parent, constant: 0)
        _ = view.addHeightConstraint(constant: getModalHeight())
        
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
