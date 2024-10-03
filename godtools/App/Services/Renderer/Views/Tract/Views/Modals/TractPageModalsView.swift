//
//  TractPageModalsView.swift
//  godtools
//
//  Created by Levi Eggert on 3/23/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class TractPageModalsView: MobileContentView {
    
    private let viewModel: TractPageModalsViewModel
    
    private var modalViews: [TractPageModalView] = Array()
    private var presentedModalView: TractPageModalView?
    
    private weak var windowViewController: UIViewController?
    
    init(viewModel: TractPageModalsViewModel, windowViewController: UIViewController) {
        
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
        
        if let modalView = childView as? TractPageModalView {
            modalViews.append(modalView)
            modalView.setDelegate(delegate: self)
        }
    }
    
    // MARK: -
    
    private func presentModalView(modalView: TractPageModalView, animated: Bool) {
        
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

// MARK: - TractPageModalViewDelegate

extension TractPageModalsView: TractPageModalViewDelegate {
    
    func tractPageModalListenerActivated(modalView: TractPageModalView) {
        presentModalView(modalView: modalView, animated: true)
    }
    
    func tractPageModalDismissListenerActivated(modalView: TractPageModalView) {
        dismissModalView(animated: true)
    }
}
