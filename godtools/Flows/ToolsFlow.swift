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
    private var shareToolMenuFlow: ShareToolMenuFlow?
    private var learnToShareToolFlow: LearnToShareToolFlow?
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    required init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: UINavigationController) {
        print("init: \(type(of: self))")
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
                     
        let openTutorialViewModel = OpenTutorialViewModel(
            flowDelegate: self,
            tutorialAvailability: appDiContainer.tutorialAvailability,
            openTutorialCalloutCache: appDiContainer.openTutorialCalloutCache,
            localizationServices: appDiContainer.localizationServices,
            analytics: appDiContainer.analytics
        )
        
        let favoritingToolMessageViewModel = FavoritingToolMessageViewModel(
            favoritingToolMessageCache: appDiContainer.favoritingToolMessageCache,
            localizationServices: appDiContainer.localizationServices
        )
        
        let favoritedToolsViewModel = FavoritedToolsViewModel(
            flowDelegate: self,
            dataDownloader: appDiContainer.initialDataDownloader,
            languageSettingsService: appDiContainer.languageSettingsService,
            localizationServices: appDiContainer.localizationServices,
            favoritedResourcesCache: appDiContainer.favoritedResourcesCache,
            deviceAttachmentBanners: appDiContainer.deviceAttachmentBanners,
            analytics: appDiContainer.analytics
        )
        
        let allToolsViewModel = AllToolsViewModel(
            flowDelegate: self,
            dataDownloader: appDiContainer.initialDataDownloader,
            languageSettingsService: appDiContainer.languageSettingsService,
            localizationServices: appDiContainer.localizationServices,
            favoritedResourcesCache: appDiContainer.favoritedResourcesCache,
            deviceAttachmentBanners: appDiContainer.deviceAttachmentBanners,
            analytics: appDiContainer.analytics
        )
        
        let toolsMenuViewModel = ToolsMenuViewModel(
            flowDelegate: self,
            localizationServices: appDiContainer.localizationServices
        )
        let view = ToolsMenuView(
            viewModel: toolsMenuViewModel,
            openTutorialViewModel: openTutorialViewModel,
            favoritedToolsViewModel: favoritedToolsViewModel,
            allToolsViewModel: allToolsViewModel,
            favoritingToolMessageViewModel: favoritingToolMessageViewModel
        )
        
        navigationController.setViewControllers([view], animated: false)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    func resetToolsMenu() {
        if let toolsMenu = navigationController.viewControllers.first as? ToolsMenuView {
            toolsMenu.resetMenu()
        }
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
            
            let localizationServices: LocalizationServices = appDiContainer.localizationServices
            
            let title: String = localizationServices.stringForMainBundle(key: "remove_from_favorites_title")
            let message: String = localizationServices.stringForMainBundle(key: "remove_from_favorites_message").replacingOccurrences(of: "%@", with: resource.name)
            let acceptedTitle: String = localizationServices.stringForMainBundle(key: "yes")
            
            let viewModel = AlertMessageViewModel(
                title: title,
                message: message,
                cancelTitle: localizationServices.stringForMainBundle(key: "no"),
                acceptTitle: acceptedTitle,
                acceptHandler: handler
            )
            
            let view = AlertMessageView(viewModel: viewModel)
            
            navigationController.present(view.controller, animated: true, completion: nil)
            
        case .toolTappedFromAllTools(let resource):
            navigateToTool(resource: resource)
            
        case .aboutToolTappedFromAllTools(let resource):
            navigateToToolDetail(resource: resource)
            
        case .homeTappedFromTract(let isScreenSharing):
            flowDelegate?.navigate(step: .homeTappedFromTract(isScreenSharing: isScreenSharing))
            
        case .shareMenuTappedFromTract(let tractRemoteShareSubscriber, let tractRemoteSharePublisher, let resource, let selectedLanguage, let primaryLanguage, let parallelLanguage, let pageNumber):
            
            let shareToolMenuFlow = ShareToolMenuFlow(
                flowDelegate: self,
                appDiContainer: appDiContainer,
                navigationController: navigationController,
                tractRemoteSharePublisher: tractRemoteSharePublisher,
                resource: resource,
                selectedLanguage: selectedLanguage,
                primaryLanguage: primaryLanguage,
                parallelLanguage: parallelLanguage,
                pageNumber: pageNumber,
                hidesRemoteShareToolAction: tractRemoteShareSubscriber.isSubscribedToChannel
            )
            
            self.shareToolMenuFlow = shareToolMenuFlow
            
        case .closeTappedFromShareToolScreenTutorial:
            self.shareToolMenuFlow = nil
                        
        case .openToolTappedFromToolDetails(let resource):
            navigateToTool(resource: resource)
            
        case .learnToShareToolTappedFromToolDetails(let resource):
            
            let toolTrainingTipsOnboardingViews: ToolTrainingTipsOnboardingViewsService = appDiContainer.getToolTrainingTipsOnboardingViews()
                        
            let toolTrainingTipReachedMaximumViews: Bool = toolTrainingTipsOnboardingViews.getToolTrainingTipReachedMaximumViews(resource: resource)
            
            if !toolTrainingTipReachedMaximumViews {
                
                toolTrainingTipsOnboardingViews.storeToolTrainingTipViewed(resource: resource)
                
                let learnToShareToolFlow = LearnToShareToolFlow(
                    flowDelegate: self,
                    appDiContainer: appDiContainer
                )
                
                navigationController.present(learnToShareToolFlow.navigationController, animated: true, completion: nil)
                
                self.learnToShareToolFlow = learnToShareToolFlow
            }
            else {
                
                navigateToTool(resource: resource)
            }
            
        case .closeTappedFromLearnToShareTool:
            dismissLearnToShareToolFlow()
            
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
    
    private func dismissLearnToShareToolFlow() {
        
        if learnToShareToolFlow != nil {
            navigationController.dismiss(animated: true, completion: nil)
        }
        
        self.learnToShareToolFlow = nil
    }
    
    private func navigateToToolDetail(resource: ResourceModel) {
        
        let viewModel = ToolDetailViewModel(
            flowDelegate: self,
            resource: resource,
            dataDownloader: appDiContainer.initialDataDownloader,
            favoritedResourcesCache: appDiContainer.favoritedResourcesCache,
            languageSettingsService: appDiContainer.languageSettingsService,
            localizationServices: appDiContainer.localizationServices,
            translationDownloader: appDiContainer.translationDownloader,
            analytics: appDiContainer.analytics,
            exitLinkAnalytics: appDiContainer.exitLinkAnalytics
        )
        let view = ToolDetailView(viewModel: viewModel)
        
        navigationController.pushViewController(view, animated: true)
    }
    
    private func navigateToLoadingToolView(resource: ResourceModel, translationsToDownload: [TranslationModel], completeHandler: CallbackValueHandler<[DownloadedTranslationResult]>) {
        
        let closeHandler: CallbackHandler = CallbackHandler { [weak self] in
            self?.leaveLoadingToolView(animated: true, completion: nil)
        }
        
        let viewModel = LoadingToolViewModel(
            resource: resource,
            translationsToDownload: translationsToDownload,
            translationDownloader: appDiContainer.translationDownloader,
            favoritedResourcesCache: appDiContainer.favoritedResourcesCache,
            localizationServices: appDiContainer.localizationServices,
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
        
        let localizationServices: LocalizationServices = appDiContainer.localizationServices
        
        leaveLoadingToolView(animated: true, completion: { [weak self] in
            if !downloadError.cancelled {
                let downloadTranslationAlert = TranslationDownloaderErrorViewModel(
                    localizationServices: localizationServices,
                    translationDownloaderError: downloadError
                )
                self?.navigationController.presentAlertMessage(alertMessage: downloadTranslationAlert)
            }
        })
    }
    
    func navigateToTool(resource: ResourceModel, primaryLanguage: LanguageModel, parallelLanguage: LanguageModel?, liveShareStream: String?, page: Int?) {
        
        let dataDownloader: InitialDataDownloader = appDiContainer.initialDataDownloader
        let translationsFileCache: TranslationsFileCache = appDiContainer.translationsFileCache
        
        let primaryTranslation: TranslationModel? = dataDownloader.resourcesCache.getResourceLanguageTranslation(resourceId: resource.id, languageId: primaryLanguage.id)
        let parallelTranslation: TranslationModel?
        
        if let parallelLanguage = parallelLanguage {
            parallelTranslation = dataDownloader.resourcesCache.getResourceLanguageTranslation(resourceId: resource.id, languageId: parallelLanguage.id)
        }
        else {
            parallelTranslation = nil
        }
        
        let primaryTranslationManifest: TranslationManifestData?
        let parallelTranslationManifest: TranslationManifestData?
        
        if let primaryTranslation = primaryTranslation {
            
            let primaryManifestResult: Result<TranslationManifestData, TranslationsFileCacheError> = translationsFileCache.getTranslationManifestOnMainThread(translationId: primaryTranslation.id)
            
            switch primaryManifestResult {
            
            case .success(let translationManifest):
                primaryTranslationManifest = translationManifest
            case .failure(let error):
                primaryTranslationManifest = nil
            }
        }
        else {
            primaryTranslationManifest = nil
        }
        
        if let parallelTranslation = parallelTranslation {
            
            let parallelManifestResult: Result<TranslationManifestData, TranslationsFileCacheError> = translationsFileCache.getTranslationManifestOnMainThread(translationId: parallelTranslation.id)
            
            switch parallelManifestResult {
            
            case .success(let translationManifest):
                parallelTranslationManifest = translationManifest
            case .failure(let error):
                parallelTranslationManifest = nil
            }
        }
        else {
            parallelTranslationManifest = nil
        }
        
        if let primaryTranslation = primaryTranslation {
            
            navigateToToolFromFetchedCachedResources(
                resource: resource,
                primaryLanguage: primaryLanguage,
                primaryTranslation: primaryTranslation,
                primaryTranslationManifest: primaryTranslationManifest,
                parallelLanguage: parallelLanguage,
                parallelTranslation: parallelTranslation,
                parallelTranslationManifest: parallelTranslationManifest,
                liveShareStream: liveShareStream,
                page: page
            )
        }
    }
    
    private func navigateToTool(resource: ResourceModel) {
        
        let fetchTranslationManifestsViewModel: FetchTranslationManifestsViewModel = appDiContainer.fetchTranslationManifestsViewModel
        
        let result: FetchTranslationManifestResult = fetchTranslationManifestsViewModel.getTranslationManifests(resourceId: resource.id)
        
        switch result {
        
        case .failedToGetInitialResourcesFromCache:
            break
        
        case .fetchedTranslationsFromCache(let primaryLanguage, let primaryTranslation, let primaryTranslationManifest, let parallelLanguage, let parallelTranslation, let parallelTranslationManifest):
            
            navigateToToolFromFetchedCachedResources(
                resource: resource,
                primaryLanguage: primaryLanguage,
                primaryTranslation: primaryTranslation,
                primaryTranslationManifest: primaryTranslationManifest,
                parallelLanguage: parallelLanguage,
                parallelTranslation: parallelTranslation,
                parallelTranslationManifest: parallelTranslationManifest,
                liveShareStream: nil,
                page: 0
            )
        }
    }
    
    private func navigateToToolFromFetchedCachedResources(resource: ResourceModel, primaryLanguage: LanguageModel, primaryTranslation: TranslationModel, primaryTranslationManifest: TranslationManifestData?, parallelLanguage: LanguageModel?, parallelTranslation: TranslationModel?, parallelTranslationManifest: TranslationManifestData?, liveShareStream: String?, page: Int?) {
        
        let translationsFileCache: TranslationsFileCache = appDiContainer.translationsFileCache
        
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
                    
                    if let downloadError = downloadedTranslation.downloadError {
                        self?.handleDownloadTranslationErrorFromLoadingToolView(downloadError: downloadError)
                        return
                    }
                    else {
                        
                        let result: Result<TranslationManifestData, TranslationsFileCacheError> = translationsFileCache.getTranslationManifestOnMainThread(translationId: downloadedTranslation.translationId)
                        
                        switch result {
                        case .success(let translationManifestData):
                            if downloadedTranslation.translationId == primaryTranslation.id {
                                downloadedPrimaryTranslation = translationManifestData
                            }
                            else if (downloadedTranslation.translationId == parallelTranslation?.id) {
                                downloadedParallelTranslation = translationManifestData
                            }
                        case .failure(let translationDownloaderError):
                            break
                        }
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
                    parallelTranslationManifest: parallelTranslationManifest ?? downloadedParallelTranslation,
                    liveShareStream: liveShareStream,
                    page: page
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
                parallelTranslationManifest: parallelTranslationManifest,
                liveShareStream: liveShareStream,
                page: page
            )
        }
    }
    
    private func navigateToTool(resource: ResourceModel, primaryLanguage: LanguageModel, primaryTranslationManifest: TranslationManifestData, parallelLanguage: LanguageModel?, parallelTranslationManifest: TranslationManifestData?, liveShareStream: String?, page: Int?) {
        
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
                parallelTranslationManifest: parallelTranslationManifest,
                liveShareStream: liveShareStream,
                page: page
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
    
    private func navigateToTract(resource: ResourceModel, primaryLanguage: LanguageModel, primaryTranslationManifest: TranslationManifestData, parallelLanguage: LanguageModel?, parallelTranslationManifest: TranslationManifestData?, liveShareStream: String?, page: Int?) {
        
        /*
        let viewModel = TractViewModel(
            flowDelegate: self,
            resource: resource,
            primaryLanguage: primaryLanguage,
            primaryTranslationManifest: primaryTranslationManifest,
            parallelLanguage: parallelLanguage,
            parallelTranslationManifest: parallelTranslationManifest,
            languageSettingsService: appDiContainer.languageSettingsService,
            tractManager: appDiContainer.tractManager,
            tractRemoteSharePublisher: appDiContainer.tractRemoteSharePublisher,
            tractRemoteShareSubscriber: appDiContainer.tractRemoteShareSubscriber,
            isNewUserService: appDiContainer.isNewUserService,
            cardJumpService: appDiContainer.cardJumpService,
            followUpsService: appDiContainer.followUpsService,
            viewsService: appDiContainer.viewsService,
            localizationServices: appDiContainer.localizationServices,
            analytics: appDiContainer.analytics,
            toolOpenedAnalytics: appDiContainer.toolOpenedAnalytics,
            liveShareStream: liveShareStream,
            tractPage: page
        )
        let view = TractView(viewModel: viewModel)*/
        
        let viewModel = ToolViewModel(
            flowDelegate: self,
            resource: resource,
            primaryLanguage: primaryLanguage,
            parallelLanguage: parallelLanguage,
            primaryTranslationManifestData: primaryTranslationManifest,
            parallelTranslationManifest: parallelTranslationManifest,
            mobileContentNodeParser: appDiContainer.getMobileContentNodeParser(),
            translationsFileCache: appDiContainer.translationsFileCache,
            languageSettingsService: appDiContainer.languageSettingsService,
            fontService: appDiContainer.getFontService(),
            tractManager: appDiContainer.tractManager,
            tractRemoteSharePublisher: appDiContainer.tractRemoteSharePublisher,
            tractRemoteShareSubscriber: appDiContainer.tractRemoteShareSubscriber,
            isNewUserService: appDiContainer.isNewUserService,
            cardJumpService: appDiContainer.cardJumpService,
            followUpsService: appDiContainer.followUpsService,
            viewsService: appDiContainer.viewsService,
            localizationServices: appDiContainer.localizationServices,
            analytics: appDiContainer.analytics,
            toolOpenedAnalytics: appDiContainer.toolOpenedAnalytics,
            liveShareStream: liveShareStream,
            toolPage: page
        )
        
        let view = ToolView(viewModel: viewModel)

        navigationController.pushViewController(view, animated: true)
    }
}
