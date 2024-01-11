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

class ChooseYourOwnAdventureFlow: ToolNavigationFlow {
        
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: AppNavigationController
    
    var articleFlow: ArticleFlow?
    var chooseYourOwnAdventureFlow: ChooseYourOwnAdventureFlow?
    var lessonFlow: LessonFlow?
    var tractFlow: TractFlow?
    var downloadToolTranslationFlow: DownloadToolTranslationsFlow?
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: AppNavigationController, toolTranslations: ToolTranslationsDomainModel, initialPage: MobileContentPagesPage?) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        
        sharedNavigationController.pushViewController(
            getChooseYourOwnAdventureView(toolTranslations: toolTranslations, initialPage: initialPage),
            animated: true
        )
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
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
    
    private func getChooseYourOwnAdventureView(toolTranslations: ToolTranslationsDomainModel, initialPage: MobileContentPagesPage?) -> UIViewController {
        
        let navigation: MobileContentRendererNavigation = appDiContainer.getMobileContentRendererNavigation(
            parentFlow: self,
            navigationDelegate: self
        )
        
        let renderer: MobileContentRenderer = appDiContainer.getMobileContentRenderer(
            type: .chooseYourOwnAdventure,
            navigation: navigation,
            toolTranslations: toolTranslations
        )
        
        let viewModel = ChooseYourOwnAdventureViewModel(
            flowDelegate: self,
            renderer: renderer,
            initialPage: initialPage,
            resourcesRepository: appDiContainer.dataLayer.getResourcesRepository(),
            translationsRepository: appDiContainer.dataLayer.getTranslationsRepository(),
            mobileContentEventAnalytics: appDiContainer.getMobileContentRendererEventAnalyticsTracking(),
            fontService: appDiContainer.getFontService(),
            trainingTipsEnabled: false,
            incrementUserCounterUseCase: appDiContainer.domainLayer.getIncrementUserCounterUseCase()
        )
        
        navigationController.setSemanticContentAttribute(semanticContentAttribute: viewModel.layoutDirection)
        
        navigationController.setLayoutDirectionPublisher(
            layoutDirectionPublisher: Just(viewModel.layoutDirection).eraseToAnyPublisher()
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
            layoutDirectionPublisher: Just(viewModel.layoutDirection).eraseToAnyPublisher()
        )
        
        let barColor: UIColor = viewModel.navBarAppearance.backgroundColor
        let controlColor: UIColor = viewModel.navBarAppearance.controlColor ?? .white
        
        let languageSelector: NavBarSelectorView?
        let title: String?
        
        var chooseYourOwnAdventureView: ChooseYourOwnAdventureView?
        
        if viewModel.languageNames.count > 1 {
            
            languageSelector = NavBarSelectorView(
                selectorButtonTitles: viewModel.languageNames,
                layoutDirection: viewModel.layoutDirection,
                borderColor: controlColor,
                selectedColor: controlColor,
                deselectedColor: UIColor.clear,
                selectedTitleColor: barColor.withAlphaComponent(1),
                deselectedTitleColor: controlColor,
                titleFont: viewModel.languageFont,
                selectorTappedClosure: { (index: Int) in
                    chooseYourOwnAdventureView?.languageTapped(index: index)
                },
                highlightSelectorPublisher: viewModel.$selectedLanguageIndex.eraseToAnyPublisher()
            )
            
            title = nil
        }
        else {
            
            languageSelector = nil
            
            title = "GodTools"
        }
        
        let navigationBar = AppNavigationBar(
            appearance: viewModel.navBarAppearance,
            backButton: nil,
            leadingItems: [homeButton, backButton],
            trailingItems: [],
            titleView: languageSelector,
            title: title
        )
        
        let view = ChooseYourOwnAdventureView(viewModel: viewModel, navigationBar: navigationBar)
        
        chooseYourOwnAdventureView = view
        
        return view
    }
}

extension ChooseYourOwnAdventureFlow: MobileContentRendererNavigationDelegate {
    
    func mobileContentRendererNavigationDismissRenderer(navigation: MobileContentRendererNavigation, event: DismissToolEvent) {
        closeTool()
    }
    
    func mobileContentRendererNavigationDeepLink(navigation: MobileContentRendererNavigation, deepLink: MobileContentRendererNavigationDeepLinkType) {
        
    }
}
