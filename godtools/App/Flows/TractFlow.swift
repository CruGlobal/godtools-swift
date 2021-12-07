//
//  TractFlow.swift
//  godtools
//
//  Created by Levi Eggert on 7/27/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class TractFlow: NSObject, ToolNavigationFlow, Flow {
    
    private let deepLinkingService: DeepLinkingServiceType
    
    private var shareToolMenuFlow: ShareToolMenuFlow?
 
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    var articleFlow: ArticleFlow?
    var lessonFlow: LessonFlow?
    var tractFlow: TractFlow?
    
    required init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: UINavigationController?, resource: ResourceModel, primaryLanguage: LanguageModel, primaryTranslationManifest: TranslationManifestData, parallelLanguage: LanguageModel?, parallelTranslationManifest: TranslationManifestData?, liveShareStream: String?, trainingTipsEnabled: Bool, page: Int?) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController ?? UINavigationController()
        self.deepLinkingService = appDiContainer.getDeepLinkingService()
        
        super.init()
            
        let translationsFileCache: TranslationsFileCache = appDiContainer.translationsFileCache
        
        let pageViewFactories: MobileContentRendererPageViewFactories = MobileContentRendererPageViewFactories(
            type: .tract,
            flowDelegate: self,
            appDiContainer: appDiContainer,
            trainingTipsEnabled: trainingTipsEnabled,
            deepLinkingService: deepLinkingService
        )
          
        let primaryRenderer = MobileContentMultiplatformRenderer(
            resource: resource,
            language: primaryLanguage,
            multiplatformParser: MobileContentMultiplatformParser(translationManifestData: primaryTranslationManifest, translationsFileCache: translationsFileCache),
            pageViewFactories: pageViewFactories
        )
        
        // TODO: Remove when removing xml node renderer. ~Levi
        /*
        let primaryRenderer = MobileContentXmlNodeRenderer(
            resource: resource,
            language: primaryLanguage,
            xmlParser: MobileContentXmlParser(translationManifestData: primaryTranslationManifest, translationsFileCache: translationsFileCache),
            pageViewFactories: pageViewFactories
        )*/
        
        var renderers: [MobileContentRendererType] = Array()
        
        renderers.append(primaryRenderer)
        
        if !trainingTipsEnabled, let parallelLanguage = parallelLanguage, let parallelTranslationManifest = parallelTranslationManifest, parallelLanguage.code != primaryLanguage.code {
            
            let parallelRenderer = MobileContentMultiplatformRenderer(
                resource: resource,
                language: parallelLanguage,
                multiplatformParser: MobileContentMultiplatformParser(translationManifestData: parallelTranslationManifest, translationsFileCache: translationsFileCache),
                pageViewFactories: pageViewFactories
            )
            
            // TODO: Remove when removing xml node renderer. ~Levi
            /*
            let parallelRenderer = MobileContentXmlNodeRenderer(
                resource: resource,
                language: parallelLanguage,
                xmlParser: MobileContentXmlParser(translationManifestData: parallelTranslationManifest, translationsFileCache: translationsFileCache),
                pageViewFactories: pageViewFactories
            )*/
            
            renderers.append(parallelRenderer)
        }
        
        let parentFlowIsHomeFlow: Bool = flowDelegate is ToolsFlow
        
        let viewModel = ToolViewModel(
            flowDelegate: self,
            backButtonImageType: (parentFlowIsHomeFlow) ? .home : .backArrow,
            renderers: renderers,
            resource: resource,
            primaryLanguage: primaryLanguage,
            tractRemoteSharePublisher: appDiContainer.tractRemoteSharePublisher,
            tractRemoteShareSubscriber: appDiContainer.tractRemoteShareSubscriber,
            localizationServices: appDiContainer.localizationServices,
            fontService: appDiContainer.getFontService(),
            viewsService: appDiContainer.viewsService,
            analytics: appDiContainer.analytics,
            mobileContentEventAnalytics: appDiContainer.getMobileContentEventAnalyticsTracking(),
            toolOpenedAnalytics: appDiContainer.toolOpenedAnalytics,
            liveShareStream: liveShareStream,
            trainingTipsEnabled: trainingTipsEnabled,
            page: page
        )
        
        let view = ToolView(viewModel: viewModel)
        
        if let sharedNavController = sharedNavigationController {
            sharedNavController.pushViewController(view, animated: true)
        }
        else {
            navigationController.setViewControllers([view], animated: false)
        }
        
        configureNavigationBar(shouldAnimateNavigationBarHiddenState: true)
        
        addDeepLinkingObserver()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        deepLinkingService.deepLinkObserver.removeObserver(self)
    }
    
    private var isShowingRootView: Bool {
        return navigationController.viewControllers.count == 1
    }
    
    private func configureNavigationBar(shouldAnimateNavigationBarHiddenState: Bool) {
        navigationController.setNavigationBarHidden(false, animated: shouldAnimateNavigationBarHiddenState)
    }
    
    private func addDeepLinkingObserver() {
        deepLinkingService.deepLinkObserver.addObserver(self) { [weak self] (parsedDeepLink: ParsedDeepLinkType?) in
            if let deepLink = parsedDeepLink {
                self?.navigate(step: .deepLink(deepLinkType: deepLink))
            }
        }
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
            
        case .deepLink(let deepLink):
            
            switch deepLink {
            
            case .allToolsList:
                break
            
            case .article(let articleURI):
                break
            
            case .favoritedToolsList:
                break
            
            case .lessonsList:
                break
            
            case .tool(let toolDeepLink):
                
                guard let toolDeepLinkResources = ToolDeepLinkResources(dataDownloader: appDiContainer.initialDataDownloader, languageSettingsService: appDiContainer.languageSettingsService, toolDeepLink: toolDeepLink) else {
                    return
                }
                
                navigateToTool(
                    resource: toolDeepLinkResources.resource,
                    primaryLanguage: toolDeepLinkResources.primaryLanguage,
                    parallelLanguage: toolDeepLinkResources.parallelLanguage,
                    liveShareStream: toolDeepLink.liveShareStream,
                    trainingTipsEnabled: false,
                    page: toolDeepLink.page
                )
            }
        
        case .homeTappedFromTool(let isScreenSharing):
            
            if isScreenSharing && isShowingRootView {
                
                let acceptHandler = CallbackHandler { [weak self] in
                    self?.closeTool()
                }
                
                let localizationServices: LocalizationServices = appDiContainer.localizationServices
                                
                let viewModel = AlertMessageViewModel(
                    title: nil,
                    message: localizationServices.stringForMainBundle(key: "exit_tract_remote_share_session.message"),
                    cancelTitle: localizationServices.stringForMainBundle(key: "no").uppercased(),
                    acceptTitle: localizationServices.stringForMainBundle(key: "yes").uppercased(),
                    acceptHandler: acceptHandler
                )
                
                let view = AlertMessageView(viewModel: viewModel)
                
                navigationController.present(view.controller, animated: true, completion: nil)
            }
            else {
                closeTool()
            }
            
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
        
        default:
            break
        }
    }
    
    private func closeTool() {
        
        if isShowingRootView {
            flowDelegate?.navigate(step: .tractFlowCompleted(state: .userClosedTract))
        }
        else {
            navigationController.popViewController(animated: true)
        }
    }
    
    private func navigateToToolTraining(event: TrainingTipEvent) {
        
        let pageModels: [PageModelType] = event.tipModel.pages
        
        if pageModels.isEmpty {
            assertionFailure("Pages should not be empty for training tip.")
        }
                        
        let pageViewFactories: MobileContentRendererPageViewFactories = MobileContentRendererPageViewFactories(
            type: .trainingTip,
            flowDelegate: self,
            appDiContainer: appDiContainer,
            trainingTipsEnabled: false,
            deepLinkingService: deepLinkingService
        )
        
        let renderer = MobileContentMultiplatformRenderer(
            resource: event.rendererPageModel.resource,
            language: event.rendererPageModel.language,
            multiplatformParser: MobileContentMultiplatformParser(manifest: event.rendererPageModel.manifest, pageModels: pageModels, translationsFileCache: appDiContainer.translationsFileCache),
            pageViewFactories: pageViewFactories
        )
           
        // TODO: Remove when removing xml node renderer. ~Levi
        /*
        let renderer = MobileContentXmlNodeRenderer(
            resource: event.rendererPageModel.resource,
            language: event.rendererPageModel.language,
            xmlParser: MobileContentXmlParser(manifest: event.rendererPageModel.manifest, pageModels: pageModels, translationsFileCache: appDiContainer.translationsFileCache),
            pageViewFactories: pageViewFactories
        )*/
                
        let viewModel = ToolTrainingViewModel(
            flowDelegate: self,
            renderer: renderer,
            trainingTipId: event.trainingTipId,
            tipModel: event.tipModel,
            analytics: appDiContainer.analytics,
            localizationServices: appDiContainer.localizationServices,
            viewedTrainingTips: appDiContainer.getViewedTrainingTipsService()
        )
        
        let view = ToolTrainingView(viewModel: viewModel)
        
        navigationController.present(view, animated: true, completion: nil)
    }
}
