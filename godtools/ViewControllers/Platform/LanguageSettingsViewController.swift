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
    
    override var screenTitle: String {
        get {
            return "language_settings".localized
        }
    }
    
    // MARK: - Actions
    
    @IBAction func pressSelectPrimaryLanguage(_ sender: Any) {
        self.delegate?.moveToLanguagesList(primaryLanguage: true)
    }
    
    @IBAction func pressSelectParallelLanguage(_ sender: Any) {
        self.delegate?.moveToLanguagesList(primaryLanguage: false)
    }
    
}
