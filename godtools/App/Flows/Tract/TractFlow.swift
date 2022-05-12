//
//  TractFlow.swift
//  godtools
//
//  Created by Levi Eggert on 7/27/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class TractFlow: NSObject, ToolNavigationFlow, Flow {
    
    private let deepLinkingService: DeepLinkingServiceType
    
    private var shareToolMenuFlow: ShareToolMenuFlow?
    private var toolSettingsFlow: ToolSettingsFlow?
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    var articleFlow: ArticleFlow?
    var chooseYourOwnAdventureFlow: ChooseYourOwnAdventureFlow?
    var lessonFlow: LessonFlow?
    var tractFlow: TractFlow?
    
    required init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: UINavigationController?, resource: ResourceModel, primaryLanguage: LanguageModel, primaryLanguageManifest: Manifest, parallelLanguage: LanguageModel?, parallelLanguageManifest: Manifest?, liveShareStream: String?, trainingTipsEnabled: Bool, page: Int?) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController ?? UINavigationController()
        self.deepLinkingService = appDiContainer.getDeepLinkingService()
        
        super.init()
            
        let translationsFileCache: TranslationsFileCache = appDiContainer.translationsFileCache
        
        var languageTranslationManifests: [MobileContentRendererLanguageTranslationManifest] = Array()
        
        let primaryLanguageTranslationManifest = MobileContentRendererLanguageTranslationManifest(
            manifest: primaryLanguageManifest,
            language: primaryLanguage
        )
        
        languageTranslationManifests.append(primaryLanguageTranslationManifest)
        
        if !trainingTipsEnabled, let parallelLanguage = parallelLanguage, let parallelLanguageManifest = parallelLanguageManifest, parallelLanguage.code != primaryLanguage.code {
            
            languageTranslationManifests.append(MobileContentRendererLanguageTranslationManifest(manifest: parallelLanguageManifest, language: parallelLanguage))
        }

        let pageViewFactories: MobileContentRendererPageViewFactories = MobileContentRendererPageViewFactories(
            type: .tract,
            flowDelegate: self,
            appDiContainer: appDiContainer,
            trainingTipsEnabled: trainingTipsEnabled,
            deepLinkingService: deepLinkingService
        )
                
        let renderer = MobileContentRenderer(
            resource: resource,
            primaryLanguage: primaryLanguage,
            languageTranslationManifests: languageTranslationManifests,
            pageViewFactories: pageViewFactories,
            translationsFileCache: translationsFileCache
        )
        
        let parentFlowIsHomeFlow: Bool = flowDelegate is AppFlow
        
        let viewModel = ToolViewModel(
            flowDelegate: self,
            backButtonImageType: (parentFlowIsHomeFlow) ? .home : .backArrow,
            renderer: renderer,
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
                flowDelegate?.navigate(step: .tractFlowCompleted(state: .userClosedTractToLessonsList))
            
            case .tool(let toolDeepLink):
                
                navigateToToolFromToolDeepLink(toolDeepLink: toolDeepLink, didCompleteToolNavigation: nil)
            }
        
        case .homeTappedFromTool(let isScreenSharing):
            
            if isScreenSharing {
                
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
            
        case .toolSettingsTappedFromTool(let tractRemoteShareSubscriber, let tractRemoteSharePublisher, let resource, let selectedLanguage, let primaryLanguage, let parallelLanguage, let pageNumber):
            
            let toolSettingsFlow = ToolSettingsFlow(appDiContainer: appDiContainer)
            
            navigationController.present(toolSettingsFlow.getInitialView(), animated: true)
            
            self.toolSettingsFlow = toolSettingsFlow
            
            // TODO: Implement navigation in GT-1558 and remove ShareToolMenuFlow if not being used anywhere else. ~Levi
            //assertionFailure("TODO: Navigate to ToolSettings")
            
            /*
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
            
            self.shareToolMenuFlow = shareToolMenuFlow*/

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
            
        case .tractFlowCompleted(let state):
            
            guard tractFlow != nil else {
                return
            }
            
            _ = navigationController.popViewController(animated: true)
            configureNavigationBar(shouldAnimateNavigationBarHiddenState: true)
            
            tractFlow = nil
            
        case .lessonFlowCompleted(let state):
            
            guard lessonFlow != nil else {
                return
            }
            
            _ = navigationController.popViewController(animated: true)
            configureNavigationBar(shouldAnimateNavigationBarHiddenState: true)
            
            lessonFlow = nil
            
        case .didTriggerDismissToolEventFromMobileContentRenderer:
            closeTool()
            
        default:
            break
        }
    }
    
    private func closeTool() {
        
        flowDelegate?.navigate(step: .tractFlowCompleted(state: .userClosedTract))
    }
    
    private func navigateToToolTraining(event: TrainingTipEvent) {
                        
        let pageViewFactories: MobileContentRendererPageViewFactories = MobileContentRendererPageViewFactories(
            type: .trainingTip,
            flowDelegate: self,
            appDiContainer: appDiContainer,
            trainingTipsEnabled: false,
            deepLinkingService: deepLinkingService
        )
        
        let languageTranslationManifest = MobileContentRendererLanguageTranslationManifest(manifest: event.renderedPageContext.manifest, language: event.renderedPageContext.language)
        
        let pageRenderer = MobileContentPageRenderer(
            sharedState: State(),
            resource: event.renderedPageContext.resource,
            primaryLanguage: event.renderedPageContext.primaryRendererLanguage,
            languageTranslationManifest: languageTranslationManifest,
            pageViewFactories: pageViewFactories,
            translationsFileCache: appDiContainer.translationsFileCache
        )
                           
        let viewModel = ToolTrainingViewModel(
            flowDelegate: self,
            pageRenderer: pageRenderer,
            renderedPageContext: event.renderedPageContext,
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
