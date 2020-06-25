//
//  ToolsFlow.swift
//  godtools
//
//  Created by Levi Eggert on 5/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolsFlow: Flow {
    
    private var articlesFlow: ArticlesFlow?
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    required init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: UINavigationController) {
        print("init: \(type(of: self))")
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
             
        let openTutorialViewModel = OpenTutorialViewModel(
            flowDelegate: self,
            tutorialAvailability: appDiContainer.tutorialAvailability,
            openTutorialCalloutCache: appDiContainer.openTutorialCalloutCache,
            analytics: appDiContainer.analytics
        )
        
        let favoritedToolsViewModel = FavoritedToolsViewModel(
            flowDelegate: self,
            dataDownloader: appDiContainer.initialDataDownloader,
            languageSettingsService: appDiContainer.languageSettingsService,
            translateLanguageNameViewModel: appDiContainer.translateLanguageNameViewModel,
            favoritedResourcesService: appDiContainer.favoritedResourcesService,
            analytics: appDiContainer.analytics
        )
        
        let allToolsViewModel = AllToolsViewModel(
            flowDelegate: self,
            dataDownloader: appDiContainer.initialDataDownloader,
            languageSettingsService: appDiContainer.languageSettingsService,
            translateLanguageNameViewModel: appDiContainer.translateLanguageNameViewModel,
            favoritedResourcesService: appDiContainer.favoritedResourcesService,
            analytics: appDiContainer.analytics
        )
        
        let toolsMenuViewModel = ToolsMenuViewModel(
            flowDelegate: self
        )
        let view = ToolsMenuView(
            viewModel: toolsMenuViewModel,
            openTutorialViewModel: openTutorialViewModel,
            favoritedToolsViewModel: favoritedToolsViewModel,
            allToolsViewModel: allToolsViewModel
        )
        
        navigationController.setViewControllers([view], animated: false)
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
           
        case .menuTappedFromTools:
            flowDelegate?.navigate(step: .showMenu)
        
        case .languageSettingsTappedFromTools:
            flowDelegate?.navigate(step: .showLanguageSettings)
            
        case .openTutorialTapped:
            flowDelegate?.navigate(step: .openTutorialTapped)
            
        case .toolTappedFromFavoritedTools(let resource):
            navigateToTool(resource: resource)
            
        case .aboutToolTappedFromFavoritedTools(let resource):
            navigateToToolDetail(resource: resource)
            
        case .unfavoriteToolTappedFromFavoritedTools(let resource, let removeHandler):
            
            let handler = CallbackHandler { [weak self] in
                removeHandler.handle()
                self?.navigationController.dismiss(animated: true, completion: nil)
            }
            
            // TODO: Localize this text. ~Levi
            let title: String = "Remove From Favorites?"
            let message: String = "Are you sure you want to remove \(resource.name) from your favorites?"
            let acceptedTitle: String = "YES"
            
            let viewModel = AlertMessageViewModel(
                title: title,
                message: message,
                cancelTitle: "NO",
                acceptTitle: acceptedTitle,
                acceptHandler: handler
            )
            
            let view = AlertMessageView(viewModel: viewModel)
            
            navigationController.present(view.controller, animated: true, completion: nil)
            
        case .toolTappedFromAllTools(let resource):
            navigateToTool(resource: resource)
            
        case .aboutToolTappedFromAllTools(let resource):
            navigateToToolDetail(resource: resource)
            
        case .homeTappedFromTract:
            flowDelegate?.navigate(step: .homeTappedFromTract)
            
        case .openToolTappedFromToolDetails(let resource):
            navigateToTool(resource: resource)
            
        case .urlLinkTappedFromToolDetail(let url):
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
            
        default:
            break
        }
    }
    
    private func loadToolTranslationManifest(resource: ResourceModel, completeOnMain: @escaping ((_ translationManifest: TranslationManifestData) -> Void)) {
        
        let appDiContainer: AppDiContainer = self.appDiContainer
        let preferredLanguageTranslationViewModel: PreferredLanguageTranslationViewModel = appDiContainer.preferredLanguageTranslationViewModel
        let translationsFileCache: TranslationsFileCache = appDiContainer.translationsFileCache

        preferredLanguageTranslationViewModel.getPreferredLanguageTranslation(resourceId: resource.id) { (preferredLanguageTranslationResult: PreferredLanguageTranslationResult) in
                            
            let translation: TranslationModel? = preferredLanguageTranslationResult.preferredLanguageTranslation
            
            translationsFileCache.getTranslationManifest(translationId: translation?.id ?? "") { (result: Result<TranslationManifestData, TranslationsFileCacheError>) in
                
                DispatchQueue.main.async { [weak self] in
                    
                    switch result {
                        
                    case .success(let translationManifest):
                        completeOnMain(translationManifest)
                        
                    case .failure(let fileCacheError):
                        
                        let closeHandler: CallbackHandler = CallbackHandler {
                            self?.navigationController.dismiss(animated: true, completion: nil)
                        }
                        
                        let completeHandler: CallbackValueHandler<Result<TranslationManifestData, TranslationDownloaderError>> = CallbackValueHandler { (result: Result<TranslationManifestData, TranslationDownloaderError>) in
                            
                            switch result {
                            case .success(let translationManifest):
                                self?.navigationController.dismiss(animated: true, completion: nil)
                                completeOnMain(translationManifest)
                            case .failure(let downloadError):
                                self?.navigationController.dismiss(animated: true, completion: { [weak self] in
                                    if !downloadError.cancelled {
                                        let downloadTranslationAlert = TranslationDownloaderErrorViewModel(translationDownloaderError: downloadError)
                                        self?.navigationController.presentAlertMessage(alertMessage: downloadTranslationAlert)
                                    }
                                })
                            }
                        }
                        
                        // present loading tool view
                        let viewModel = LoadingToolViewModel(
                            resource: resource,
                            preferredTranslation: preferredLanguageTranslationResult,
                            translationDownloader: appDiContainer.translationDownloader,
                            completeHandler: completeHandler,
                            closeHandler: closeHandler
                        )
                        
                        let view = LoadingToolView(viewModel: viewModel)
                        
                        let modal = ModalNavigationController(rootView: view)
                        
                        self?.navigationController.present(modal, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    private func navigateToTool(resource: ResourceModel) {
        
        let appDiContainer: AppDiContainer = self.appDiContainer
        let navigationController: UINavigationController = self.navigationController
        let flowDelegate: FlowDelegate = self
        let resourceType: ResourceType = ResourceType.resourceType(resource: resource)
        
        loadToolTranslationManifest(resource: resource, completeOnMain: { [weak self] (translationManifest: TranslationManifestData) in
            
            switch resourceType {
                
            case .article:
                
                let articlesFlow = ArticlesFlow(
                    flowDelegate: flowDelegate,
                    appDiContainer: appDiContainer,
                    sharedNavigationController: navigationController,
                    resource: resource,
                    translationManifest: translationManifest
                )
                
                self?.articlesFlow = articlesFlow
                
            case .tract:
    
                let languageSettingsService: LanguageSettingsService = appDiContainer.languageSettingsService
                                
                guard let primaryLanguage = languageSettingsService.primaryLanguage.value else {
                    navigationController.presentAlertMessage(
                        alertMessage: AlertMessage(
                            title: "Internal Error",
                            message: "Primary language not set.  Choose a primary language for viewing this tool."
                    ))
                    return
                }
                
                let viewModel = TractViewModel(
                    flowDelegate: flowDelegate,
                    resource: resource,
                    primaryLanguage: primaryLanguage,
                    primaryTranslationManifest: translationManifest,
                    parallelLanguage: languageSettingsService.parallelLanguage.value,
                    languageSettingsService: languageSettingsService,
                    translateLanguageNameViewModel: appDiContainer.translateLanguageNameViewModel,
                    tractManager: appDiContainer.tractManager,
                    viewsService: appDiContainer.viewsService,
                    analytics: appDiContainer.analytics,
                    toolOpenedAnalytics: appDiContainer.toolOpenedAnalytics,
                    tractPage: 0
                )
                let view = TractView(viewModel: viewModel)

                navigationController.pushViewController(view, animated: true)
                
            case .unknown:
                
                let viewModel = AlertMessageViewModel(
                    title: "Internal Error",
                    message: "Unknown tool type for resource.",
                    cancelTitle: nil,
                    acceptTitle: "OK",
                    acceptHandler: nil
                )
                let view = AlertMessageView(viewModel: viewModel)
                navigationController.present(view.controller, animated: true, completion: nil)
            }
        })
    }
    
    private func navigateToToolDetail(resource: ResourceModel) {
        
        let viewModel = ToolDetailViewModel(
            flowDelegate: self,
            resource: resource,
            dataDownloader: appDiContainer.initialDataDownloader,
            favoritedResourcesService: appDiContainer.favoritedResourcesService,
            languageSettingsService: appDiContainer.languageSettingsService,
            localization: appDiContainer.localizationServices,
            preferredLanguageTranslationViewModel: appDiContainer.preferredLanguageTranslationViewModel,
            translateLanguageNameViewModel: appDiContainer.translateLanguageNameViewModel,
            analytics: appDiContainer.analytics,
            exitLinkAnalytics: appDiContainer.exitLinkAnalytics
        )
        let view = ToolDetailView(viewModel: viewModel)
        
        navigationController.pushViewController(view, animated: true)
    }
}
