//
//  ChooseYourOwnAdventureFlow.swift
//  godtools
//
//  Created by Levi Eggert on 1/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser
import Combine

class ChooseYourOwnAdventureFlow: ToolNavigationFlow, ToolSettingsNavigationFlow {
        
    private let appLanguage: AppLanguageDomainModel
    
    internal var toolSettingsFlow: ToolSettingsFlow?
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: AppNavigationController
    
    var articleFlow: ArticleFlow?
    var chooseYourOwnAdventureFlow: ChooseYourOwnAdventureFlow?
    var lessonFlow: LessonFlow?
    var tractFlow: TractFlow?
    var downloadToolTranslationFlow: DownloadToolTranslationsFlow?
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: AppNavigationController, appLanguage: AppLanguageDomainModel, toolTranslations: ToolTranslationsDomainModel, initialPage: MobileContentPagesPage?, selectedLanguageIndex: Int?) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        self.appLanguage = appLanguage
        
        sharedNavigationController.pushViewController(
            getChooseYourOwnAdventureView(toolTranslations: toolTranslations, initialPage: initialPage, selectedLanguageIndex: selectedLanguageIndex),
            animated: true
        )
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
        case .toolSettingsTappedFromChooseYourOwnAdventure(let toolSettingsObserver):
            
            openToolSettings(with: toolSettingsObserver)
            
        case .toolSettingsFlowCompleted(let state):
            
            guard toolSettingsFlow != nil else { return }
            
            navigationController.dismiss(animated: true)
            
            toolSettingsFlow = nil
            
        case .backTappedFromChooseYourOwnAdventure:
            closeTool()
            
        default:
            break
        }
    }
    
    private func closeTool() {
        flowDelegate?.navigate(step: .chooseYourOwnAdventureFlowCompleted(state: .userClosedTool))
    }
}

extension ChooseYourOwnAdventureFlow {
    
    private func getChooseYourOwnAdventureView(toolTranslations: ToolTranslationsDomainModel, initialPage: MobileContentPagesPage?, selectedLanguageIndex: Int?) -> UIViewController {
        
        let navigation: MobileContentRendererNavigation = appDiContainer.getMobileContentRendererNavigation(
            parentFlow: self,
            navigationDelegate: self,
            appLanguage: appLanguage
        )
        
        let renderer: MobileContentRenderer = appDiContainer.getMobileContentRenderer(
            type: .chooseYourOwnAdventure,
            navigation: navigation,
            appLanguage: appLanguage,
            toolTranslations: toolTranslations
        )
        
        let navBarLayoutDirection: UISemanticContentAttribute = ApplicationLayout.shared.currentDirection.semanticContentAttribute
        
        let viewModel = ChooseYourOwnAdventureViewModel(
            flowDelegate: self,
            renderer: renderer,
            initialPage: initialPage,
            resourcesRepository: appDiContainer.dataLayer.getResourcesRepository(),
            translationsRepository: appDiContainer.dataLayer.getTranslationsRepository(),
            mobileContentEventAnalytics: appDiContainer.getMobileContentRendererEventAnalyticsTracking(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getTranslatedLanguageName: appDiContainer.dataLayer.getTranslatedLanguageName(),
            trainingTipsEnabled: false,
            incrementUserCounterUseCase: appDiContainer.domainLayer.getIncrementUserCounterUseCase(),
            selectedLanguageIndex: selectedLanguageIndex
        )
        
        navigationController.setSemanticContentAttribute(semanticContentAttribute: navBarLayoutDirection)
                
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
                style: .plain,
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
        
        var chooseYourOwnAdventureView: ChooseYourOwnAdventureView?
        let view = ChooseYourOwnAdventureView(viewModel: viewModel, navigationBar: navigationBar)
        
        chooseYourOwnAdventureView = view
        
        viewModel.$languageNames
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (languageNames: [String]) in
                                
                if languageNames.count > 1 {
                    navigationBar.setTitleView(
                        titleView: self?.getNewLanguageSelectorView(view: chooseYourOwnAdventureView, viewModel: viewModel, navBarLayoutDirection: navBarLayoutDirection)
                    )
                }
                else {
                    navigationBar.setTitle(title: "GodTools")
                }
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
        closeTool()
    }
    
    func mobileContentRendererNavigationDeepLink(navigation: MobileContentRendererNavigation, deepLink: MobileContentRendererNavigationDeepLinkType) {
        
    }
}
