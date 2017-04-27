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
        let viewController = LanguageSettingsViewController(nibName: String(describing:LanguageSettingsViewController.self), bundle: nil)
        viewController.delegate = self
        self.pushViewController(viewController: viewController)
    }
    
    func moveToAddNewTool() {
        let viewController = AddToolsViewController(nibName: String(describing:AddToolsViewController.self), bundle: nil)
        viewController.delegate = self
        self.pushViewController(viewController: viewController)
    }
    
    func moveToToolDetail() {
        let viewController = ToolDetailViewController(nibName: String(describing:ToolDetailViewController.self), bundle: nil)
        viewController.delegate = self
        self.pushViewController(viewController: viewController)
    }
    
    func moveToTract() {
        let viewController = TractViewController(nibName: String(describing: TractViewController.self), bundle: nil)
        pushViewController(viewController: viewController)
    }
    
    // MARK: - GTLanguageSettingsViewControllerDelegate
    
    func moveToLanguagesList(primaryLanguage: Bool) {
        let viewController = LanguagesTableViewController(nibName: String(describing:LanguagesTableViewController.self), bundle: nil)
        viewController.delegate = self
        self.pushViewController(viewController: viewController)
    }
    
    // MARK: - GTLanguagesTableViewControllerDelegate
    
}
