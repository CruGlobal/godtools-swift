//
//  MobileContentRendererNavigation.swift
//  godtools
//
//  Created by Levi Eggert on 6/3/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

protocol MobileContentRendererNavigationDelegate: AnyObject {
    
    func mobileContentRendererNavigationDismissRenderer(navigation: MobileContentRendererNavigation, event: DismissToolEvent)
    func mobileContentRendererNavigationDeepLink(navigation: MobileContentRendererNavigation, deepLink: ParsedDeepLinkType)
}

class MobileContentRendererNavigation {
    
    private let appDiContainer: AppDiContainer
    private let navigationController: UINavigationController
    private let exitLinkAnalytics: ExitLinkAnalytics
    
    private var toolTraining: ToolTrainingView?
    
    private weak var delegate: MobileContentRendererNavigationDelegate?
    
    init(delegate: MobileContentRendererNavigationDelegate, appDiContainer: AppDiContainer, navigationController: UINavigationController, exitLinkAnalytics: ExitLinkAnalytics) {
        
        self.delegate = delegate
        self.appDiContainer = appDiContainer
        self.navigationController = navigationController
        self.exitLinkAnalytics = exitLinkAnalytics
    }
    
    func buttonWithUrlTapped(url: String, exitLink: ExitLinkModel) {
        
        guard let url = URL(string: url) else {
            return
        }
        
        let deepLinkingService: DeepLinkingServiceType = AppDiContainer.getNewDeepLinkingService(loggingEnabled: false)
        let deepLink: ParsedDeepLinkType? = deepLinkingService.parseDeepLink(incomingDeepLink: .url(incomingUrl: IncomingDeepLinkUrl(url: url)))
        
        if let deepLink = deepLink {
            
            delegate?.mobileContentRendererNavigationDeepLink(navigation: self, deepLink: deepLink)
        }
        else {
            
            exitLinkAnalytics.trackExitLink(exitLink: exitLink)
            
            UIApplication.shared.open(url)
        }
    }
    
    func dismissTool(event: DismissToolEvent) {
        
        delegate?.mobileContentRendererNavigationDismissRenderer(navigation: self, event: event)
    }
    
    func errorOccurred(error: MobileContentErrorViewModel) {
        
        let view = MobileContentErrorView(viewModel: error)
        
        navigationController.present(view.controller, animated: true, completion: nil)
    }
    
    func trainingTipTapped(event: TrainingTipEvent) {
                
        presentToolTraining(event: event)
    }
    
    private func presentToolTraining(event: TrainingTipEvent) {
        
        let pageViewFactories: MobileContentRendererPageViewFactories = MobileContentRendererPageViewFactories(
            type: .trainingTip,
            appDiContainer: appDiContainer
        )
        
        let languageTranslationManifest = MobileContentRendererLanguageTranslationManifest(manifest: event.renderedPageContext.manifest, language: event.renderedPageContext.language)
        
        let navigation = MobileContentRendererNavigation(
            delegate: self,
            appDiContainer: appDiContainer,
            navigationController: navigationController,
            exitLinkAnalytics: exitLinkAnalytics
        )
        
        let pageRenderer = MobileContentPageRenderer(
            sharedState: State(),
            resource: event.renderedPageContext.resource,
            primaryLanguage: event.renderedPageContext.primaryRendererLanguage,
            languageTranslationManifest: languageTranslationManifest,
            pageViewFactories: pageViewFactories,
            navigation: navigation,
            manifestResourcesCache: appDiContainer.getManifestResourcesCache()
        )
                           
        let viewModel = ToolTrainingViewModel(
            pageRenderer: pageRenderer,
            renderedPageContext: event.renderedPageContext,
            trainingTipId: event.trainingTipId,
            tipModel: event.tipModel,
            analytics: appDiContainer.analytics,
            localizationServices: appDiContainer.localizationServices,
            viewedTrainingTips: appDiContainer.getViewedTrainingTipsService(),
            closeTappedClosure: { [weak self] in
                self?.dismissToolTraining()
        })
        
        let view = ToolTrainingView(viewModel: viewModel)
        
        navigationController.present(view, animated: true, completion: nil)
        
        self.toolTraining = view
    }
    
    private func dismissToolTraining() {
        
        guard toolTraining != nil else {
            return
        }
        
        navigationController.dismiss(animated: true, completion: nil)
        toolTraining = nil
    }
}

extension MobileContentRendererNavigation: MobileContentRendererNavigationDelegate {
    
    func mobileContentRendererNavigationDismissRenderer(navigation: MobileContentRendererNavigation, event: DismissToolEvent) {
        dismissToolTraining()
    }
    
    func mobileContentRendererNavigationDeepLink(navigation: MobileContentRendererNavigation, deepLink: ParsedDeepLinkType) {
        
    }
}
