//
//  GTLanguageSettingsViewController.swift
//  godtools
//
//  Created by Devserker on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

protocol LanguageSettingsViewControllerDelegate {
    mutating func moveToLanguagesList(primaryLanguage: Bool)
}

class LanguageSettingsViewController: BaseViewController {
    
    var delegate: LanguageSettingsViewControllerDelegate?
    let languagesManager = LanguagesManager()
    
    @IBOutlet weak var primaryLanguageButton: BlueButton!
    @IBOutlet weak var parallelLanguageButton: BlueButton!
    
    override var screenTitle: String {
        get {
            return "language_settings".localized
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupPrimaryLanguageButton()
        setupParallelLanguageButton()
    }
    
    private func setupPrimaryLanguageButton() {
        let primaryLanguage = self.languagesManager.loadPrimaryLanguageFromDisk()
        let title = primaryLanguage != nil ? primaryLanguage!.localizedName() : "select_primary_language".localized
        
        primaryLanguageButton.setTitle(title, for: .normal)
    }
    
    private func setupParallelLanguageButton() {
        let parallelLanguageId = GTSettings.shared.parallelLanguageId
        let title = parallelLanguageId != nil ?
            self.languagesManager.loadFromDisk(id: parallelLanguageId!)?.localizedName() : "select_parallel_language".localized
        
        parallelLanguageButton.setTitle(title, for: .normal)
        parallelLanguageButton.accessibilityIdentifier = "select_parallel_language"
    }

    // MARK: - Actions
    
    @IBAction func pressSelectPrimaryLanguage(_ sender: Any) {
        self.languagesManager.selectingPrimaryLanguage = true
        self.delegate?.moveToLanguagesList(primaryLanguage: true)
    }
    
    @IBAction func pressSelectParallelLanguage(_ sender: Any) {
        self.languagesManager.selectingPrimaryLanguage = false
        self.delegate?.moveToLanguagesList(primaryLanguage: false)
    }
    
    // MARK: - Analytics
    
    override func screenName() -> String {
        return "Language Settings"
    }
    
    override func siteSection() -> String {
        return "menu"
    }
    
}
