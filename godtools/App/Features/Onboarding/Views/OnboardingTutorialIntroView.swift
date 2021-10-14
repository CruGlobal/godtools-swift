//
//  OnboardingTutorialIntroView.swift
//  godtools
//
//  Created by Robert Eldredge on 9/30/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class OnboardingTutorialIntroView: UIView, NibBased {

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

    func configure(viewModel: OnboardingTutorialIntroViewModelType) {

        titleLabel.text = viewModel.title

        logoImageView.image = viewModel.logoImage
        logoImageView.isHidden = viewModel.logoImage == nil
    }

    @objc private func handleWatchVideo (button: UIButton) {
        //TODO: Launch Video
    }
}
