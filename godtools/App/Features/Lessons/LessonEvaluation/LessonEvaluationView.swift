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
    private let chooseScaleMinValue: Int = 1
    private let chooseScaleMaxValue: Int = 10
    private let chooseScaleInitialProgressValue: CGFloat = 0.5
            
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

        chooseScaleSliderView.setMinScaleValue(minScaleValue: chooseScaleMinValue, maxScaleValue: chooseScaleMaxValue)
        chooseScaleSliderView.setProgress(progressValue: chooseScaleInitialProgressValue)
        
        sendButton.layer.cornerRadius = yesButton.layer.cornerRadius
    }
    
    private func setupBinding() {
        
        titleLabel.text = viewModel.title
        wasThisHelpfulLabel.text = viewModel.wasThisHelpful
        yesButton.setTitle(viewModel.yesButtonTitle, for: .normal)
        noButton.setTitle(viewModel.noButtonTitle, for: .normal)
        shareFaithLabel.text = viewModel.shareFaith
        sendButton.setTitle(viewModel.sendButtonTitle, for: .normal)
        
        viewModel.yesIsSelected.addObserver(self) { [weak self] (isSelected: Bool) in
            
            let optionState: PrimaryEvaluationOptionState = isSelected ? .selected : .deSelected
            self?.yesButton.setOptionState(optionState: optionState)
        }
        
        viewModel.noIsSelected.addObserver(self) { [weak self] (isSelected: Bool) in
            
            let optionState: PrimaryEvaluationOptionState = isSelected ? .selected : .deSelected
            self?.noButton.setOptionState(optionState: optionState)
        }
    }
    
    @objc func closeButtonTapped() {
        
        viewModel.closeTapped()
    }
    
    @objc func yesButtonTapped() {
        
        viewModel.yesTapped()
    }
    
    @objc func noButtonTapped() {
        
        viewModel.noTapped()
    }
    
    @objc func sendButtonTapped() {
        
        viewModel.sendTapped()
    }
}

// MARK: - TransparentModalCustomView

extension LessonEvaluationView: TransparentModalCustomView {
    
    var view: UIView {
        return self
    }
    
    func transparentModalDidLayout() {
        chooseScaleSliderView.setProgress(progressValue: chooseScaleInitialProgressValue)
    }
}
