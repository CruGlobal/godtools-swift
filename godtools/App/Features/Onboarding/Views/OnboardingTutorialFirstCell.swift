//
//  OnboardingTutorialFirstCell.swift
//  godtools
//
//  Created by Robert Eldredge on 9/30/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class OnboardingTutorialFirstCell: UIView, NibBased {

    @IBOutlet weak private var logoImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var videoButton: UIButton!

    required init() {
        super.init(frame: UIScreen.main.bounds)
        loadNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNib()
    }

    func configure(viewModel: OnboardingTutorialFirstCellViewModelType) {

        titleLabel.text = viewModel.title

        if let logoImageName = viewModel.logoImageName, !logoImageName.isEmpty, let logoImage = UIImage(named: logoImageName) {
            logoImageView.image = logoImage
            logoImageView.isHidden = false
        }
        else {
            logoImageView.image = nil
            logoImageView.isHidden = true
        }
    }

    @objc private func handleWatchVideo (button: UIButton) {
        //TODO: Launch Video
    }
}
