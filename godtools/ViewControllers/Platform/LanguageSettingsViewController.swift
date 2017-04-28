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
    let languagesManager = LanguagesManager.shared
    
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
        if primaryLanguage != nil {
            primaryLanguageButton.setTitle(primaryLanguage!.localizedName, for: .normal)
        } else {
            primaryLanguageButton.setTitle("select_primary_language".localized, for: .normal)
        }
    }

    private func setupParallelLanguageButton() {
        if GTSettings.shared.parallelLanguageId != nil {
            let parallelLanguage = self.languagesManager.loadFromDisk(id: GTSettings.shared.parallelLanguageId!)
            parallelLanguageButton.setTitle(parallelLanguage.localizedName, for: .normal)
        } else {
            parallelLanguageButton.setTitle("select_parallel_language".localized, for: .normal)
        }
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
    
}
