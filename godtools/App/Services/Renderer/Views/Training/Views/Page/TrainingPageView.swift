//
//  TrainingPageView.swift
//  godtools
//
//  Created by Levi Eggert on 3/24/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol TrainingPageViewDelegate: AnyObject {
    
    func trainingPageButtonWithUrlTapped(trainingPage: TrainingPageView, url: String)
}

class TrainingPageView: MobileContentView {
    
    private let viewModel: TrainingPageViewModelType
    private let contentStackView: MobileContentStackView = MobileContentStackView(contentInsets: .zero, itemSpacing: 15, scrollIsEnabled: true)
    
    private weak var delegate: TrainingPageViewDelegate?
    
    @IBOutlet weak private var contentStackContainerView: UIView!
    @IBOutlet weak private var bottomGradientView: UIView!
    
    required init(viewModel: TrainingPageViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: UIScreen.main.bounds)
        
        initializeNib(nibName: String(describing: TrainingPageView.self))
        setupLayout()
        setupBinding()
    }
    
    private func initializeNib(nibName: String) {
        
        let nib: UINib = UINib(nibName: nibName, bundle: nil)
        let contents: [Any]? = nib.instantiate(withOwner: self, options: nil)
        if let rootNibView = (contents as? [UIView])?.first {
            addSubview(rootNibView)
            rootNibView.backgroundColor = .clear
            rootNibView.frame = bounds
            rootNibView.translatesAutoresizingMaskIntoConstraints = false
            rootNibView.constrainEdgesToView(view: self)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
        // contentStackView
        contentStackContainerView.addSubview(contentStackView)
        contentStackView.constrainEdgesToSuperview()
        contentStackView.setScrollViewContentInset(contentInset: UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: bottomGradientView.frame.size.height,
            right: 0
        ))
        setParentAndAddChild(childView: contentStackView)
        
        // bottom gradient
        bottomGradientView.isUserInteractionEnabled = false
        bottomGradientView.backgroundColor = .clear
        let bottomGradient = CAGradientLayer()
        bottomGradient.frame = bottomGradientView.bounds
        bottomGradient.colors = [
            UIColor.white.withAlphaComponent(0).cgColor,
            UIColor.white.withAlphaComponent(0.5).cgColor,
            UIColor.white.withAlphaComponent(0.75).cgColor,
            UIColor.white.cgColor
        ]
        bottomGradientView.layer.insertSublayer(bottomGradient, at: 0)
    }
    
    private func setupBinding() {
        
    }
    
    func setDelegate(delegate: TrainingPageViewDelegate?) {
        self.delegate = delegate
    }
    
    // MARK: - MobileContentView
    
    override func renderChild(childView: MobileContentView) {
        
        contentStackView.renderChild(childView: childView)
    }
    
    override func didReceiveButtonWithUrlEvent(url: String) {
        delegate?.trainingPageButtonWithUrlTapped(trainingPage: self, url: url)
    }
    
    override var heightConstraintType: MobileContentViewHeightConstraintType {
        return .constrainedToChildren
    }
}
