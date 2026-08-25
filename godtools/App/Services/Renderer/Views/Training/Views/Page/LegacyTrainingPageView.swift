//
//  LegacyTrainingPageView.swift
//  godtools
//
//  Created by Levi Eggert on 3/24/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

@MainActor
protocol LegacyTrainingPageViewDelegate: AnyObject {
    
    func trainingPageButtonWithUrlTapped(trainingPage: LegacyTrainingPageView, url: URL)
}

class LegacyTrainingPageView: LegacyMobileContentView, NibBased {
    
    private let viewModel: LegacyTrainingPageViewModel
    private let contentStackView: LegacyMobileContentStackView
    
    private weak var delegate: LegacyTrainingPageViewDelegate?
    
    @IBOutlet weak private var contentStackContainerView: UIView!
    @IBOutlet weak private var bottomGradientView: UIView!
    
    init(viewModel: LegacyTrainingPageViewModel) {
        
        self.viewModel = viewModel
        self.contentStackView = LegacyMobileContentStackView(viewModel: viewModel, contentInsets: nil, scrollIsEnabled: true)
        
        super.init(viewModel: viewModel, frame: UIScreen.main.bounds)
        
        loadNib(nibName: String(describing: LegacyTrainingPageView.self))
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
    
    func setDelegate(delegate: LegacyTrainingPageViewDelegate?) {
        self.delegate = delegate
    }
    
    // MARK: - LegacyMobileContentView
    
    override func renderChild(childView: LegacyMobileContentView) {
        
        contentStackView.renderChild(childView: childView)
    }
    
    override func didReceiveButtonWithUrlEvent(url: URL) {
        delegate?.trainingPageButtonWithUrlTapped(trainingPage: self, url: url)
    }
    
    override var heightConstraintType: MobileContentViewHeightConstraintType {
        return .constrainedToChildren
    }
}
