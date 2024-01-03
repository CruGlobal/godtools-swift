//
//  TractFlow.swift
//  godtools
//
//  Created by Levi Eggert on 7/27/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class TractFlow: ToolNavigationFlow, Flow {
        
    private var toolSettingsFlow: ToolSettingsFlow?
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: AppNavigationController
    
    var articleFlow: ArticleFlow?
    var chooseYourOwnAdventureFlow: ChooseYourOwnAdventureFlow?
    var lessonFlow: LessonFlow?
    var tractFlow: TractFlow?
    var downloadToolTranslationFlow: DownloadToolTranslationsFlow?
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: AppNavigationController?, toolTranslations: ToolTranslationsDomainModel, liveShareStream: String?, trainingTipsEnabled: Bool, initialPage: MobileContentPagesPage?) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController ?? AppNavigationController(navigationBarAppearance: nil)
          
        let navigation: MobileContentRendererNavigation = appDiContainer.getMobileContentRendererNavigation(
            parentFlow: self,
            navigationDelegate: self
        )
        
        let renderer: MobileContentRenderer = appDiContainer.getMobileContentRenderer(
            type: .tract,
            navigation: navigation,
            toolTranslations: toolTranslations
        )
                
        let parentFlowIsHomeFlow: Bool = flowDelegate is AppFlow
        
        let viewModel = ToolViewModel(
            flowDelegate: self,
            backButtonImageType: (parentFlowIsHomeFlow) ? .home : .backArrow,
            renderer: renderer,
            tractRemoteSharePublisher: appDiContainer.feature.toolScreenShare.dataLayer.getTractRemoteSharePublisher(),
            tractRemoteShareSubscriber: appDiContainer.feature.toolScreenShare.dataLayer.getTractRemoteShareSubscriber(),
            localizationServices: appDiContainer.dataLayer.getLocalizationServices(),
            fontService: appDiContainer.getFontService(),
            resourceViewsService: appDiContainer.dataLayer.getResourceViewsService(),
            trackActionAnalyticsUseCase: appDiContainer.domainLayer.getTrackActionAnalyticsUseCase(),
            resourcesRepository: appDiContainer.dataLayer.getResourcesRepository(),
            translationsRepository: appDiContainer.dataLayer.getTranslationsRepository(),
            mobileContentEventAnalytics: appDiContainer.getMobileContentRendererEventAnalyticsTracking(),
            toolOpenedAnalytics: appDiContainer.getToolOpenedAnalytics(),
            liveShareStream: liveShareStream,
            initialPage: initialPage,
            trainingTipsEnabled: trainingTipsEnabled,
            incrementUserCounterUseCase: appDiContainer.domainLayer.getIncrementUserCounterUseCase()
        )
        
        // TODO: Will need to make sure to configure the navigation bar here instead of in the ViewController. ~Levi See GT-2239.
        let view = ToolView(viewModel: viewModel, navigationBar: nil)
                        
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
    
    private func getFirstToolViewInFlow() -> ToolView? {
        
        for index in 0 ..< navigationController.viewControllers.count {
            let view: UIViewController = navigationController.viewControllers[index]
            guard let toolView = view as? ToolView else {
                continue
            }
            return toolView
        }
        return nil
    }
    
    private func configureNavigationBar(shouldAnimateNavigationBarHiddenState: Bool) {
        navigationController.setNavigationBarHidden(false, animated: shouldAnimateNavigationBarHiddenState)
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
                    
        case .homeTappedFromTool(let isScreenSharing):
            
            if isScreenSharing {
                
                let acceptHandler = CallbackHandler { [weak self] in
                    self?.closeTool()
                }
                
                let localizationServices: LocalizationServices = appDiContainer.dataLayer.getLocalizationServices()
                                
                let viewModel = AlertMessageViewModel(
                    title: nil,
                    message: localizationServices.stringForSystemElseEnglish(key: "exit_tract_remote_share_session.message"),
                    cancelTitle: localizationServices.stringForSystemElseEnglish(key: "no").uppercased(),
                    acceptTitle: localizationServices.stringForSystemElseEnglish(key: "yes").uppercased(),
                    acceptHandler: acceptHandler
                )
                
                let view = AlertMessageView(viewModel: viewModel)
                
                navigationController.present(view.controller, animated: true, completion: nil)
            }
            else {
                closeTool()
            }
            
        case .toolSettingsTappedFromTool(let toolData):
                    
            guard let tool = getFirstToolViewInFlow() else {
                assertionFailure("Failed to fetch ToolSettingsToolType for ToolSettingsFlow in the view hierarchy.  A view with protocol ToolSettingsToolType should exist.")
                return
            }
            
            let toolSettingsFlow = ToolSettingsFlow(
                flowDelegate: self,
                appDiContainer: appDiContainer,
                sharedNavigationController: navigationController,
                toolData: toolData,
                tool: tool
            )
            
            navigationController.present(toolSettingsFlow.getInitialView(), animated: true)
            
            self.toolSettingsFlow = toolSettingsFlow
            
        case .toolSettingsFlowCompleted(let state):
            
            guard toolSettingsFlow != nil else {
                return
            }
        
            navigationController.dismiss(animated: true)
            
            toolSettingsFlow = nil
                        
        case .tractFlowCompleted( _):
            
            guard tractFlow != nil else {
                return
            }
            
            _ = navigationController.popViewController(animated: true)
            configureNavigationBar(shouldAnimateNavigationBarHiddenState: true)
            
            tractFlow = nil
            
        case .lessonFlowCompleted( _):
            
            guard lessonFlow != nil else {
                return
            }
            
            _ = navigationController.popViewController(animated: true)
            configureNavigationBar(shouldAnimateNavigationBarHiddenState: true)
            
            lessonFlow = nil
            
        default:
            break
        }
    }
    
    private func closeTool() {
        
        flowDelegate?.navigate(step: .tractFlowCompleted(state: .userClosedTract))
    }
}

extension TractFlow: MobileContentRendererNavigationDelegate {
    
    func mobileContentRendererNavigationDismissRenderer(navigation: MobileContentRendererNavigation, event: DismissToolEvent) {
        closeTool()
    }
    
    func mobileContentRendererNavigationDeepLink(navigation: MobileContentRendererNavigation, deepLink: MobileContentRendererNavigationDeepLinkType) {
        
        switch deepLink {
        
        case .lessonsList:
            flowDelegate?.navigate(step: .tractFlowCompleted(state: .userClosedTractToLessonsList))
        }
    }
}
