//
//  ToolPageModalsView.swift
//  godtools
//
//  Created by Levi Eggert on 3/23/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class ToolPageModalsView: MobileContentView {
    
    private let viewModel: ToolPageModalsViewModel
    
    private var modalViews: [ToolPageModalView] = Array()
    private var presentedModalView: ToolPageModalView?
    
    private weak var windowViewController: UIViewController?
    
    required init(viewModel: ToolPageModalsViewModel, windowViewController: UIViewController) {
        
        self.viewModel = viewModel
        self.windowViewController = windowViewController
        
        super.init(viewModel: viewModel, frame: UIScreen.main.bounds)
        
        setupLayout()
        setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
    }
    
    private func setupBinding() {
        
    }
    
    // MARK: - MobileContentView
    
    override func renderChild(childView: MobileContentView) {
        
        super.renderChild(childView: childView)
        
        if let modalView = childView as? ToolPageModalView {
            modalViews.append(modalView)
            modalView.setDelegate(delegate: self)
        }
    }
    
    // MARK: -
    
    private func presentModalView(modalView: ToolPageModalView, animated: Bool) {
        
        guard modalViews.contains(modalView) else {
            return
        }
        
        guard let window = windowViewController else {
            return
        }
        
        presentedModalView = modalView
        
        window.view.addSubview(modalView)
        modalView.frame = window.view.bounds
        modalView.layoutIfNeeded()
                                
        if animated {
            modalView.alpha = 0
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                modalView.alpha = 1
            }, completion: nil)
        }
    }
    
    private func dismissModalView(animated: Bool) {
        
        guard let modalView = presentedModalView else {
            return
        }
        
        presentedModalView = nil
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                modalView.alpha = 0
            }) { (finished: Bool) in
                modalView.removeFromSuperview()
            }
        }
        else {
            modalView.alpha = 0
            modalView.removeFromSuperview()
        }
    }
}

// MARK: - ToolPageModalViewDelegate

extension ToolPageModalsView: ToolPageModalViewDelegate {
    
    func toolPageModalListenerActivated(modalView: ToolPageModalView) {
        presentModalView(modalView: modalView, animated: true)
    }
    
    func toolPageModalDismissListenerActivated(modalView: ToolPageModalView) {
        dismissModalView(animated: true)
    }
}
