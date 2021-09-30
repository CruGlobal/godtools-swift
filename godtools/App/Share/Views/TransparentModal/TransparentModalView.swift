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
    @IBOutlet weak private var customModalView: UIView!
    
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
        
        view.backgroundColor = .clear
        
        overlayButton.backgroundColor = .black
        overlayButton.alpha = 0.4
        
        customModalView.backgroundColor = .white
        customModalView.layer.cornerRadius = modalCornerRadius
        customModalView.layer.shadowOffset = CGSize(width: 1, height: 1)
        customModalView.layer.shadowColor = UIColor.black.cgColor
        customModalView.layer.shadowRadius = 5
        customModalView.layer.shadowOpacity = 0.6
        customModalView.addSubview(modalView.view)
        
        modalView.view.constrainEdgesToSuperview()
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
