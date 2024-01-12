//
//  TractFlow.swift
//  godtools
//
//  Created by Levi Eggert on 7/27/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser
import Combine

class TractFlow: ToolNavigationFlow, Flow {
        
    private var toolSettingsFlow: ToolSettingsFlow?
    private var cancellables: Set<AnyCancellable> = Set()
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    
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
        
        appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase()
            .getLanguagePublisher()
            .assign(to: &$appLanguage)
        
        let toolView = getToolView(
            toolTranslations: toolTranslations,
            liveShareStream: liveShareStream,
            trainingTipsEnabled: trainingTipsEnabled,
            initialPage: initialPage
        )
                        
        if let sharedNavController = sharedNavigationController {
            sharedNavController.pushViewController(toolView, animated: true)
        }
        else {
            navigationController.setViewControllers([toolView], animated: false)
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
                    message: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "exit_tract_remote_share_session.message"),
                    cancelTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "no").uppercased(),
                    acceptTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "yes").uppercased(),
                    acceptHandler: acceptHandler
                )
                
                let view = AlertMessageView(viewModel: viewModel)
                
                navigationController.present(view.controller, animated: true, completion: nil)
            }
            else {
                closeTool()
            }
            
        case .backTappedFromTool:
            closeTool()
            
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

extension TractFlow {
    
    private func getToolView(toolTranslations: ToolTranslationsDomainModel, liveShareStream: String?, trainingTipsEnabled: Bool, initialPage: MobileContentPagesPage?) -> UIViewController {
        
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
            renderer: renderer,
            tractRemoteSharePublisher: appDiContainer.feature.toolScreenShare.dataLayer.getTractRemoteSharePublisher(),
            tractRemoteShareSubscriber: appDiContainer.feature.toolScreenShare.dataLayer.getTractRemoteShareSubscriber(),
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
        
        let backBarItem: NavBarItem
        
        if parentFlowIsHomeFlow {
            backBarItem = AppHomeBarItem(color: nil, target: viewModel, action: #selector(viewModel.homeTapped), accessibilityIdentifier: nil)
        }
        else {
            backBarItem = AppBackBarItem(target: viewModel, action: #selector(viewModel.backTapped), accessibilityIdentifier: nil)
        }
        
        let remoteShareActiveBarItem = AppLottieBarItem(
            animationName: "remote_share_active",
            color: nil,
            target: nil,
            action: nil,
            accessibilityIdentifier: nil,
            hidesBarItemPublisher: viewModel.$hidesRemoteShareIsActive.eraseToAnyPublisher()
        )
        
        let toolSettingsBarItem = NavBarItem(
            controllerType: .base,
            itemData: NavBarItemData(
                contentType: .image(value: ImageCatalog.navToolSettings.uiImage),
                style: .plain,
                color: nil,
                target: viewModel,
                action: #selector(viewModel.toolSettingsTapped),
                accessibilityIdentifier: nil
            ),
            hidesBarItemPublisher: nil
        )
        
        var toolView: ToolView?
              
        let navigationBar = AppNavigationBar(
            appearance: viewModel.navBarAppearance,
            backButton: nil,
            leadingItems: [backBarItem],
            trailingItems: [remoteShareActiveBarItem, toolSettingsBarItem],
            titleView: nil,
            title: nil
        )
        
        let view = ToolView(viewModel: viewModel, navigationBar: navigationBar)
        
        toolView = view
        
        viewModel.$languageNames.eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (languageNames: [String]) in
                
                let languageSelectorView: NavBarSelectorView?
                
                if languageNames.count > 1 {
                    languageSelectorView = self?.getNewLanguageSelectorView(view: toolView, viewModel: viewModel)
                }
                else {
                    languageSelectorView = nil
                }
                
                navigationBar.setTitleView(
                    titleView: languageSelectorView
                )
                
                self?.navigationController.setLayoutDirectionPublisher(
                    layoutDirectionPublisher: Just(viewModel.layoutDirection).eraseToAnyPublisher()
                )
            }
            .store(in: &cancellables)
        
        viewModel.$selectedLanguageIndex.eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink { (index: Int) in
                
                (navigationBar.getTitleView() as? NavBarSelectorView)?.setSelectedIndex(index: index)
            }
            .store(in: &cancellables)
        
        return view
    }
    
    private func getNewLanguageSelectorView(view: ToolView?, viewModel: ToolViewModel) -> NavBarSelectorView {
        
        let barColor: UIColor = viewModel.navBarAppearance.backgroundColor
        let controlColor: UIColor = viewModel.navBarAppearance.controlColor ?? .white
        
        return NavBarSelectorView(
            selectorButtonTitles: viewModel.languageNames,
            layoutDirection: viewModel.layoutDirection,
            borderColor: controlColor,
            selectedColor: controlColor,
            deselectedColor: UIColor.clear,
            selectedTitleColor: barColor.withAlphaComponent(1),
            deselectedTitleColor: controlColor,
            titleFont: viewModel.languageFont,
            selectorTappedClosure: { (index: Int) in
                view?.languageTapped(index: index)
            }
        )
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
