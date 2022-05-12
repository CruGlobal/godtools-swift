//
//  TransparentModalView.swift
//  godtools
//
//  Created by Levi Eggert on 9/29/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import SwiftUI

class TransparentModalView: UIViewController {
    
    private weak var flowDelegate: FlowDelegate?
    
    private let modalView: TransparentModalCustomView
    private let modalCornerRadius: CGFloat = 12
    private let closeModalFlowStep: FlowStep
    
    private var didLayoutSubviews: Bool = false
    private var didTriggerAnimationControllerForPresentationAnimation: Bool = false
    
    @IBOutlet weak private var overlayButton: UIButton!
    
    required init(flowDelegate: FlowDelegate, modalView: TransparentModalCustomView, closeModalFlowStep: FlowStep) {
        
        self.flowDelegate = flowDelegate
        
        self.modalView = modalView
        self.closeModalFlowStep = closeModalFlowStep
        
        super.init(nibName: String(describing: TransparentModalView.self), bundle: nil)
        
        modalPresentationStyle = .overCurrentContext
        transitioningDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overlayButton.addTarget(self, action: #selector(handleBackgroundTapped), for: .touchUpInside)
        
        setupLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard !didLayoutSubviews else {
            return
        }
        
        didLayoutSubviews = true
        
        if modalView.modalLayoutType == .centerVertically && modalView.modal.frame.size.height > view.frame.size.height {
            addModalViewToScrollView()
        }
        
        modalView.transparentModalDidLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if didTriggerAnimationControllerForPresentationAnimation {
            didTriggerAnimationControllerForPresentationAnimation = false
            modalView.transparentModalParentWillAnimateForPresented()
        }
    }
    
    private func setupLayout() {
        
        // view
        view.backgroundColor = .clear
        
        // overlayButton
        overlayButton.backgroundColor = .black
        overlayButton.alpha = 0.4
        
        //customModalView.backgroundColor = .white
        //customModalView.layer.cornerRadius = modalCornerRadius
        //customModalView.layer.shadowOffset = CGSize(width: 1, height: 1)
        //customModalView.layer.shadowColor = UIColor.black.cgColor
        //customModalView.layer.shadowRadius = 5
        //customModalView.layer.shadowOpacity = 0.6
        
        // modalView
        addModalView(modalView: modalView)
    }
    
    @objc private func handleBackgroundTapped() {
        
        flowDelegate?.navigate(step: closeModalFlowStep)
    }
}

// MARK: - Add ModalView

extension TransparentModalView {
    
    private func addModalView(modalView: TransparentModalCustomView) {
        
        guard !view.subviews.contains(modalView.modal) else {
            return
        }
        
        switch modalView.modalLayoutType {
            
        case .centerVertically:
            centerModalViewVertically(modalView: modalView)
        
        case .definedInCustomViewProtocol:
            modalView.addToParentForCustomLayout(parent: view)
        }
        
        modalView.transparentModalDidLayout()
    }
    
    private func centerModalViewVertically(modalView: TransparentModalCustomView) {
        
        view.addSubview(modalView.modal)
                
        let modalInsets = modalView.modalInsets
        
        modalView.modal.translatesAutoresizingMaskIntoConstraints = false
        
        let leading: NSLayoutConstraint = NSLayoutConstraint(
            item: modalView.modal,
            attribute: .leading,
            relatedBy: .equal,
            toItem: view,
            attribute: .leading,
            multiplier: 1,
            constant: modalInsets.left
        )
        
        let trailing: NSLayoutConstraint = NSLayoutConstraint(
            item: modalView.modal,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: view,
            attribute: .trailing,
            multiplier: 1,
            constant: modalInsets.right * -1
        )
        
        let centerVertically: NSLayoutConstraint = NSLayoutConstraint(
            item: modalView.modal,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: view,
            attribute: .centerY,
            multiplier: 1,
            constant: 0
        )
        
        view.addConstraint(leading)
        view.addConstraint(trailing)
        view.addConstraint(centerVertically)
                
        let height: NSLayoutConstraint = NSLayoutConstraint(
            item: modalView.modal,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: 30
        )
        height.priority = UILayoutPriority(500)
        modalView.modal.addConstraint(height)
        
        modalView.modal.layer.cornerRadius = modalCornerRadius
        modalView.modal.clipsToBounds = true
    }
    
    private func addModalViewToScrollView() {
        
        modalView.modal.removeFromSuperview()
        let viewConstraints = view.constraints
        view.removeConstraints(viewConstraints)
        
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.constrainEdgesToView(view: view)
        
        let contentView = UIView()
        contentView.backgroundColor = .clear
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.constrainEdgesToView(view: scrollView)
        
        let equalWidths: NSLayoutConstraint = NSLayoutConstraint(
            item: scrollView,
            attribute: .width,
            relatedBy: .equal,
            toItem: contentView,
            attribute: .width,
            multiplier: 1,
            constant: 0
        )
        
        scrollView.addConstraint(equalWidths)
        
        contentView.addSubview(modalView.modal)
        modalView.modal.translatesAutoresizingMaskIntoConstraints = false
        modalView.modal.constrainEdgesToView(view: contentView)
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension TransparentModalView: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        didTriggerAnimationControllerForPresentationAnimation = true
        
        return FadeAnimationTransition(fade: .fadeIn)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        modalView.transparentModalParentWillAnimateForDismissed()
        
        return FadeAnimationTransition(fade: .fadeOut)
    }
}
