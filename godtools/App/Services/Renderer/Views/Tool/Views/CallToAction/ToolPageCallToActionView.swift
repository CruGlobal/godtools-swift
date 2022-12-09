//
//  ToolPageCallToActionView.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol ToolPageCallToActionViewDelegate: AnyObject {
    
    func toolPageCallToActionNextButtonTapped(callToActionView: ToolPageCallToActionView)
}

class ToolPageCallToActionView: MobileContentView, NibBased {
        
    let viewModel: ToolPageCallToActionViewModel
        
    private weak var delegate: ToolPageCallToActionViewDelegate?
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var nextButton: UIButton!
    
    required init(viewModel: ToolPageCallToActionViewModel) {
        
        self.viewModel = viewModel
        
        super.init(viewModel: viewModel, frame: UIScreen.main.bounds)
        
        let rootNibView: UIView? = loadNib()
        rootNibView?.semanticContentAttribute = viewModel.languageDirectionSemanticContentAttribute
        setupLayout()
        setupBinding()
        
        nextButton.addTarget(self, action: #selector(handleNextTapped(button:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        
    }
    
    private func setupBinding() {
                
        titleLabel.text = viewModel.title
        titleLabel.textColor = viewModel.titleColor
        titleLabel.textAlignment = viewModel.titleTextAlignment
        
        nextButton.semanticContentAttribute = viewModel.nextButtonSemanticContentAttribute
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
