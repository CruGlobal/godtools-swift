//
//  GTPlatformFlowController.swift
//  godtools
//
//  Created by Devserker on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class GTPlatformFlowController: GTBaseFlowController, GTLanguageSettingsViewControllerDelegate, GTLanguagesTableViewControllerDelegate {
    
    override func initialViewController() -> UIViewController {
        let viewController = GTLanguageSettingsViewController(nibName: "GTLanguageSettingsViewController", bundle: nil)
        viewController.delegate = self
        return viewController
    }
    
    // MARK: - GTLanguageSettingsViewControllerDelegate
    
    func moveToLanguagesList(primaryLanguage: Bool) {
        let viewController = GTLanguagesTableViewController(nibName: "GTLanguagesTableViewController", bundle: nil)
        viewController.delegate = self
        self.pushViewController(viewController: viewController)
    }
    
    // MARK: - GTLanguagesTableViewControllerDelegate
    
}
