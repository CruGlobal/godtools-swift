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
            if modalView.modal.frame.size.height > view.frame.size.height {
                addModalViewToScrollView()
            }
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
        
        guard !view.subviews.contains(modalView.modal) else {
            return
        }
                
        view.addSubview(modalView.modal)
                
        let modalInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
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
        modalView.transparentModalDidLayout()
    }
    
    private func addModalViewToScrollView() {
        
        modalView.modal.removeFromSuperview()
        let viewConstraints = view.constraints
        view.removeConstraints(viewConstraints)
        
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.constrainEdgesToSuperview()
        
        let contentView = UIView()
        contentView.backgroundColor = .clear
        scrollView.addSubview(contentView)
        contentView.constrainEdgesToSuperview()
        
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
        modalView.modal.constrainEdgesToSuperview()
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
