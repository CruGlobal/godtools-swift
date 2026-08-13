//
//  MobileContentRendererNavigation.swift
//  godtools
//
//  Created by Levi Eggert on 6/3/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import GodToolsShared

@MainActor
protocol MobileContentRendererNavigationDelegate: AnyObject {
    
    func mobileContentRendererNavigationDismissRenderer(navigation: MobileContentRendererNavigation, event: DismissToolEvent)
    func mobileContentRendererNavigationDeepLink(navigation: MobileContentRendererNavigation, deepLink: MobileContentRendererNavigationDeepLinkType)
}

@MainActor final class MobileContentRendererNavigation {
    
    private let appDiContainer: AppDiContainer
    private let appLanguage: AppLanguageDomainModel
    
    private var toolTraining: ToolTrainingView?
    
    private weak var toolFlow: GTFlow?
    private weak var delegate: MobileContentRendererNavigationDelegate?
    
    init(appDiContainer: AppDiContainer, appLanguage: AppLanguageDomainModel) {
        
        self.appDiContainer = appDiContainer
        self.appLanguage = appLanguage
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    func setToolFlow(toolFlow: GTFlow?) {
        self.toolFlow = toolFlow
    }
    
    func setDelegate(delegate: MobileContentRendererNavigationDelegate?) {
        self.delegate = delegate
    }
    
    func buttonWithUrlTapped(
        url: URL,
        analyticsScreenName: String,
        analyticsSiteSection: String,
        analyticsSiteSubSection: String,
        languages: MobileContentRendererLanguages
    ) {
        
        let deepLinkingService: DeepLinkingService = appDiContainer.core.dataLayer.getDeepLinkingService()
        let deepLink: ParsedDeepLinkType? = deepLinkingService.parseDeepLink(incomingDeepLink: .url(incomingUrl: IncomingDeepLinkUrl(url: url)))
        
        if let deepLink = deepLink {
            
            switch deepLink {
            
            case .lessonsList:
               
                delegate?.mobileContentRendererNavigationDeepLink(
                    navigation: self,
                    deepLink: .lessonsList
                )
                            
            case .tool(let toolDeepLink):
                
                toolFlow?.pushFlow(
                    flow: ToolNavigationFlow(
                        appDiContainer: appDiContainer,
                        appLanguage: appLanguage,
                        toolDeepLink: toolDeepLink
                    )
                )
                
            default:
                break
            }
        }
        else {
            
            let linkTapped = URLLinkTappedParams(
                url: url,
                screenName: analyticsScreenName,
                siteSection: analyticsSiteSection,
                siteSubSection: analyticsSiteSubSection,
                contentLanguage: languages.primaryLanguage.localeId,
                contentLanguageSecondary: languages.parallelLanguage?.localeId
            )
            
            toolFlow?.navigateToURL(
                linkTapped: linkTapped,
                appLanguage: appLanguage
            )
        }
    }
    
    func dismissTool(event: DismissToolEvent) {
        
        delegate?.mobileContentRendererNavigationDismissRenderer(navigation: self, event: event)
    }
    
    func presentError(error: Error, appLanguage: AppLanguageDomainModel) {
        
        toolFlow?.presentError(appLanguage: appLanguage, error: error)
    }
    
    func errorOccurred(error: MobileContentErrorViewModel) {
        
        let view = MobileContentErrorView(viewModel: error)
        
        toolFlow?.presentView(view: view.controller, animated: true)
    }
    
    func trainingTipTapped(event: TrainingTipEvent) {
                
        presentToolTraining(event: event)
    }
    
    func downloadToolLanguages(
        toolId: String,
        languageIds: [String],
        completion: @escaping ((_ state: DownloadToolFlow.CompletedState) -> Void)
    ) {
             
        guard let toolFlow = self.toolFlow else {
            
            let error: Error = NSError.errorWithDescription(description: "Failed to download tool languages.  Parent flow is null.")
            completion(.downloadFailed(error: error))
            
            return
        }
        
        let determineToolTranslationsToDownload = DetermineToolTranslationsToDownload(
            resourceId: toolId,
            languageIds: languageIds,
            resourcesRepository: appDiContainer.core.dataLayer.getResourcesRepository(),
            translationsRepository: appDiContainer.core.dataLayer.getTranslationsRepository()
        )
        
        let downloadToolUseCase = appDiContainer.core.domainLayer.getDownloadToolUseCase()
        
        Task {
            
            let toolTranslations = try await downloadToolUseCase
                .execute(
                    filter: .downloadManifestAndRelatedFilesForRenderer,
                    determineToolTranslationsToDownload: determineToolTranslationsToDownload,
                    downloadType: .cache
                )
            
            if let toolTranslations = toolTranslations {
                
                completion(.downloadSuccess(toolTranslations: toolTranslations))
            }
            else {
                
                let presentOnFlow: Flow = toolFlow.getTopMostPresentedFlow() ?? toolFlow
                
                presentOnFlow.presentFlow(
                    flow: DownloadToolFlow(
                        appDiContainer: appDiContainer,
                        appLanguage: appLanguage,
                        determineToolTranslationsToDownload: determineToolTranslationsToDownload,
                        flowCompleted: { (state: DownloadToolFlow.CompletedState) in
                            
                            completion(state)
                            
                            presentOnFlow.dismissFlow()
                        }
                    )
                )
            }
        }
    }
    
    private func presentToolTraining(event: TrainingTipEvent) {
        
        guard let toolFlow = self.toolFlow else {
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
            appDiContainer: appDiContainer,
            appLanguage: appLanguage
        )
        
        navigation.setDelegate(delegate: self)
        navigation.setToolFlow(toolFlow: toolFlow)
        
        let pageRenderer = MobileContentPageRenderer(
            sharedState: State(),
            resource: event.renderedPageContext.resource,
            appLanguage: appLanguage,
            rendererLanguages: event.renderedPageContext.rendererLanguages,
            languageTranslationManifest: languageTranslationManifest,
            pageViewFactories: pageViewFactories,
            navigation: navigation,
            resourcesFileCache: appDiContainer.core.dataLayer.getResourcesFileCache()
        )
                           
        let viewModel = ToolTrainingViewModel(
            pageRenderer: pageRenderer,
            renderedPageContext: event.renderedPageContext,
            trainingTipId: event.trainingTipId,
            tipModel: event.tipModel,
            setCompletedTrainingTipUseCase: appDiContainer.core.domainLayer.getSetCompletedTrainingTipUseCase(),
            getTrainingTipCompletedUseCase: appDiContainer.core.domainLayer.getTrainingTipCompletedUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            localizationServices: appDiContainer.core.dataLayer.getLocalizationServices(),
            closeTappedClosure: { [weak self] in
                self?.dismissToolTraining()
            }
        )
        
        let view = ToolTrainingView(viewModel: viewModel)
        
        toolFlow.presentView(view: view, animated: true)
        
        self.toolTraining = view
    }
    
    private func dismissToolTraining() {
        
        guard toolTraining != nil else {
            return
        }
        
        toolFlow?.dismissView(animated: true)
        
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
