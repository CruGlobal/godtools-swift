//
//  GTPlatformFlowController.swift
//  godtools
//
//  Created by Devserker on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class PlatformFlowController: BaseFlowController, HomeViewControllerDelegate, AddToolsViewControllerDelegate, MasterHomeViewControllerDelegate {
    
    override func initialViewController() -> UIViewController {
        let viewController = MasterHomeViewController(nibName: "MasterHomeViewController", bundle: nil)
        viewController.delegate = self
        return viewController
    }
    
    func goToUniversalLinkedResource(_ resource: DownloadedResource, language: Language, page: Int) {
        let viewController = TractViewController(nibName: String(describing: TractViewController.self), bundle: nil)
        viewController.resource = resource
        viewController.currentPage = page
        viewController.universalLinkLanguage = language
        viewController.arrivedByUniversalLink = true
        
        pushViewController(viewController: viewController)
    }
    
    // MARK: - HomeViewControllerDelegate
    
    func moveToToolDetail(resource: DownloadedResource) {
        let viewController = ToolDetailViewController(nibName: String(describing:ToolDetailViewController.self), bundle: nil)
        viewController.resource = resource
        self.pushViewController(viewController: viewController)
    }
    
    func moveToTract(resource: DownloadedResource) {
        let viewController = TractViewController(nibName: String(describing: TractViewController.self), bundle: nil)
        viewController.resource = resource
        pushViewController(viewController: viewController)
    }
    
}
