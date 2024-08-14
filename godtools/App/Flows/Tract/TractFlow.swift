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
import LocalizationServices

class TractFlow: ToolNavigationFlow, ToolSettingsNavigationFlow {
        
    private let appLanguage: AppLanguageDomainModel
    
    private var cancellables: Set<AnyCancellable> = Set()
    internal var toolSettingsFlow: ToolSettingsFlow?
        
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: AppNavigationController
    
    var articleFlow: ArticleFlow?
    var chooseYourOwnAdventureFlow: ChooseYourOwnAdventureFlow?
    var lessonFlow: LessonFlow?
    var tractFlow: TractFlow?
    var downloadToolTranslationFlow: DownloadToolTranslationsFlow?
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: AppNavigationController?, appLanguage: AppLanguageDomainModel, toolTranslations: ToolTranslationsDomainModel, liveShareStream: String?, selectedLanguageIndex: Int?, trainingTipsEnabled: Bool, initialPage: MobileContentPagesPage?, shouldPersistToolSettings: Bool) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController ?? AppNavigationController(navigationBarAppearance: nil)
        self.appLanguage = appLanguage
        
        let toolView = getToolView(
            toolTranslations: toolTranslations,
            liveShareStream: liveShareStream,
            selectedLanguageIndex: selectedLanguageIndex,
            trainingTipsEnabled: trainingTipsEnabled,
            initialPage: initialPage, 
            shouldPersistToolSettings: shouldPersistToolSettings
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
            
        case .toolSettingsTappedFromTool(let toolSettingsObserver):
                    
            openToolSettings(with: toolSettingsObserver)
            
        case .toolSettingsFlowCompleted(let state):
            
            closeToolSettings()
                        
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
    
    private func getToolView(toolTranslations: ToolTranslationsDomainModel, liveShareStream: String?, selectedLanguageIndex: Int?, trainingTipsEnabled: Bool, initialPage: MobileContentPagesPage?, shouldPersistToolSettings: Bool) -> UIViewController {
        
        let navigation: MobileContentRendererNavigation = appDiContainer.getMobileContentRendererNavigation(
            parentFlow: self,
            navigationDelegate: self,
            appLanguage: appLanguage
        )
        
        let renderer: MobileContentRenderer = appDiContainer.getMobileContentRenderer(
            type: .tract,
            navigation: navigation,
            appLanguage: appLanguage,
            toolTranslations: toolTranslations
        )
        
        let navBarLayoutDirection: UISemanticContentAttribute = ApplicationLayout.shared.currentDirection.semanticContentAttribute
        
        let parentFlowIsHomeFlow: Bool = flowDelegate is AppFlow
        
        let viewModel = TractViewModel(
            flowDelegate: self,
            renderer: renderer,
            tractRemoteSharePublisher: appDiContainer.feature.toolScreenShare.dataLayer.getTractRemoteSharePublisher(),
            tractRemoteShareSubscriber: appDiContainer.feature.toolScreenShare.dataLayer.getTractRemoteShareSubscriber(),
            resourceViewsService: appDiContainer.dataLayer.getResourceViewsService(),
            trackActionAnalyticsUseCase: appDiContainer.domainLayer.getTrackActionAnalyticsUseCase(),
            resourcesRepository: appDiContainer.dataLayer.getResourcesRepository(),
            translationsRepository: appDiContainer.dataLayer.getTranslationsRepository(),
            mobileContentEventAnalytics: appDiContainer.getMobileContentRendererEventAnalyticsTracking(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getTranslatedLanguageName: appDiContainer.dataLayer.getTranslatedLanguageName(),
            toolOpenedAnalytics: appDiContainer.getToolOpenedAnalytics(),
            liveShareStream: liveShareStream,
            initialPage: initialPage,
            trainingTipsEnabled: trainingTipsEnabled,
            incrementUserCounterUseCase: appDiContainer.domainLayer.getIncrementUserCounterUseCase(), 
            selectedLanguageIndex: selectedLanguageIndex, 
            persistUserToolLanguageSettingsUseCase: appDiContainer.feature.toolSettings.domainLayer.getPersistUserToolLanguageSettingsUseCase(),
            shouldPersistToolSettings: shouldPersistToolSettings
        )
        
        navigationController.setSemanticContentAttribute(semanticContentAttribute: navBarLayoutDirection)
        
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
        
        var tractView: TractView?
              
        let navigationBar = AppNavigationBar(
            appearance: viewModel.navBarAppearance,
            backButton: nil,
            leadingItems: [backBarItem],
            trailingItems: [toolSettingsBarItem, remoteShareActiveBarItem],
            titleView: nil,
            title: nil
        )
        
        let view = TractView(viewModel: viewModel, navigationBar: navigationBar)
        
        tractView = view
        
        viewModel.$languageNames
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (languageNames: [String]) in
                
                let languageSelectorView: NavBarSelectorView?
                
                if languageNames.count > 1 {
                    languageSelectorView = self?.getNewLanguageSelectorView(view: tractView, viewModel: viewModel, navBarLayoutDirection: navBarLayoutDirection)
                }
                else {
                    languageSelectorView = nil
                }
                
                navigationBar.setTitleView(
                    titleView: languageSelectorView
                )
            }
            .store(in: &cancellables)
        
        viewModel.$selectedLanguageIndex
            .receive(on: DispatchQueue.main)
            .sink { (index: Int) in
                
                (navigationBar.getTitleView() as? NavBarSelectorView)?.setSelectedIndex(index: index)
            }
            .store(in: &cancellables)
        
        return view
    }
    
    private func getNewLanguageSelectorView(view: TractView?, viewModel: TractViewModel, navBarLayoutDirection: UISemanticContentAttribute) -> NavBarSelectorView {
        
        let barColor: UIColor = viewModel.navBarAppearance.backgroundColor
        let controlColor: UIColor = viewModel.navBarAppearance.controlColor ?? .white
        
        return NavBarSelectorView(
            selectorButtonTitles: viewModel.languageNames,
            layoutDirection: navBarLayoutDirection,
            selectedIndex: viewModel.selectedLanguageIndex,
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
