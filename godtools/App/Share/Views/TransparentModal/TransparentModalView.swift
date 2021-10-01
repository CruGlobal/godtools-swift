//
//  TransparentModalView.swift
//  godtools
//
//  Created by Levi Eggert on 9/29/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class TransparentModalView: UIViewController {
    
    private let modalView: TransparentModalCustomView
    private let modalCornerRadius: CGFloat = 12
    
    private var didLayoutSubviews: Bool = false
    
    @IBOutlet weak private var overlayButton: UIButton!
    
    required init(modalView: TransparentModalCustomView) {
        
        self.modalView = modalView
        
        super.init(nibName: String(describing: TransparentModalView.self), bundle: nil)
        
        modalPresentationStyle = .overCurrentContext
        transitioningDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !didLayoutSubviews {
            didLayoutSubviews = true
            modalView.transparentModalDidLayout()
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
}

// MARK: - Add ModalView

extension TransparentModalView {
    
    private func addModalView(modalView: TransparentModalCustomView) {
        
        guard !view.subviews.contains(modalView.view) else {
            return
        }
        
        view.addSubview(modalView.view)
        modalView.view.layoutIfNeeded()
        
        let modalInsets: UIEdgeInsets = .zero
        
        modalView.view.translatesAutoresizingMaskIntoConstraints = false
        
        let leading: NSLayoutConstraint = NSLayoutConstraint(
            item: modalView.view,
            attribute: .leading,
            relatedBy: .equal,
            toItem: view,
            attribute: .leading,
            multiplier: 1,
            constant: modalInsets.left
        )
        
        let trailing: NSLayoutConstraint = NSLayoutConstraint(
            item: modalView.view,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: view,
            attribute: .trailing,
            multiplier: 1,
            constant: modalInsets.right * -1
        )
        
        let top: NSLayoutConstraint = NSLayoutConstraint(
            item: modalView.view,
            attribute: .top,
            relatedBy: .equal,
            toItem: view,
            attribute: .top,
            multiplier: 1,
            constant: modalInsets.top
        )
        
        let bottom: NSLayoutConstraint = NSLayoutConstraint(
            item: modalView.view,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: view,
            attribute: .bottom,
            multiplier: 1,
            constant: modalInsets.bottom * -1
        )
                
        let height: NSLayoutConstraint = NSLayoutConstraint(
            item: modalView.view,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: 30
        )
        
        height.priority = UILayoutPriority(500)
        
        modalView.view.addConstraint(height)
        
        view.addConstraint(leading)
        view.addConstraint(trailing)
        view.addConstraint(top)
        //view.addConstraint(bottom)
        
        //modalView.view.constrainEdgesToSuperview()
        modalView.view.layoutIfNeeded()
        modalView.view.layer.cornerRadius = modalCornerRadius
        modalView.view.clipsToBounds = true
        modalView.transparentModalDidLayout()
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension TransparentModalView: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return FadeAnimationTransition(fade: .fadeIn)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return FadeAnimationTransition(fade: .fadeOut)
    }
}
