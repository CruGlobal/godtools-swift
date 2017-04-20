//
//  GTPlatformFlowController.swift
//  godtools
//
//  Created by Devserker on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class PlatformFlowController: BaseFlowController, LanguageSettingsViewControllerDelegate, LanguagesTableViewControllerDelegate {
    
    override func initialViewController() -> UIViewController {
        let viewController = LanguageSettingsViewController(nibName: "LanguageSettingsViewController", bundle: nil)
        viewController.delegate = self
        return viewController
    }
    
    // MARK: - GTLanguageSettingsViewControllerDelegate
    
    func moveToLanguagesList(primaryLanguage: Bool) {
        let viewController = LanguagesTableViewController(nibName: "LanguagesTableViewController", bundle: nil)
        viewController.delegate = self
        self.pushViewController(viewController: viewController)
    }
    
    // MARK: - GTLanguagesTableViewControllerDelegate
    
}
