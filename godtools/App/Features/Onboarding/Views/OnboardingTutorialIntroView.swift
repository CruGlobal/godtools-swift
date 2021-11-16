//
//  OnboardingTutorialIntroView.swift
//  godtools
//
//  Created by Robert Eldredge on 9/30/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class OnboardingTutorialIntroView: UIView, NibBased {
    
    @IBOutlet weak private var logoImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var videoButton: UIButton!
    
    private var viewModel: OnboardingTutorialIntroViewModelType?
    
    required init() {
        
        super.init(frame: UIScreen.main.bounds)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialize() {
        
        loadNib()
        
        videoButton.addTarget(self, action: #selector(videoLinkTapped(button:)), for: .touchUpInside)
    }
    
    private var youtubePlayerParameters: [String : Any]? {
        
        let playsInFullScreen = 0
        
        return ["playsinline": playsInFullScreen]
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        videoButton.centerTitleAndSetImageRightOfTitleWithSpacing(spacing: 16)
    }
    
    func configure(viewModel: OnboardingTutorialIntroViewModelType) {

        self.viewModel = viewModel
        
        titleLabel.text = viewModel.title
        videoButton.setTitle(viewModel.videoLinkLabel, for: .normal)
        videoButton.setImage(UIImage(named: "play_icon"), for: .normal)
        videoButton.setImageColor(color: UIColor(red: 0.23, green: 0.64, blue: 0.86, alpha: 1.0))
        logoImageView.image = viewModel.logoImage
        
        layoutIfNeeded()
    }
    
    @objc private func videoLinkTapped (button: UIButton) {
        
        viewModel?.videoLinkTapped()
    }
}
