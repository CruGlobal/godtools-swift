//
//  ToolPageCallToActionView.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol ToolPageCallToActionViewDelegate: class {
    
    func toolPageCallToActionNextButtonTapped(callToActionView: ToolPageCallToActionView)
}

class ToolPageCallToActionView: MobileContentView {
        
    let viewModel: ToolPageCallToActionViewModelType
        
    private weak var delegate: ToolPageCallToActionViewDelegate?
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var nextButton: UIButton!
    
    required init(viewModel: ToolPageCallToActionViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: UIScreen.main.bounds)
        
        initializeNib()
        setupLayout()
        setupBinding()
        
        nextButton.addTarget(self, action: #selector(handleNextTapped(button:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initializeNib() {
        
        let nib: UINib = UINib(nibName: String(describing: ToolPageCallToActionView.self), bundle: nil)
        let contents: [Any]? = nib.instantiate(withOwner: self, options: nil)
        if let rootNibView = (contents as? [UIView])?.first {
            addSubview(rootNibView)
            rootNibView.backgroundColor = .clear
            rootNibView.frame = bounds
            rootNibView.constrainEdgesToSuperview()
        }
    }
    
    private func setupLayout() {
        
    }
    
    private func setupBinding() {
        
        semanticContentAttribute = viewModel.languageDirectionSemanticContentAttribute
        
        titleLabel.text = viewModel.title
        titleLabel.textColor = viewModel.titleColor
        
        nextButton.semanticContentAttribute = viewModel.languageDirectionSemanticContentAttribute
        nextButton.setImage(viewModel.nextButtonImage, for: .normal)
        nextButton.setImageColor(color: viewModel.nextButtonColor)
    }
    
    func setDelegate(delegate: ToolPageCallToActionViewDelegate?) {
        self.delegate = delegate
    }
    
    @objc func handleNextTapped(button: UIButton) {
        delegate?.toolPageCallToActionNextButtonTapped(callToActionView: self)
    }
}
