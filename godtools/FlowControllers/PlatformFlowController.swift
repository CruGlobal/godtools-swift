//
//  GTPlatformFlowController.swift
//  godtools
//
//  Created by Devserker on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class PlatformFlowController: BaseFlowController, LanguageSettingsViewControllerDelegate, LanguagesTableViewControllerDelegate,
HomeViewControllerDelegate {
    
    override func initialViewController() -> UIViewController {
        let viewController = HomeViewController(nibName: "HomeViewController", bundle: nil)
        viewController.delegate = self
        return viewController
    }
    
    // MARK: - HomeViewControllerDelegate
    
    func moveToUpdateLanguageSettings() {
        let viewController = LanguageSettingsViewController(nibName: "LanguageSettingsViewController", bundle: nil)
        viewController.delegate = self
        self.pushViewController(viewController: viewController)
    }
    
    func moveToAddNewTool() {
    }
    
    // MARK: - GTLanguageSettingsViewControllerDelegate
    
    func moveToLanguagesList(primaryLanguage: Bool) {
        let viewController = LanguagesTableViewController(nibName: "LanguagesTableViewController", bundle: nil)
        viewController.delegate = self
        self.pushViewController(viewController: viewController)
    }
    
    // MARK: - GTLanguagesTableViewControllerDelegate
    
}
