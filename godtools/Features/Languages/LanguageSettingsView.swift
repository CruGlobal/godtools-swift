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
    @IBOutlet weak private var primaryLanguageLabel: GTLabel!
    @IBOutlet weak private var primaryLanguageButton: BlueButton!
    @IBOutlet weak private var parallelLanguageLabel: GTLabel!
    @IBOutlet weak private var shareGodToolsLabel: GTLabel!
    @IBOutlet weak private var parallelLanguageButton: BlueButton!
    @IBOutlet weak private var exclamationImageView: UIImageView!
    @IBOutlet weak private var languageAvailabilityLabel: GTLabel!
    
    required init(viewModel: LanguageSettingsViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: "LanguageSettingsView", bundle: nil)
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
        
    }
    
    private func setupBinding() {
        
        viewModel.navTitle.addObserver(self) { [weak self] (navTitle: String) in
            self?.title = navTitle
        }
        
        viewModel.primaryLanguageButtonTitle.addObserver(self) { [weak self] (title: String) in
            self?.primaryLanguageButton.setTitle(title, for: .normal)
        }
        
        viewModel.parallelLanguageButtonTitle.addObserver(self) { [weak self] (title: String) in
            self?.parallelLanguageButton.setTitle(title, for: .normal)
            self?.parallelLanguageButton.accessibilityIdentifier = "select_parallel_language"
        }
    }
    
    @objc func handlePrimaryLanguage(button: UIButton) {
        viewModel.choosePrimaryLanguageTapped()
    }
    
    @objc func handleParallelLanguage(button: UIButton) {
        viewModel.chooseParallelLanguageTapped()
    }
}
