//
//  GTPlatformFlowController.swift
//  godtools
//
//  Created by Devserker on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class PlatformFlowController: BaseFlowController, HomeViewControllerDelegate, AddToolsViewControllerDelegate, MasterHomeViewControllerDelegate {
    
    private var onboardingFlow: OnboardingFlow?
    private var tutorialFlow: TutorialFlow?
    
    override func initialViewController() -> UIViewController {
        let viewController = MasterHomeViewController(
            flowDelegate: self,
            delegate: self,
            tutorialServices: appDiContainer.tutorialServices
        )
        return viewController
    }
    
    override func navigate(step: FlowStep) {
    
        switch step {
        
        case .showOnboardingTutorial(let animated):
            
            let onboardingFlow = OnboardingFlow(
                flowDelegate: self,
                appDiContainer: appDiContainer
            )
            
            navigationController.present(onboardingFlow.navigationController, animated: animated, completion: nil)
            
            self.onboardingFlow = onboardingFlow
            
        case .dismissOnboardingTutorial:
            
            navigationController.dismiss(animated: true) { [weak self] in
                self?.onboardingFlow = nil
            }
            
        case .openTutorialTapped:
            let tutorialFlow = TutorialFlow(
                flowDelegate: self,
                appDiContainer: appDiContainer
            )
            navigationController.present(tutorialFlow.navigationController, animated: true, completion: nil)
            self.tutorialFlow = tutorialFlow
            
        case .closeTappedFromTutorial:
            navigationController.dismiss(animated: true, completion: { [weak self] in
                self?.tutorialFlow = nil
            })
            
        default:
            break
        }
    }
    
    func goToUniversalLinkedResource(_ resource: DownloadedResource, language: Language, page: Int, parallelLanguageCode: String? = nil) {
        let viewController = TractViewController(nibName: String(describing: TractViewController.self), bundle: nil)
        viewController.resource = resource
        viewController.currentPage = page
        viewController.universalLinkLanguage = language
        viewController.arrivedByUniversalLink = true
        GTSettings.shared.parallelLanguageCode = parallelLanguageCode
        
        pushViewController(viewController: viewController)
    }
    
    // MARK: - HomeViewControllerDelegate
    
    func moveToToolDetail(resource: DownloadedResource) {
        let viewController = ToolDetailViewController(nibName: String(describing:ToolDetailViewController.self), bundle: nil)
        viewController.resource = resource
        viewController.delegate = self
        self.pushViewController(viewController: viewController)
    }
    
    func moveToTract(resource: DownloadedResource) {
        let viewController = TractViewController(nibName: String(describing: TractViewController.self), bundle: nil)
        viewController.resource = resource
        pushViewController(viewController: viewController)
    }
    
    func moveToArticle(resource: DownloadedResource) {
        let viewController = ArticleToolViewController.create()
        viewController.resource = resource
        pushViewController(viewController: viewController)
    }
    
}

extension PlatformFlowController: ToolDetailViewControllerDelegate {
    
    func openToolTapped(toolDetail: ToolDetailViewController, resource: DownloadedResource) {
        moveToTract(resource: resource)
    }
}
