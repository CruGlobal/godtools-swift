//
//  TrainingPageView.swift
//  godtools
//
//  Created by Levi Eggert on 3/24/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol TrainingPageViewDelegate: AnyObject {
    
    func trainingPageButtonWithUrlTapped(trainingPage: TrainingPageView, url: URL)
}

class TrainingPageView: MobileContentView, NibBased {
    
    private let viewModel: TrainingPageViewModel
    private let contentStackView: MobileContentStackView
    
    private weak var delegate: TrainingPageViewDelegate?
    
    @IBOutlet weak private var contentStackContainerView: UIView!
    @IBOutlet weak private var bottomGradientView: UIView!
    
    init(viewModel: TrainingPageViewModel) {
        
        self.viewModel = viewModel
        self.contentStackView = MobileContentStackView(viewModel: viewModel, contentInsets: .zero, itemSpacing: 15, scrollIsEnabled: true)
        
        super.init(viewModel: viewModel, frame: UIScreen.main.bounds)
        
        loadNib(nibName: String(describing: TrainingPageView.self))
        setupLayout()
        setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
        // contentStackView
        contentStackContainerView.addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.constrainEdgesToView(view: contentStackContainerView)
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
    
    override func didReceiveButtonWithUrlEvent(url: URL) {
        delegate?.trainingPageButtonWithUrlTapped(trainingPage: self, url: url)
    }
    
    override var heightConstraintType: MobileContentViewHeightConstraintType {
        return .constrainedToChildren
    }
}
