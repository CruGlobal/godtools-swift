//
//  LessonEvaluationView.swift
//  godtools
//
//  Created by Levi Eggert on 9/29/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class LessonEvaluationView: UIView, NibBased {
    
    private let viewModel: LessonEvaluationViewModelType
            
    @IBOutlet weak private var closeButton: UIButton!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var wasThisHelpfulLabel: UILabel!
    @IBOutlet weak private var yesButton: PrimaryEvaluationOptionButton!
    @IBOutlet weak private var noButton: PrimaryEvaluationOptionButton!
    @IBOutlet weak private var shareFaithLabel: UILabel!
    @IBOutlet weak private var chooseScaleSliderView: ChooseScaleSliderView!
    @IBOutlet weak private var sendButton: UIButton!
    
    required init(viewModel: LessonEvaluationViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: UIScreen.main.bounds)
        
        loadNib()
        setupLayout()
        setupBinding()
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        yesButton.addTarget(self, action: #selector(yesButtonTapped), for: .touchUpInside)
        noButton.addTarget(self, action: #selector(noButtonTapped), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func setupLayout() {

    }
    
    private func setupBinding() {
        
        titleLabel.text = viewModel.title
        wasThisHelpfulLabel.text = viewModel.wasThisHelpful
        yesButton.setTitle(viewModel.yesButtonTitle, for: .normal)
        noButton.setTitle(viewModel.noButtonTitle, for: .normal)
        shareFaithLabel.text = viewModel.shareFaith
        sendButton.setTitle(viewModel.sendButtonTitle, for: .normal)
    }
    
    @objc func closeButtonTapped() {
        
        viewModel.closeTapped()
    }
    
    @objc func yesButtonTapped() {
        
    }
    
    @objc func noButtonTapped() {
        
    }
    
    @objc func sendButtonTapped() {
        
    }
}
