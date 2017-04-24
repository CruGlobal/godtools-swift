//
//  GTPlatformFlowController.swift
//  godtools
//
//  Created by Devserker on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class PlatformFlowController: BaseFlowController, LanguageSettingsViewControllerDelegate, LanguagesTableViewControllerDelegate,
HomeViewControllerDelegate, ToolDetailViewControllerDelegate, AddToolsViewControllerDelegate {
    
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
        let viewController = AddToolsViewController(nibName: "AddToolsViewController", bundle: nil)
        viewController.delegate = self
        self.pushViewController(viewController: viewController)
    }
    
    func moveToToolDetail() {
        let viewController = ToolDetailViewController(nibName: "ToolDetailViewController", bundle: nil)
        viewController.delegate = self
        self.pushViewController(viewController: viewController)
    }
    
    func moveToTract() {
        let viewController = TractViewController(nibName: String(describing: TractViewController.self), bundle: nil)
        pushViewController(viewController: viewController)
    }
    
    // MARK: - GTLanguageSettingsViewControllerDelegate
    
    func moveToLanguagesList(primaryLanguage: Bool) {
        let viewController = LanguagesTableViewController(nibName: "LanguagesTableViewController", bundle: nil)
        viewController.delegate = self
        self.pushViewController(viewController: viewController)
    }
    
    // MARK: - GTLanguagesTableViewControllerDelegate
    
}
