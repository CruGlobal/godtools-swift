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
    private let appLanguage: AppLanguageDomainModel
    
    private var toolTraining: ToolTrainingView?
    private var downloadToolTranslationsFlow: DownloadToolTranslationsFlow?
    
    private weak var parentFlow: ToolNavigationFlow?
    private weak var delegate: MobileContentRendererNavigationDelegate?
    
    init(parentFlow: ToolNavigationFlow, delegate: MobileContentRendererNavigationDelegate, appDiContainer: AppDiContainer, appLanguage: AppLanguageDomainModel) {
        
        self.parentFlow = parentFlow
        self.delegate = delegate
        self.appDiContainer = appDiContainer
        self.appLanguage = appLanguage
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    func buttonWithUrlTapped(url: URL, screenName: String, siteSection: String, siteSubSection: String, contentLanguage: String?) {
        
        let deepLinkingService: DeepLinkingService = appDiContainer.dataLayer.getDeepLinkingService()
        let deepLink: ParsedDeepLinkType? = deepLinkingService.parseDeepLink(incomingDeepLink: .url(incomingUrl: IncomingDeepLinkUrl(url: url)))
        
        if let deepLink = deepLink {
            
            switch deepLink {
            
            case .lessonsList:
               
                delegate?.mobileContentRendererNavigationDeepLink(navigation: self, deepLink: .lessonsList)
                            
            case .tool(let toolDeepLink):
                
                parentFlow?.navigateToToolFromToolDeepLink(appLanguage: appLanguage, toolDeepLink: toolDeepLink, didCompleteToolNavigation: nil)
                
            default:
                break
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
    
    func downloadToolLanguages(toolId: String, languageIds: [String], completion: @escaping ((_ result: Result<ToolTranslationsDomainModel, Error>) -> Void)) {
             
        guard let flow = parentFlow else {
            completion(.failure(NSError.errorWithDescription(description: "Failed to download tool languages.  Parent flow is null.")))
            return
        }
        
        let determineToolTranslationsToDownload = DetermineToolTranslationsToDownload(
            resourceId: toolId,
            languageIds: languageIds,
            resourcesRepository: appDiContainer.dataLayer.getResourcesRepository(),
            translationsRepository: appDiContainer.dataLayer.getTranslationsRepository()
        )
        
        downloadToolTranslationsFlow = DownloadToolTranslationsFlow(
            presentInFlow: flow,
            appDiContainer: appDiContainer,
            determineToolTranslationsToDownload: determineToolTranslationsToDownload,
            didDownloadToolTranslations: { [weak self] (result: Result<ToolTranslationsDomainModel, Error>) in
                self?.downloadToolTranslationsFlow = nil
                completion(result)
            }
        )
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
            appDiContainer: appDiContainer,
            appLanguage: appLanguage
        )
        
        let pageRenderer = MobileContentPageRenderer(
            sharedState: State(),
            resource: event.renderedPageContext.resource,
            appLanguage: appLanguage,
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

