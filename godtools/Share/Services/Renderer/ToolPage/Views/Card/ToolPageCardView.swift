//
//  ToolPageCardView.swift
//  godtools
//
//  Created by Levi Eggert on 11/3/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageCardView: UIView {
    
    private let viewModel: ToolPageCardViewModelType
    
    private var contentStackView: ToolPageContentStackView?
        
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var titleSeparatorLine: UIView!
    @IBOutlet weak private var headerButton: UIButton!
    @IBOutlet weak private var contentStackContainer: UIView!
    @IBOutlet weak private var bottomGradientView: UIView!
    @IBOutlet weak private var cardPositionLabel: UILabel!
    @IBOutlet weak private var previousButton: UIButton!
    @IBOutlet weak private var nextButton: UIButton!
    
    required init(viewModel: ToolPageCardViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: UIScreen.main.bounds)
        
        initializeNib()
        setupLayout()
        setupBinding()
        
        headerButton.addTarget(self, action: #selector(handleHeader(button:)), for: .touchUpInside)
        previousButton.addTarget(self, action: #selector(handlePrevious(button:)), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(handleNext(button:)), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initializeNib() {
        
        let nib: UINib = UINib(nibName: String(describing: ToolPageCardView.self), bundle: nil)
        let contents: [Any]? = nib.instantiate(withOwner: self, options: nil)
        if let rootNibView = (contents as? [UIView])?.first {
            addSubview(rootNibView)
            rootNibView.frame = bounds
            rootNibView.constrainEdgesToSuperview()
        }
    }
    
    private func setupLayout() {
        
        let cardCornerRadius: CGFloat = 8
        
        layer.cornerRadius = cardCornerRadius
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 6.0
        layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        layer.shadowOpacity = 0.3
        clipsToBounds = false
        
        let rootView: UIView? = subviews.first
        rootView?.layer.cornerRadius = cardCornerRadius
        rootView?.clipsToBounds = true
    }
    
    private func setupBinding() {
        
        titleLabel.text = viewModel.title
        
        cardPositionLabel.text = viewModel.cardPositionLabel
        
        previousButton.setTitle(viewModel.previousButtonTitle, for: .normal)
        
        nextButton.setTitle(viewModel.nextButtonTitle, for: .normal)
        
        let contentStackViewModel: ToolPageContentStackViewModel = viewModel.contentStackWillAppear()
        let contentStackView: ToolPageContentStackView = ToolPageContentStackView(viewModel: contentStackViewModel)
        contentStackContainer.addSubview(contentStackView)
        contentStackView.constrainEdgesToSuperview()
        layoutIfNeeded()
        self.contentStackView = contentStackView
        contentStackView.setContentInset(contentInset: UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: bottomGradientView.frame.size.height,
            right: 0
        ))
    }
    
    var titleHeight: CGFloat {
        return titleSeparatorLine.frame.origin.y
    }
    
    @objc func handleHeader(button: UIButton) {
        viewModel.headerTapped()
    }
    
    @objc func handlePrevious(button: UIButton) {
        viewModel.previousTapped()
    }
    
    @objc func handleNext(button: UIButton) {
        viewModel.nextTapped()
    }
}
