//
//  TractFlow.swift
//  godtools
//
//  Created by Levi Eggert on 7/27/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class TractFlow: Flow {
    
    private let deepLinkingService: DeepLinkingServiceType
    
    private var shareToolMenuFlow: ShareToolMenuFlow?
 
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    required init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: UINavigationController?, resource: ResourceModel, primaryLanguage: LanguageModel, primaryTranslationManifest: TranslationManifestData, parallelLanguage: LanguageModel?, parallelTranslationManifest: TranslationManifestData?, liveShareStream: String?, trainingTipsEnabled: Bool, page: Int?) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController ?? UINavigationController()
        self.deepLinkingService = appDiContainer.getDeepLinkingService()
        
        let translationsFileCache: TranslationsFileCache = appDiContainer.translationsFileCache
        
        let pageViewFactories: MobileContentRendererPageViewFactories = MobileContentRendererPageViewFactories(
            type: .tract,
            flowDelegate: self,
            appDiContainer: appDiContainer,
            trainingTipsEnabled: trainingTipsEnabled,
            deepLinkingService: deepLinkingService
        )
          
        /*
        let primaryRenderer = MobileContentMultiplatformRenderer(
            resource: resource,
            language: primaryLanguage,
            multiplatformParser: MobileContentMultiplatformParser(translationManifestData: primaryTranslationManifest, translationsFileCache: translationsFileCache),
            pageViewFactories: pageViewFactories
        )*/
        
        let primaryRenderer = MobileContentXmlNodeRenderer(
            resource: resource,
            language: primaryLanguage,
            xmlParser: MobileContentXmlParser(translationManifestData: primaryTranslationManifest, translationsFileCache: translationsFileCache),
            pageViewFactories: pageViewFactories
        )
        
        var renderers: [MobileContentRendererType] = Array()
        
        renderers.append(primaryRenderer)
        
        if !trainingTipsEnabled, let parallelLanguage = parallelLanguage, let parallelTranslationManifest = parallelTranslationManifest, parallelLanguage.code != primaryLanguage.code {
            
            /*
            let parallelRenderer = MobileContentMultiplatformRenderer(
                resource: resource,
                language: parallelLanguage,
                multiplatformParser: MobileContentMultiplatformParser(translationManifestData: parallelTranslationManifest, translationsFileCache: translationsFileCache),
                pageViewFactories: pageViewFactories
            )*/
            
            let parallelRenderer = MobileContentXmlNodeRenderer(
                resource: resource,
                language: parallelLanguage,
                xmlParser: MobileContentXmlParser(translationManifestData: parallelTranslationManifest, translationsFileCache: translationsFileCache),
                pageViewFactories: pageViewFactories
            )
            
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
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func configureNavigationBar(shouldAnimateNavigationBarHiddenState: Bool) {
        navigationController.setNavigationBarHidden(false, animated: shouldAnimateNavigationBarHiddenState)
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
        
        case .homeTappedFromTool(let isScreenSharing):
            
            if isScreenSharing {
                
                let acceptHandler = CallbackHandler { [weak self] in
                    self?.flowDelegate?.navigate(step: .tractFlowCompleted(state: .userClosedTract))
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
                flowDelegate?.navigate(step: .tractFlowCompleted(state: .userClosedTract))
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
        
        /*
        let renderer = MobileContentMultiplatformRenderer(
            resource: event.rendererPageModel.resource,
            language: event.rendererPageModel.language,
            multiplatformParser: MobileContentMultiplatformParser(manifest: event.rendererPageModel.manifest, pageModels: pageModels, translationsFileCache: appDiContainer.translationsFileCache),
            pageViewFactories: pageViewFactories
        )*/
           
        let renderer = MobileContentXmlNodeRenderer(
            resource: event.rendererPageModel.resource,
            language: event.rendererPageModel.language,
            xmlParser: MobileContentXmlParser(manifest: event.rendererPageModel.manifest, pageModels: pageModels, translationsFileCache: appDiContainer.translationsFileCache),
            pageViewFactories: pageViewFactories
        )
                
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
