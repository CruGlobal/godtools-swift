//
//  SetupParallelLanguageView.swift
//  godtools
//
//  Created by Robert Eldredge on 11/19/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import UIKit

class SetupParallelLanguageView: UIViewController {
    
    private let viewModel: SetupParallelLanguageViewModelType
    
    private var closeButton: UIBarButtonItem?

    @IBOutlet weak private var animatedView: AnimatedView!
    @IBOutlet weak private var promptLabel: UILabel!
    @IBOutlet weak private var selectLanguageButtonView: UIView!
    @IBOutlet weak private var selectLanguageButtonGestureRecognizer: UITapGestureRecognizer!
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
        
        setupLayout()
        setupBinding()
    }
    
    private func setupBinding() {
        
        animatedView.configure(viewModel: viewModel.animatedViewModel)
        
        selectLanguageButtonGestureRecognizer.addTarget(self, action: #selector(handleSelectLanguageTapped))
        
        yesButton.addTarget(self, action: #selector(handleYesTapped), for: .touchUpInside)
        
        noButton.addTarget(self, action: #selector(handleNoTapped), for: .touchUpInside)
        
        getStartedButton.addTarget(self, action: #selector(handleGetStartedTapped), for: .touchUpInside)

        viewModel.selectLanguageButtonText.addObserver(self) { [weak self] (buttonText: String) in
            
            self?.selectLanguageButtonTitle.text = buttonText
        }
        
        viewModel.yesNoButtonsHidden.addObserver(self) { [weak self] (isHidden: Bool) in
            
            self?.yesButton.isHidden = isHidden
            self?.noButton.isHidden = isHidden
        }
        
        viewModel.getStartedButtonHidden.addObserver(self) { [weak self] (isHidden: Bool) in
            
            self?.getStartedButton.isHidden = isHidden
        }
    }
    
    private func setupLayout() {
        
        closeButton = addBarButtonItem(
            to: .right,
            image: ImageCatalog.navClose.image,
            color: ColorPalette.gtBlue.color,
            target: self,
            action: #selector(handleCloseTapped)
        )
        
        promptLabel.text = viewModel.promptText
                
        yesButton.setTitle(viewModel.yesButtonText, for: .normal)
        
        noButton.setTitle(viewModel.noButtonText, for: .normal)
        
        getStartedButton.setTitle(viewModel.getStartedButtonText, for: .normal)
        
        setupSelectLanguageButton()
        setupBottomButtons()
    }
    
    func setupSelectLanguageButton() {
        
        selectLanguageButtonView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        selectLanguageButtonView.layer.shadowOffset = CGSize(width: 2, height: 2)
        selectLanguageButtonView.layer.shadowOpacity =  0.25
        selectLanguageButtonView.layer.shadowRadius = 4
        selectLanguageButtonView.layer.masksToBounds = false
        selectLanguageButtonView.layer.cornerRadius = 6
    }
    
    func setupBottomButtons() {
        
        yesButton.layer.cornerRadius = 6
        
        noButton.layer.cornerRadius = 6
        noButton.drawBorder(color: ColorPalette.gtBlue.color)
        noButton.layer.borderWidth = 1
        
        getStartedButton.layer.cornerRadius = 6
    }
    
    @objc func handleSelectLanguageTapped() {
        
        viewModel.selectLanguageTapped()
    }
    
    @objc func handleCloseTapped(barButtonItem: UIBarButtonItem) {
        
        viewModel.closeButtonTapped()
    }
    
    @objc func handleYesTapped() {
        
        viewModel.yesButtonTapped()
    }
    
    @objc func handleNoTapped() {
        
        viewModel.noButtonTapped()
    }
    
    @objc func handleGetStartedTapped() {
        
        viewModel.getStartedButtonTapped()
    }
}
