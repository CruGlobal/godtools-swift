//
//  SetupParallelLanguageView.swift
//  godtools
//
//  Created by Robert Eldredge on 11/19/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import Lottie
import UIKit

class SetupParallelLanguageView: UIViewController {
    
    private let viewModel: SetupParallelLanguageViewModelType
    
    private var closeButton: UIBarButtonItem?

    @IBOutlet weak private var animatedView: AnimatedView!
    @IBOutlet weak private var promptLabel: UILabel!
    @IBOutlet weak private var selectLanguageButton: UIButton!
    //@IBOutlet weak private var languagePicker: UIPickerView!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    //@IBOutlet weak private var selectLanguageButton: UIButton!
    //@IBOutlet weak private var getStartedButton: UIButton!

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
        
        selectLanguageButton.addTarget(self, action: #selector(handleSelectLanguageTapped), for: .touchUpInside)
        
        yesButton.addTarget(self, action: #selector(handleYesTapped), for: .touchUpInside)
        
        noButton.addTarget(self, action: #selector(handleNoTapped), for: .touchUpInside)
        
        setupBinding()
        setupLayout()
    }
    
    private func setupBinding() {
        
        animatedView.configure(viewModel: viewModel.animatedViewModel)
        
        promptLabel.text = viewModel.promptText
        
        selectLanguageButton.setTitle(viewModel.languagePickerLabelText, for: .normal)
        
        yesButton.setTitle(viewModel.yesButtonText, for: .normal)
        
        noButton.setTitle(viewModel.noButtonText, for: .normal)
    }
    
    private func setupLayout() {
        
        closeButton = addBarButtonItem(
            to: .right,
            image: ImageCatalog.navClose.image,
            color: ColorPalette.gtBlue.color,
            target: self,
            action: #selector(handleCloseTapped)
        )
        
        setupSelectLanguageButton()
        setupBottomButtons()
    }
    
    func setupSelectLanguageButton() {
        
        selectLanguageButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        selectLanguageButton.layer.shadowOffset = CGSize(width: 2, height: 4)
        selectLanguageButton.layer.shadowOpacity = 1.0
        selectLanguageButton.layer.shadowRadius = 0.0
        selectLanguageButton.layer.masksToBounds = false
        selectLanguageButton.layer.cornerRadius = 6
        
        selectLanguageButton.setImageColor(color: UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1))
        
        selectLanguageButton.layoutIfNeeded()
        
        let buttonWidth = selectLanguageButton.frame.size.width
        let imageWidth = selectLanguageButton.image(for: .normal)?.size.width ?? 0
        
        selectLanguageButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: buttonWidth - imageWidth - 10, bottom: 0, right: 0)
    }
    
    func setupBottomButtons() {
        
        yesButton.layer.cornerRadius = 6
        
        noButton.layer.cornerRadius = 6
        noButton.drawBorder(color: ColorPalette.gtBlue.color)
        noButton.layer.borderWidth = 1
    }
    
    @objc func handleSelectLanguageTapped() {
        viewModel.selectLanguageTapped()
    }
    
    @objc func handleCloseTapped(barButtonItem: UIBarButtonItem) {
        viewModel.closeButtonTapped()
    }
    
    @objc func handleYesTapped(barButtonItem: UIBarButtonItem) {
        viewModel.yesButtonTapped()
    }
    
    @objc func handleNoTapped(barButtonItem: UIBarButtonItem) {
        viewModel.noButtonTapped()
    }
}
