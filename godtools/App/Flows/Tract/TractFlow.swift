//
//  TractFlow.swift
//  godtools
//
//  Created by Levi Eggert on 7/27/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsShared
import Combine

class TractFlow: GTFlow {
    
    enum CompletedState: Sendable {
        case userClosedTract
        case userClosedTractToLessonsList
    }
        
    private let appLanguage: AppLanguageDomainModel
    
    private var cancellables: Set<AnyCancellable> = Set()
                    
    init(
        appDiContainer: AppDiContainer,
        appLanguage: AppLanguageDomainModel,
        toolTranslations: ToolTranslationsDomainModel,
        parentFlowIsDashboard: Bool,
        liveShareStream: String?,
        selectedLanguageIndex: Int?,
        trainingTipsEnabled: Bool,
        initialPage: MobileContentRendererInitialPage?,
        initialPageSubIndex: Int?,
        persistToolLanguageSettings: PersistToolLanguageSettingsInterface?
    ) {
        
        self.appLanguage = appLanguage
        
        let stepEmitter = FlowStepEmitter()
        
        let navigation: MobileContentRendererNavigation = appDiContainer.getMobileContentRendererNavigation(
            appLanguage: appLanguage
        )
        
        let renderer: MobileContentRenderer = appDiContainer.getMobileContentRenderer(
            type: .tract,
            navigation: navigation,
            appLanguage: appLanguage,
            toolTranslations: toolTranslations
        )
        
        let navBarLayoutDirection: UISemanticContentAttribute = ApplicationLayout.shared.currentDirection.semanticContentAttribute
        
        let viewModel = TractViewModel(
            stepEmitter: stepEmitter,
            renderer: renderer,
            tractRemoteSharePublisher: appDiContainer.feature.toolScreenShare.dataLayer.getTractRemoteSharePublisher(),
            tractRemoteShareSubscriber: appDiContainer.feature.toolScreenShare.dataLayer.getTractRemoteShareSubscriber(),
            languagesRepository: appDiContainer.core.dataLayer.getLanguagesRepository(),
            resourceViewsService: appDiContainer.core.dataLayer.getResourceViewsService(),
            trackActionAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackActionAnalyticsUseCase(),
            resourcesRepository: appDiContainer.core.dataLayer.getResourcesRepository(),
            translationsRepository: appDiContainer.core.dataLayer.getTranslationsRepository(),
            mobileContentEventAnalytics: appDiContainer.getMobileContentRendererEventAnalyticsTracking(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getTranslatedLanguageName: appDiContainer.core.domainLayer.supporting.getTranslatedLanguageName(),
            liveShareStream: liveShareStream,
            initialPage: initialPage,
            initialPageSubIndex: initialPageSubIndex,
            trainingTipsEnabled: trainingTipsEnabled,
            incrementUserCounterUseCase: appDiContainer.feature.userActivity.domainLayer.getIncrementUserCounterUseCase(),
            selectedLanguageIndex: selectedLanguageIndex,
            persistToolLanguageSettings: persistToolLanguageSettings
        )
                
        let backBarItem: NavBarItem
        
        if parentFlowIsDashboard {
            backBarItem = AppHomeBarItem(color: nil, target: viewModel, action: #selector(viewModel.homeTapped), accessibilityIdentifier: nil)
        }
        else {
            backBarItem = AppBackBarItem(target: viewModel, action: #selector(viewModel.backTapped))
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
                color: nil,
                target: viewModel,
                action: #selector(viewModel.toolSettingsTapped),
                accessibilityIdentifier: AccessibilityStrings.Button.toolSettings.id
            ),
            hidesBarItemPublisher: nil
        )
              
        let navigationBar = AppNavigationBar(
            appearance: viewModel.navBarAppearance,
            backButton: nil,
            leadingItems: [backBarItem],
            trailingItems: [toolSettingsBarItem, remoteShareActiveBarItem],
            titleView: nil,
            title: nil
        )
        
        let tractView = TractView(viewModel: viewModel, navigationBar: navigationBar)
        
        super.init(
            appDiContainer: appDiContainer,
            initialView: tractView,
            stepEmitter: stepEmitter
        )
        
        navigation.setDelegate(delegate: self)
        navigation.setToolFlow(toolFlow: self)
                        
        viewModel.$languageNames
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (languageNames: [String]) in
                
                let languageSelectorView: NavBarSelectorView?
                
                if languageNames.count > 1 {
                    languageSelectorView = self?.getNewLanguageSelectorView(
                        view: tractView,
                        viewModel: viewModel,
                        navBarLayoutDirection: navBarLayoutDirection
                    )
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
    }
    
    override func navigate(step: FlowStep) {
        
        guard let appStep = step as? AppFlowStep else {
            return
        }

        switch appStep {
                    
        case .homeTappedFromTool(let isScreenSharing):
            backTappedFromTool(isScreenSharing: isScreenSharing)
            
        case .acceptTappedFromExitToolRemoteShare:
            completeFlow(state: .userClosedTract)
            
        case .backTappedFromTool(let isScreenSharing):
            backTappedFromTool(isScreenSharing: isScreenSharing)
            
        case .toolSettingsTappedFromTool(let toolSettingsObserver, let toolSettingsDidCloseClosure):
            presentFlow(
                flow: ToolSettingsFlow(
                    appDiContainer: appDiContainer,
                    toolSettingsObserver: toolSettingsObserver,
                    toolSettingsDidCloseClosure: toolSettingsDidCloseClosure
                )
            )
            
        case .toolSettingsFlowCompleted( _):
            dismissFlow()
            
        case .toolNavigationFlowCompleted( _):
            popFlow(animated: true, popToViewController: initialView)
            
        default:
            break
        }
    }
    
    override func onPushed(animated: Bool) {
        
        appNavigationController?.setSemanticContentAttribute(semanticContentAttribute: ApplicationLayout.shared.currentDirection.semanticContentAttribute)
    }
    
    private func completeFlow(state: TractFlow.CompletedState) {
        parent?.stepEmitter.emit(step: AppFlowStep.tractFlowCompleted(state: state))
    }
    
    private func backTappedFromTool(isScreenSharing: Bool) {

        if isScreenSharing {

            let localizationServices: LocalizationServicesInterface = appDiContainer.core.dataLayer.getLocalizationServices()

            let messageKey: String = LocalizableStringKeys.exitTractRemoteShareSessionMessage.key
            let acceptTitleKey: String = LocalizableStringKeys.yes.key
            let cancelTitleKey: String = LocalizableStringKeys.no.key

            let strings: [String: String] = localizationServices.stringsForKeys(
                keys: [
                    messageKey,
                    acceptTitleKey,
                    cancelTitleKey
                ],
                fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: appLanguage),
                shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
            )

            Task {

                let view = AlertMessageView(
                    title: "",
                    message: strings[messageKey] ?? "",
                    acceptTitle: (strings[acceptTitleKey] ?? "").uppercased(),
                    cancelTitle: (strings[cancelTitleKey] ?? "").uppercased(),
                    acceptTapped: { [weak self] in

                        self?.navigate(step: AppFlowStep.acceptTappedFromExitToolRemoteShare)
                    },
                    cancelTapped: nil
                )

                presentView(view: view.controller, animated: true)
            }
        }
        else {
            completeFlow(state: .userClosedTract)
        }
    }
}

extension TractFlow {
    
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
        completeFlow(state: .userClosedTract)
    }
    
    func mobileContentRendererNavigationDeepLink(navigation: MobileContentRendererNavigation, deepLink: MobileContentRendererNavigationDeepLinkType) {
        
        switch deepLink {
        
        case .lessonsList:
            completeFlow(state: .userClosedTractToLessonsList)
        }
    }
}
