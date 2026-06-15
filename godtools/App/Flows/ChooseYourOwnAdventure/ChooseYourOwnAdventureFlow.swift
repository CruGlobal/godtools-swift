//
//  ChooseYourOwnAdventureFlow.swift
//  godtools
//
//  Created by Levi Eggert on 1/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import GodToolsShared
import Combine

final class ChooseYourOwnAdventureFlow: GTFlow {
    
    enum CompletedState: Sendable {
        case userClosedTool
    }
        
    private let appLanguage: AppLanguageDomainModel
    
    private var cancellables: Set<AnyCancellable> = Set()
                
    init(
        appDiContainer: AppDiContainer,
        appLanguage: AppLanguageDomainModel,
        toolTranslations: ToolTranslationsDomainModel,
        initialPage: MobileContentRendererInitialPage?,
        initialPageSubIndex: Int?,
        selectedLanguageIndex: Int?,
        trainingTipsEnabled: Bool
    ) {
        
        self.appLanguage = appLanguage
        
        let rendererNavigation: MobileContentRendererNavigation = appDiContainer.getMobileContentRendererNavigation(
            appLanguage: appLanguage
        )
        
        let renderer: MobileContentRenderer = appDiContainer.getMobileContentRenderer(
            type: .chooseYourOwnAdventure,
            navigation: rendererNavigation,
            appLanguage: appLanguage,
            toolTranslations: toolTranslations
        )
        
        let navBarLayoutDirection: UISemanticContentAttribute = ApplicationLayout.shared.currentDirection.semanticContentAttribute
        
        let stepEmitter = FlowStepEmitter()
        
        let viewModel = ChooseYourOwnAdventureViewModel(
            stepEmitter: stepEmitter,
            renderer: renderer,
            initialPage: initialPage,
            initialPageSubIndex: initialPageSubIndex,
            resourcesRepository: appDiContainer.core.dataLayer.getResourcesRepository(),
            translationsRepository: appDiContainer.core.dataLayer.getTranslationsRepository(),
            mobileContentEventAnalytics: appDiContainer.getMobileContentRendererEventAnalyticsTracking(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getTranslatedLanguageName: appDiContainer.core.domainLayer.supporting.getTranslatedLanguageName(),
            trainingTipsEnabled: trainingTipsEnabled,
            incrementUserCounterUseCase: appDiContainer.feature.userActivity.domainLayer.getIncrementUserCounterUseCase(),
            selectedLanguageIndex: selectedLanguageIndex
        )
                
        let homeButton = AppHomeBarItem(
            color: nil,
            target: viewModel,
            action: #selector(viewModel.homeTapped),
            accessibilityIdentifier: nil,
            hidesBarItemPublisher: viewModel.$hidesHomeButton.eraseToAnyPublisher()
        )
        
        let backButton = AppBackBarItem(
            target: viewModel,
            action: #selector(viewModel.backTapped),
            accessibilityIdentifier: nil,
            hidesBarItemPublisher: viewModel.$hidesBackButton.eraseToAnyPublisher(),
            layoutDirectionPublisher: Just(navBarLayoutDirection).eraseToAnyPublisher()
        )
        
        let toolSettingsBarItem = NavBarItem(
            controllerType: .base,
            itemData: NavBarItemData(
                contentType: .image(value: ImageCatalog.navToolSettings.uiImage),
                color: nil,
                target: viewModel,
                action: #selector(viewModel.toolSettingsTapped),
                accessibilityIdentifier: nil
            ),
            hidesBarItemPublisher: nil
        )
        
        let navigationBar = AppNavigationBar(
            appearance: viewModel.navBarAppearance,
            backButton: nil,
            leadingItems: [homeButton, backButton],
            trailingItems: [toolSettingsBarItem],
            titleView: nil,
            title: nil
        )
        
        let chooseYourOwnAdventureView = ChooseYourOwnAdventureView(viewModel: viewModel, navigationBar: navigationBar)
                
        super.init(
            appDiContainer: appDiContainer,
            initialView: chooseYourOwnAdventureView,
            stepEmitter: stepEmitter
        )
        
        rendererNavigation.setDelegate(delegate: self)
        rendererNavigation.setToolFlow(toolFlow: self)
        
        viewModel.$languageNames
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (languageNames: [String]) in
                                
                if languageNames.count > 1 {
                    navigationBar.setTitleView(
                        titleView: self?.getNewLanguageSelectorView(view: chooseYourOwnAdventureView, viewModel: viewModel, navBarLayoutDirection: navBarLayoutDirection)
                    )
                } else {
                    navigationBar.setTitle(title: "")
                }
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
            
        case .toolSettingsTappedFromChooseYourOwnAdventure(let toolSettingsObserver):
            presentFlow(
                flow: ToolSettingsFlow(
                    appDiContainer: appDiContainer,
                    toolSettingsObserver: toolSettingsObserver,
                    toolSettingsDidCloseClosure: nil
                )
            )
                        
        case .toolSettingsFlowCompleted( _):
            dismissFlow()
            
        case .backTappedFromChooseYourOwnAdventure:
            completeFlow(state: .userClosedTool)
            
        case .toolNavigationFlowCompleted( _):
            pushedFlow?.popFlow()
            popFlow()
            
        default:
            break
        }
    }
    
    override func onPushed(animated: Bool) {
        
        appNavigationController?.setSemanticContentAttribute(semanticContentAttribute: ApplicationLayout.shared.currentDirection.semanticContentAttribute)
    }
    
    private func completeFlow(state: CompletedState) {
        parent?.stepEmitter.emit(step: AppFlowStep.chooseYourOwnAdventureFlowCompleted(state: state))
    }
}

extension ChooseYourOwnAdventureFlow {
        
    private func getNewLanguageSelectorView(view: ChooseYourOwnAdventureView?, viewModel: ChooseYourOwnAdventureViewModel, navBarLayoutDirection: UISemanticContentAttribute) -> NavBarSelectorView {
        
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

extension ChooseYourOwnAdventureFlow: MobileContentRendererNavigationDelegate {
    
    func mobileContentRendererNavigationDismissRenderer(navigation: MobileContentRendererNavigation, event: DismissToolEvent) {
        completeFlow(state: .userClosedTool)
    }
    
    func mobileContentRendererNavigationDeepLink(navigation: MobileContentRendererNavigation, deepLink: MobileContentRendererNavigationDeepLinkType) {
        
    }
}
