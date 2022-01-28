//
//  SetupParallelLanguageView.swift
//  godtools
//
//  Created by Robert Eldredge on 11/19/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class SetupParallelLanguageView: UIViewController {
    
    private let viewModel: SetupParallelLanguageViewModelType
    
    private let buttonCornerRadius: CGFloat = 6
    
    private var tapRecognizer: UITapGestureRecognizer!
    
    @IBOutlet weak private var animatedView: AnimatedView!
    @IBOutlet weak private var promptLabel: UILabel!
    @IBOutlet weak private var selectLanguageButtonView: UIView!
    @IBOutlet weak private var selectLanguageButtonTitle: UILabel!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var getStartedButton: UIButton!

    required init(viewModel: SetupParallelLanguageViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(nibName: String(describing: SetupParallelLanguageView.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
        print("x deinit: \(type(of: self))")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSelectLanguageTapped))
        tapRecognizer.cancelsTouchesInView = false
        selectLanguageButtonView.addGestureRecognizer(tapRecognizer)
        
        yesButton.addTarget(self, action: #selector(handleYesTapped), for: .touchUpInside)
        noButton.addTarget(self, action: #selector(handleNoTapped), for: .touchUpInside)
        getStartedButton.addTarget(self, action: #selector(handleGetStartedTapped), for: .touchUpInside)
        
        setupLayout()
        setupBinding()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        selectLanguageButtonView.removeGestureRecognizer(self.tapRecognizer)
    }
    
    private func setupLayout() {
        
        promptLabel.text = viewModel.promptText
                
        yesButton.setTitle(viewModel.yesButtonText, for: .normal)
        
        noButton.setTitle(viewModel.noButtonText, for: .normal)
        
        getStartedButton.setTitle(viewModel.getStartedButtonText, for: .normal)
        
        setupSelectLanguageButton()
        setupBottomButtons()
    }
    
    private func setupBinding() {
        
        animatedView.configure(viewModel: viewModel.animatedViewModel)
        
        viewModel.selectLanguageButtonText.addObserver(self) { [weak self] (buttonText: String) in
                        
            self?.selectLanguageButtonTitle?.text = buttonText
        }
        
        viewModel.yesNoButtonsHidden.addObserver(self) { [weak self] (isHidden: Bool) in
            
            self?.yesButton?.isHidden = isHidden
            self?.noButton?.isHidden = isHidden
        }
        
        viewModel.getStartedButtonHidden.addObserver(self) { [weak self] (isHidden: Bool) in
            
            self?.getStartedButton?.isHidden = isHidden
        }
    }
    
    private func setupSelectLanguageButton() {
        
        selectLanguageButtonView.isUserInteractionEnabled = true
        
        selectLanguageButtonView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        selectLanguageButtonView.layer.shadowOffset = CGSize(width: 2, height: 2)
        selectLanguageButtonView.layer.shadowOpacity =  0.25
        selectLanguageButtonView.layer.shadowRadius = 4
        selectLanguageButtonView.layer.masksToBounds = false
        selectLanguageButtonView.layer.cornerRadius = 6
    }
    
    private func setupBottomButtons() {
        
        yesButton.layer.cornerRadius = buttonCornerRadius
        
        noButton.layer.cornerRadius = buttonCornerRadius
        noButton.drawBorder(color: ColorPalette.gtBlue.color)
        noButton.layer.borderWidth = 1
        
        getStartedButton.layer.cornerRadius = buttonCornerRadius
    }
    
    @objc private func handleSelectLanguageTapped(recognizer: UITapGestureRecognizer) {
        
        viewModel.languageSelectorTapped()
    }
    
    @objc private func handleYesTapped() {
        
        viewModel.yesButtonTapped()
    }
    
    @objc private func handleNoTapped() {
        
        viewModel.noButtonTapped()
    }
    
    @objc private func handleGetStartedTapped() {
        
        viewModel.getStartedButtonTapped()
    }
}

// MARK: - TransparentModalCustomView

extension SetupParallelLanguageView: TransparentModalCustomView {
    
    var modal: UIView {
        
        return self.view
    }
    
    var modalInsets: UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    func transparentModalDidLayout() {
        
    }
}
