//
//  LegacyTractPageCallToActionView.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

@MainActor
protocol LegacyTractPageCallToActionViewDelegate: AnyObject {
    
    func tractPageCallToActionNextButtonTapped(callToActionView: LegacyTractPageCallToActionView)
}

class LegacyTractPageCallToActionView: LegacyMobileContentView, NibBased {
        
    let viewModel: LegacyTractPageCallToActionViewModel
        
    private weak var delegate: LegacyTractPageCallToActionViewDelegate?
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var nextButton: UIButton!
    
    init(viewModel: LegacyTractPageCallToActionViewModel) {
        
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
    
    func setDelegate(delegate: LegacyTractPageCallToActionViewDelegate?) {
        self.delegate = delegate
    }
    
    @objc func handleNextTapped(button: UIButton) {
        delegate?.tractPageCallToActionNextButtonTapped(callToActionView: self)
    }
}
