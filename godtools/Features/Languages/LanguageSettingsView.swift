//
//  LanguageSettingsView.swift
//  godtools
//
//  Created by Levi Eggert on 4/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class LanguageSettingsView: UIViewController {
    
    private let viewModel: LanguageSettingsViewModelType
            
    @IBOutlet weak private var languageImageView: UIImageView!
    @IBOutlet weak private var primaryLanguageTitleLabel: UILabel!
    @IBOutlet weak private var primaryLanguageButton: UIButton!
    @IBOutlet weak private var parallelLanguageTitleLabel: UILabel!
    @IBOutlet weak private var shareGodToolsLabel: UILabel!
    @IBOutlet weak private var parallelLanguageButton: UIButton!
    @IBOutlet weak private var exclamationImageView: UIImageView!
    @IBOutlet weak private var languageAvailabilityLabel: UILabel!
    
    required init(viewModel: LanguageSettingsViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: LanguageSettingsView.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    override func viewDidLoad() {
        print("view didload: \(type(of: self))")
        super.viewDidLoad()
        
        setupLayout()
        setupBinding()
        
        addDefaultNavBackItem()
        
        primaryLanguageButton.addTarget(
            self,
            action: #selector(handlePrimaryLanguage(button:)),
            for: .touchUpInside
        )
        
        parallelLanguageButton.addTarget(
            self,
            action: #selector(handleParallelLanguage(button:)),
            for: .touchUpInside
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.pageViewed()
    }
    
    private func setupLayout() {
        
        let buttonCornerRadius: CGFloat = 6
        primaryLanguageButton.layer.cornerRadius = buttonCornerRadius
        parallelLanguageButton.layer.cornerRadius = buttonCornerRadius
    }
    
    private func setupBinding() {
        
        viewModel.navTitle.addObserver(self) { [weak self] (navTitle: String) in
            self?.title = navTitle
        }
        
        primaryLanguageTitleLabel.text = viewModel.primaryLanguageTitle
        
        viewModel.primaryLanguageButtonTitle.addObserver(self) { [weak self] (title: String) in
            self?.primaryLanguageButton.setTitle(title, for: .normal)
        }
        
        parallelLanguageTitleLabel.text = viewModel.parallelLanguageTitle
        
        shareGodToolsLabel.text = viewModel.shareGodToolsInNativeLanguage
        
        viewModel.parallelLanguageButtonTitle.addObserver(self) { [weak self] (title: String) in
            self?.parallelLanguageButton.setTitle(title, for: .normal)
            self?.parallelLanguageButton.accessibilityIdentifier = "select_parallel_language"
        }
        
        languageAvailabilityLabel.text = viewModel.languageAvailability
    }
    
    @objc func handlePrimaryLanguage(button: UIButton) {
        viewModel.choosePrimaryLanguageTapped()
    }
    
    @objc func handleParallelLanguage(button: UIButton) {
        viewModel.chooseParallelLanguageTapped()
    }
}
