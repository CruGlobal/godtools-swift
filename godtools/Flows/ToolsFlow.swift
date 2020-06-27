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
            favoritedResourcesCache: appDiContainer.favoritedResourcesCache,
            fetchLanguageTranslationViewModel: appDiContainer.fetchLanguageTranslationViewModel,
            analytics: appDiContainer.analytics
        )
        
        let allToolsViewModel = AllToolsViewModel(
            flowDelegate: self,
            dataDownloader: appDiContainer.initialDataDownloader,
            resourcesTranslationsDownloader: appDiContainer.resourcesTranslationsDownloader,
            languageSettingsService: appDiContainer.languageSettingsService,
            favoritedResourcesCache: appDiContainer.favoritedResourcesCache,
            fetchLanguageTranslationViewModel: appDiContainer.fetchLanguageTranslationViewModel,
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
            
        case .shareTappedFromTract(let resource, let language, let pageNumber):
            
            let viewModel = ShareToolViewModel(
                resource: resource,
                language: language,
                pageNumber: pageNumber,
                analytics: appDiContainer.analytics
            )
            
            let view = ShareToolView(viewModel: viewModel)
            
            navigationController.present(
                view.controller,
                animated: true,
                completion: nil
            )
            
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
    
    private func navigateToLoadingToolView(resource: ResourceModel, translationsToDownload: [TranslationModel], completeHandler: CallbackValueHandler<[DownloadedTranslationResult]>) {
        
        let closeHandler: CallbackHandler = CallbackHandler { [weak self] in
            self?.leaveLoadingToolView(animated: true, completion: nil)
        }
        
        let viewModel = LoadingToolViewModel(
            resource: resource,
            translationsToDownload: translationsToDownload,
            translationDownloader: appDiContainer.translationDownloader,
            completeHandler: completeHandler,
            closeHandler: closeHandler
        )
        
        let view = LoadingToolView(viewModel: viewModel)
        
        let modal = ModalNavigationController(rootView: view)
        
        navigationController.present(modal, animated: true, completion: nil)
    }
    
    private func leaveLoadingToolView(animated: Bool, completion: (() -> Void)?) {
        navigationController.dismiss(
            animated: animated,
            completion: completion
        )
    }
    
    private func handleDownloadTranslationErrorFromLoadingToolView(downloadError: TranslationDownloaderError) {
        leaveLoadingToolView(animated: true, completion: { [weak self] in
            if !downloadError.cancelled {
                let downloadTranslationAlert = TranslationDownloaderErrorViewModel(translationDownloaderError: downloadError)
                self?.navigationController.presentAlertMessage(alertMessage: downloadTranslationAlert)
            }
        })
    }
    
    private func navigateToTool(resource: ResourceModel) {
        
        let fetchTranslationManifestsViewModel: FetchTranslationManifestsViewModel = appDiContainer.fetchTranslationManifestsViewModel
        
        let result: FetchTranslationManifestResult = fetchTranslationManifestsViewModel.getTranslationManifests(resourceId: resource.id)
        
        switch result {
        
        case .failedToGetInitialResourcesFromCache:
            break
        
        case .fetchedTranslationsFromCache(let primaryLanguage, let primaryTranslation, let primaryTranslationManifest, let parallelLanguage, let parallelTranslation, let parallelTranslationManifest):
            
            var translationsToDownload: [TranslationModel] = Array()
            
            let shouldDownloadPrimaryTranslation: Bool = primaryTranslationManifest == nil
            let shouldDownloadParallelTranslation: Bool = parallelTranslationManifest == nil && parallelTranslation != nil
            
            if shouldDownloadPrimaryTranslation {
                translationsToDownload.append(primaryTranslation)
            }
            
            if shouldDownloadParallelTranslation, let parallelTranslation = parallelTranslation {
                translationsToDownload.append(parallelTranslation)
            }
            
            if !translationsToDownload.isEmpty {
                
                var downloadedPrimaryTranslation: TranslationManifestData?
                var downloadedParallelTranslation: TranslationManifestData?
                
                let completeHandler: CallbackValueHandler<[DownloadedTranslationResult]> = CallbackValueHandler { [weak self] (downloadedTranslationsResults: [DownloadedTranslationResult]) in
                                                   
                    for downloadedTranslation in downloadedTranslationsResults {
                        
                        switch downloadedTranslation.result {
                            
                        case .success(let translationManifestData):
                            if downloadedTranslation.translationId == primaryTranslation.id {
                                downloadedPrimaryTranslation = translationManifestData
                            }
                            else if (downloadedTranslation.translationId == parallelTranslation?.id) {
                                downloadedParallelTranslation = translationManifestData
                            }
                        case .failure(let translationDownloaderError):
                            self?.handleDownloadTranslationErrorFromLoadingToolView(downloadError: translationDownloaderError)
                            return
                        }
                    }
                    
                    guard let resourceTranslationPrimaryManifest = primaryTranslationManifest ?? downloadedPrimaryTranslation else {
                        self?.navigationController.presentAlertMessage(alertMessage: AlertMessage(title: "Internal Error", message: "Missing primary translation."))
                        return
                    }
                    
                    self?.leaveLoadingToolView(
                        animated: true,
                        completion: nil
                    )
                    
                    self?.navigateToTool(
                        resource: resource,
                        primaryLanguage: primaryLanguage,
                        primaryTranslationManifest: resourceTranslationPrimaryManifest,
                        parallelLanguage: parallelLanguage,
                        parallelTranslationManifest: parallelTranslationManifest ?? downloadedParallelTranslation
                    )
                    
                }// loading tool completed
                
                navigateToLoadingToolView(
                    resource: resource,
                    translationsToDownload: translationsToDownload,
                    completeHandler: completeHandler
                )
            }
            else if let primaryTranslationManifest = primaryTranslationManifest {
                
                navigateToTool(
                    resource: resource,
                    primaryLanguage: primaryLanguage,
                    primaryTranslationManifest: primaryTranslationManifest,
                    parallelLanguage: parallelLanguage,
                    parallelTranslationManifest: parallelTranslationManifest
                )
            }
        }
    }
    
    private func navigateToTool(resource: ResourceModel, primaryLanguage: LanguageModel, primaryTranslationManifest: TranslationManifestData, parallelLanguage: LanguageModel?, parallelTranslationManifest: TranslationManifestData?) {
        
        let resourceType: ResourceType = ResourceType.resourceType(resource: resource)
        
        switch resourceType {
            
        case .article:
            navigateToArticlesFlow(
                resource: resource,
                translationManifest: primaryTranslationManifest
            )
            
        case .tract:
            navigateToTract(
                resource: resource,
                primaryLanguage: primaryLanguage,
                primaryTranslationManifest: primaryTranslationManifest,
                parallelLanguage: parallelLanguage,
                parallelTranslationManifest: parallelTranslationManifest
            )
            
        case .unknown:
            navigationController.presentAlertMessage(alertMessage: AlertMessage(title: "Internal Error", message: "Attempted to navigate to a tool with an unknown resource type."))
        }
    }
    
    private func navigateToArticlesFlow(resource: ResourceModel, translationManifest: TranslationManifestData) {
        
        let articlesFlow = ArticlesFlow(
            flowDelegate: self,
            appDiContainer: appDiContainer,
            sharedNavigationController: navigationController,
            resource: resource,
            translationManifest: translationManifest
        )
        
        self.articlesFlow = articlesFlow
    }
    
    private func navigateToTract(resource: ResourceModel, primaryLanguage: LanguageModel, primaryTranslationManifest: TranslationManifestData, parallelLanguage: LanguageModel?, parallelTranslationManifest: TranslationManifestData?) {
        
        let viewModel = TractViewModel(
            flowDelegate: self,
            resource: resource,
            primaryLanguage: primaryLanguage,
            primaryTranslationManifest: primaryTranslationManifest,
            parallelLanguage: parallelLanguage,
            parallelTranslationManifest: parallelTranslationManifest,
            languageSettingsService: appDiContainer.languageSettingsService,
            tractManager: appDiContainer.tractManager,
            viewsService: appDiContainer.viewsService,
            analytics: appDiContainer.analytics,
            toolOpenedAnalytics: appDiContainer.toolOpenedAnalytics,
            tractPage: 0
        )
        let view = TractView(viewModel: viewModel)

        navigationController.pushViewController(view, animated: true)
    }
    
    private func navigateToToolDetail(resource: ResourceModel) {
        
        let viewModel = ToolDetailViewModel(
            flowDelegate: self,
            resource: resource,
            dataDownloader: appDiContainer.initialDataDownloader,
            favoritedResourcesCache: appDiContainer.favoritedResourcesCache,
            languageSettingsService: appDiContainer.languageSettingsService,
            localization: appDiContainer.localizationServices,
            fetchLanguageTranslationViewModel: appDiContainer.fetchLanguageTranslationViewModel,
            analytics: appDiContainer.analytics,
            exitLinkAnalytics: appDiContainer.exitLinkAnalytics
        )
        let view = ToolDetailView(viewModel: viewModel)
        
        navigationController.pushViewController(view, animated: true)
    }
}
