//
//  ToolsFlow.swift
//  godtools
//
//  Created by Levi Eggert on 5/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolsFlow: Flow {
    
    private static let defaultStartingToolsMenu: ToolsMenuToolbarView.ToolbarItemView = .favoritedTools
    
    private var articleToolFlow: ArticleToolFlow?
    private var shareToolMenuFlow: ShareToolMenuFlow?
    private var learnToShareToolFlow: LearnToShareToolFlow?
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    required init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: UINavigationController, startingToolbarItem: ToolsMenuToolbarView.ToolbarItemView?) {
        print("init: \(type(of: self))")
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        
        let viewModel = ToolsMenuViewModel(
            flowDelegate: self,
            initialDataDownloader: appDiContainer.initialDataDownloader,
            languageSettingsService: appDiContainer.languageSettingsService,
            localizationServices: appDiContainer.localizationServices,
            favoritedResourcesCache: appDiContainer.favoritedResourcesCache,
            deviceAttachmentBanners: appDiContainer.deviceAttachmentBanners,
            favoritingToolMessageCache: appDiContainer.favoritingToolMessageCache,
            analytics: appDiContainer.analytics,
            tutorialAvailability: appDiContainer.tutorialAvailability,
            openTutorialCalloutCache: appDiContainer.openTutorialCalloutCache
        )
        
        let view = ToolsMenuView(
            viewModel: viewModel,
            startingToolbarItem: startingToolbarItem ?? ToolsFlow.defaultStartingToolsMenu
        )
        
        navigationController.setViewControllers([view], animated: false)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
           
        case .menuTappedFromTools:
            flowDelegate?.navigate(step: .showMenu)
        
        case .languageSettingsTappedFromTools:
            flowDelegate?.navigate(step: .showLanguageSettings)
            
        case .lessonTappedFromLessonsList(let resource):
            navigateToTool(resource: resource, trainingTipsEnabled: false)
            
        case .closeTappedFromLesson:
            flowDelegate?.navigate(step: .closeTappedFromLesson)
            
        case .openTutorialTapped:
            flowDelegate?.navigate(step: .openTutorialTapped)
            
        case .toolTappedFromFavoritedTools(let resource):
            navigateToTool(resource: resource, trainingTipsEnabled: false)
            
        case .aboutToolTappedFromFavoritedTools(let resource):
            navigateToToolDetail(resource: resource)
            
        case .unfavoriteToolTappedFromFavoritedTools(let resource, let removeHandler):
            
            let handler = CallbackHandler { [weak self] in
                removeHandler.handle()
                self?.navigationController.dismiss(animated: true, completion: nil)
            }
            
            let localizationServices: LocalizationServices = appDiContainer.localizationServices
            let languageSettingsService: LanguageSettingsService = appDiContainer.languageSettingsService
            let resourcesCache: ResourcesCache = appDiContainer.initialDataDownloader.resourcesCache
            
            let toolName: String
            
            if let primaryLanguage = languageSettingsService.primaryLanguage.value, let primaryTranslation = resourcesCache.getResourceLanguageTranslation(resourceId: resource.id, languageId: primaryLanguage.id) {
                toolName = primaryTranslation.translatedName
            }
            else if let englishTranslation = resourcesCache.getResourceLanguageTranslation(resourceId: resource.id, languageCode: "en") {
                toolName = englishTranslation.translatedName
            }
            else {
                toolName = resource.name
            }
            
            let title: String = localizationServices.stringForMainBundle(key: "remove_from_favorites_title")
            let message: String = localizationServices.stringForMainBundle(key: "remove_from_favorites_message").replacingOccurrences(of: "%@", with: toolName)
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
            navigateToTool(resource: resource, trainingTipsEnabled: false)
            
        case .aboutToolTappedFromAllTools(let resource):
            navigateToToolDetail(resource: resource)
            
        case .homeTappedFromTool(let isScreenSharing):
            flowDelegate?.navigate(step: .homeTappedFromTool(isScreenSharing: isScreenSharing))
            
        case .shareMenuTappedFromTool(let tractRemoteShareSubscriber, let tractRemoteSharePublisher, let resource, let selectedLanguage, let primaryLanguage, let parallelLanguage, let pageNumber):
            
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

        case .buttonWithUrlTappedFromMobileContentRenderer(let url, let exitLink):
            guard let webUrl = URL(string: url) else {
                return
            }
            navigateToURL(url: webUrl, exitLink: exitLink)
            
        case .trainingTipTappedFromMobileContentRenderer(let event):
            navigateToToolTraining(event: event)
            
        case .errorOccurredFromMobileContentRenderer(let error):
            
            let view = MobileContentErrorView(viewModel: error)
            
            navigationController.present(view.controller, animated: true, completion: nil)
            
        case .closeTappedFromToolTraining:
            navigationController.dismiss(animated: true, completion: nil)
                        
        case .closeTappedFromShareToolScreenTutorial:
            self.shareToolMenuFlow = nil
                        
        case .openToolTappedFromToolDetails(let resource):
            navigateToTool(resource: resource, trainingTipsEnabled: false)
            
        case .learnToShareToolTappedFromToolDetails(let resource):
            
            let toolTrainingTipsOnboardingViews: ToolTrainingTipsOnboardingViewsService = appDiContainer.getToolTrainingTipsOnboardingViews()
                        
            let toolTrainingTipReachedMaximumViews: Bool = toolTrainingTipsOnboardingViews.getToolTrainingTipReachedMaximumViews(resource: resource)
            
            if !toolTrainingTipReachedMaximumViews {
                
                toolTrainingTipsOnboardingViews.storeToolTrainingTipViewed(resource: resource)
                
                let learnToShareToolFlow = LearnToShareToolFlow(
                    flowDelegate: self,
                    appDiContainer: appDiContainer,
                    resource: resource
                )
                
                navigationController.present(learnToShareToolFlow.navigationController, animated: true, completion: nil)
                
                self.learnToShareToolFlow = learnToShareToolFlow
            }
            else {
                
                navigateToTool(resource: resource, trainingTipsEnabled: true)
            }
            
        case .continueTappedFromLearnToShareTool(let resource):
            navigateToTool(resource: resource, trainingTipsEnabled: true)
            dismissLearnToShareToolFlow()
            
        case .closeTappedFromLearnToShareTool(let resource):
            navigateToTool(resource: resource, trainingTipsEnabled: true)
            dismissLearnToShareToolFlow()
            
        case .urlLinkTappedFromToolDetail(let url, let exitLink):
            navigateToURL(url: url, exitLink: exitLink)
            
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
    
    private func navigateToURL(url: URL, exitLink: ExitLinkModel) {
        
        appDiContainer.exitLinkAnalytics.trackExitLink(exitLink: exitLink)
        
        UIApplication.shared.open(url)
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
            analytics: appDiContainer.analytics
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
    
    func navigateToTool(resource: ResourceModel, primaryLanguage: LanguageModel, parallelLanguage: LanguageModel?, liveShareStream: String?, trainingTipsEnabled: Bool, page: Int?) {
        
        let dataDownloader: InitialDataDownloader = appDiContainer.initialDataDownloader
        let translationsFileCache: TranslationsFileCache = appDiContainer.translationsFileCache
        
        let primaryTranslation: TranslationModel? = dataDownloader.resourcesCache.getResourceLanguageTranslation(resourceId: resource.id, languageId: primaryLanguage.id) ?? dataDownloader.resourcesCache.getResourceLanguageTranslation(resourceId: resource.id, languageCode: "en")
        
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
                trainingTipsEnabled: trainingTipsEnabled,
                page: page
            )
        }
        else {
            
            navigationController.presentAlertMessage(alertMessage: AlertMessage(title: "Internal Error", message: "Failed to fetch primary translation for primary language \(primaryLanguage.name)"))
        }
    }
    
    private func navigateToTool(resource: ResourceModel, trainingTipsEnabled: Bool) {
        
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
                trainingTipsEnabled: trainingTipsEnabled,
                page: 0
            )
        }
    }
    
    private func navigateToToolFromFetchedCachedResources(resource: ResourceModel, primaryLanguage: LanguageModel, primaryTranslation: TranslationModel, primaryTranslationManifest: TranslationManifestData?, parallelLanguage: LanguageModel?, parallelTranslation: TranslationModel?, parallelTranslationManifest: TranslationManifestData?, liveShareStream: String?, trainingTipsEnabled: Bool, page: Int?) {
        
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
                    trainingTipsEnabled: trainingTipsEnabled,
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
                trainingTipsEnabled: trainingTipsEnabled,
                page: page
            )
        }
    }
    
    private func navigateToTool(resource: ResourceModel, primaryLanguage: LanguageModel, primaryTranslationManifest: TranslationManifestData, parallelLanguage: LanguageModel?, parallelTranslationManifest: TranslationManifestData?, liveShareStream: String?, trainingTipsEnabled: Bool, page: Int?) {
        
        let resourceType: ResourceType = resource.resourceTypeEnum
        
        switch resourceType {
            
        case .article:
            navigateToArticleToolFlow(
                resource: resource,
                translationManifest: primaryTranslationManifest
            )
            
        case .lesson:
            navigateToLesson(
                resource: resource,
                primaryLanguage: primaryLanguage,
                primaryTranslationManifest: primaryTranslationManifest,
                trainingTipsEnabled: trainingTipsEnabled,
                page: page
            )
            
        case .tract:
            navigateToTract(
                resource: resource,
                primaryLanguage: primaryLanguage,
                primaryTranslationManifest: primaryTranslationManifest,
                parallelLanguage: parallelLanguage,
                parallelTranslationManifest: parallelTranslationManifest,
                liveShareStream: liveShareStream,
                trainingTipsEnabled: trainingTipsEnabled,
                page: page
            )
            
        case .unknown:
            navigationController.presentAlertMessage(alertMessage: AlertMessage(title: "Internal Error", message: "Attempted to navigate to a tool with an unknown resource type."))
        }
    }
    
    private func navigateToArticleToolFlow(resource: ResourceModel, translationManifest: TranslationManifestData) {
        
        let articleToolFlow = ArticleToolFlow(
            flowDelegate: self,
            appDiContainer: appDiContainer,
            sharedNavigationController: navigationController,
            resource: resource,
            translationManifest: translationManifest
        )
        
        self.articleToolFlow = articleToolFlow
    }
    
    private func navigateToTract(resource: ResourceModel, primaryLanguage: LanguageModel, primaryTranslationManifest: TranslationManifestData, parallelLanguage: LanguageModel?, parallelTranslationManifest: TranslationManifestData?, liveShareStream: String?, trainingTipsEnabled: Bool, page: Int?) {
        
        let renderers: [MobileContentRendererType]
        
        let primaryRenderer = appDiContainer.getMobileContentRenderer(
            flowDelegate: self,
            resource: resource,
            language: primaryLanguage,
            translationManifestData: primaryTranslationManifest,
            viewRendererFactoryType: .tract,
            trainingTipsEnabled: trainingTipsEnabled
        )
        
        if !trainingTipsEnabled, let parallelLanguage = parallelLanguage, let parallelTranslationManifest = parallelTranslationManifest, parallelLanguage.code != primaryLanguage.code {
            
            let parallelRenderer = appDiContainer.getMobileContentRenderer(
                flowDelegate: self,
                resource: resource,
                language: parallelLanguage,
                translationManifestData: parallelTranslationManifest,
                viewRendererFactoryType: .tract,
                trainingTipsEnabled: trainingTipsEnabled
            )
            
            renderers = [primaryRenderer, parallelRenderer]
        }
        else {
            
            renderers = [primaryRenderer]
        }
        
        let viewModel = ToolViewModel(
            flowDelegate: self,
            renderers: renderers,
            resource: resource,
            primaryLanguage: primaryLanguage,
            tractRemoteSharePublisher: appDiContainer.tractRemoteSharePublisher,
            tractRemoteShareSubscriber: appDiContainer.tractRemoteShareSubscriber,
            localizationServices: appDiContainer.localizationServices,
            fontService: appDiContainer.getFontService(),
            viewsService: appDiContainer.viewsService,
            analytics: appDiContainer.analytics,
            toolOpenedAnalytics: appDiContainer.toolOpenedAnalytics,
            liveShareStream: liveShareStream,
            trainingTipsEnabled: trainingTipsEnabled,
            page: page
        )
        
        let view = ToolView(viewModel: viewModel)
        
        navigationController.pushViewController(view, animated: true)
    }
    
    private func navigateToToolTraining(event: TrainingTipEvent) {
        
        let pageNodes: [PageNode] = event.tipNode.pages?.pages ?? []
        
        if pageNodes.isEmpty {
            // TODO: Page nodes should not be empty. ~Levi
        }
                        
        let pageViewFactories: MobileContentRendererPageViewFactories = MobileContentRendererPageViewFactories(
            type: .trainingTip,
            flowDelegate: self,
            appDiContainer: appDiContainer,
            trainingTipsEnabled: false
        )
                
        let renderer = MobileContentXmlNodeRenderer(
            resource: event.rendererPageModel.resource,
            language: event.rendererPageModel.language,
            xmlParser: MobileContentXmlParser(manifest: event.rendererPageModel.manifest, pageModels: pageNodes),
            pageViewFactories: pageViewFactories,
            translationsFileCache: appDiContainer.translationsFileCache
        )
                
        let viewModel = ToolTrainingViewModel(
            flowDelegate: self,
            renderer: renderer,
            trainingTipId: event.trainingTipId,
            tipNode: event.tipNode,
            analytics: appDiContainer.analytics,
            localizationServices: appDiContainer.localizationServices,
            viewedTrainingTips: appDiContainer.getViewedTrainingTipsService()
        )
        
        let view = ToolTrainingView(viewModel: viewModel)
        
        navigationController.present(view, animated: true, completion: nil)
    }
    
    private func navigateToLesson(resource: ResourceModel, primaryLanguage: LanguageModel, primaryTranslationManifest: TranslationManifestData, trainingTipsEnabled: Bool, page: Int?) {
        
        let renderer = appDiContainer.getMobileContentRenderer(
            flowDelegate: self,
            resource: resource,
            language: primaryLanguage,
            translationManifestData: primaryTranslationManifest,
            viewRendererFactoryType: .lesson,
            trainingTipsEnabled: trainingTipsEnabled
        )
        
        let viewModel = LessonViewModel(
            flowDelegate: self,
            renderers: [renderer],
            resource: resource,
            primaryLanguage: primaryLanguage,
            page: page
        )
        
        let view = LessonView(viewModel: viewModel)
        
        navigationController.pushViewController(view, animated: true)
    }
}
