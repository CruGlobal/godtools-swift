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
    func mobileContentRendererNavigationDeepLink(navigation: MobileContentRendererNavigation, deepLink: MobileContentRendererNavigationDeepLinkType)
}

class MobileContentRendererNavigation {
    
    private let appDiContainer: AppDiContainer
    
    private var toolTraining: ToolTrainingView?
    
    private weak var parentFlow: ToolNavigationFlow?
    private weak var delegate: MobileContentRendererNavigationDelegate?
    
    init(parentFlow: ToolNavigationFlow, delegate: MobileContentRendererNavigationDelegate, appDiContainer: AppDiContainer) {
        
        self.parentFlow = parentFlow
        self.delegate = delegate
        self.appDiContainer = appDiContainer
    }
    
    func buttonWithUrlTapped(url: URL, screenName: String, siteSection: String, siteSubSection: String, contentLanguage: String?) {
        
        let deepLinkingService: DeepLinkingService = appDiContainer.dataLayer.getDeepLinkingService()
        let deepLink: ParsedDeepLinkType? = deepLinkingService.parseDeepLink(incomingDeepLink: .url(incomingUrl: IncomingDeepLinkUrl(url: url)))
        
        if let deepLink = deepLink {
            
            switch deepLink {
            
            case .dashboard:
                break
                
            case .allToolsList:
                break
            
            case .articleAemUri( _):
                break
            
            case .favoritedToolsList:
                break
            
            case .lessonsList:
               
                delegate?.mobileContentRendererNavigationDeepLink(navigation: self, deepLink: .lessonsList)
            
            case .onboarding:
                break
                
            case .tool(let toolDeepLink):
                
                parentFlow?.navigateToToolFromToolDeepLink(toolDeepLink: toolDeepLink, selectedLanguageIndex: nil, didCompleteToolNavigation: nil)
            }
        }
        else {
            
            parentFlow?.navigateToURL(url: url, screenName: screenName, siteSection: siteSection, siteSubSection: siteSubSection, contentLanguage: contentLanguage, contentLanguageSecondary: nil)
        }
    }
    
    func dismissTool(event: DismissToolEvent) {
        
        delegate?.mobileContentRendererNavigationDismissRenderer(navigation: self, event: event)
    }
    
    func errorOccurred(error: MobileContentErrorViewModel) {
        
        let view = MobileContentErrorView(viewModel: error)
        
        parentFlow?.navigationController.present(view.controller, animated: true, completion: nil)
    }
    
    func trainingTipTapped(event: TrainingTipEvent) {
                
        presentToolTraining(event: event)
    }
    
    private func presentToolTraining(event: TrainingTipEvent) {
        
        guard let parentFlow = parentFlow else {
            return
        }

        let pageViewFactories: MobileContentRendererPageViewFactories = MobileContentRendererPageViewFactories(
            type: .trainingTip,
            appDiContainer: appDiContainer
        )
        
        let languageTranslationManifest = MobileContentRendererLanguageTranslationManifest(
            manifest: event.renderedPageContext.manifest,
            language: event.renderedPageContext.language,
            translation: event.renderedPageContext.translation
        )
        
        let navigation = MobileContentRendererNavigation(
            parentFlow: parentFlow,
            delegate: self,
            appDiContainer: appDiContainer
        )
        
        let pageRenderer = MobileContentPageRenderer(
            sharedState: State(),
            resource: event.renderedPageContext.resource,
            primaryLanguage: event.renderedPageContext.primaryRendererLanguage,
            languageTranslationManifest: languageTranslationManifest,
            pageViewFactories: pageViewFactories,
            navigation: navigation,
            manifestResourcesCache: appDiContainer.getMobileContentRendererManifestResourcesCache()
        )
                           
        let viewModel = ToolTrainingViewModel(
            pageRenderer: pageRenderer,
            renderedPageContext: event.renderedPageContext,
            trainingTipId: event.trainingTipId,
            tipModel: event.tipModel,
            setCompletedTrainingTipUseCase: appDiContainer.domainLayer.getSetCompletedTrainingTipUseCase(),
            getTrainingTipCompletedUseCase: appDiContainer.domainLayer.getTrainingTipCompletedUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            localizationServices: appDiContainer.dataLayer.getLocalizationServices(),
            closeTappedClosure: { [weak self] in
                self?.dismissToolTraining()
        })
        
        let view = ToolTrainingView(viewModel: viewModel)
        
        parentFlow.navigationController.present(view, animated: true, completion: nil)
        
        self.toolTraining = view
    }
    
    private func dismissToolTraining() {
        
        guard toolTraining != nil else {
            return
        }
        
        parentFlow?.navigationController.dismiss(animated: true, completion: nil)
        toolTraining = nil
    }
}

extension MobileContentRendererNavigation: MobileContentRendererNavigationDelegate {
    
    func mobileContentRendererNavigationDismissRenderer(navigation: MobileContentRendererNavigation, event: DismissToolEvent) {
        dismissToolTraining()
    }
    
    func mobileContentRendererNavigationDeepLink(navigation: MobileContentRendererNavigation, deepLink: MobileContentRendererNavigationDeepLinkType) {
        
    }
}

