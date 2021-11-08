//
//  OnboardingQuickStartCell.swift
//  godtools
//
//  Created by Robert Eldredge on 11/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit


protocol OnboardingQuickStartCellDelegate: class {
    
    func buttonTapped(dismissOnboardingTutorialType: OnboardingQuickStartView.DismissOnboardingTutorialType)
}

class OnboardingQuickStartCell: UICollectionViewCell {
    
    static let nibName: String = "OnboardingQuickStartCell"
    static let reuseIdentifier: String = "OnboardingQuickStartCellReuseIdentifier"
    
    private weak var delegate: OnboardingQuickStartCellDelegate?
    
    private var viewModel: OnboardingQuickStartCellViewModelType?
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var linkButton: UIButton!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        setupBinding()
    }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        titleLabel.text = nil
        linkButton.setTitle(nil, for: .normal)
    }
    
    func configure(viewModel: OnboardingQuickStartCellViewModelType, delegate: OnboardingQuickStartCellDelegate?) {
            
        self.delegate = delegate
        
        self.viewModel = viewModel
        
        titleLabel.text = viewModel.title
        linkButton.setTitle(viewModel.buttonTitle, for: .normal)
    }
    
    private func setupBinding() {
        
        linkButton.addTarget(self, action: #selector(linkButtonTapped), for: .touchUpInside)
    }
    
    @objc func linkButtonTapped() {
        
        guard let dismissOnboardingTutorialType = viewModel?.dismissOnboardingTutorialType else {
            return
        }
        
        delegate?.buttonTapped(dismissOnboardingTutorialType: dismissOnboardingTutorialType)
    }
}
