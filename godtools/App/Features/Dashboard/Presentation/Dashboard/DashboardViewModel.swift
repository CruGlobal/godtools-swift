//
//  DashboardViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 10/6/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class DashboardViewModel: ObservableObject {
    
    private let dashboardPresentationLayerDependencies: DashboardPresentationLayerDependencies
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let viewDashboardUseCase: ViewDashboardUseCase
    private let tabs: [DashboardTabTypeDomainModel] = [.lessons, .favorites, .tools]
        
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
        
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    
    @Published var hidesLanguagesSettingsButton: Bool = true
    @Published var lessonsButtonTitle: String = ""
    @Published var favoritesButtonTitle: String = ""
    @Published var toolsButtonTitle: String = ""
    @Published var numberOfTabs: Int = 0
    @Published var currentTab: Int {
        didSet {
            tabChanged()
        }
    }
    
    init(startingTab: DashboardTabTypeDomainModel, flowDelegate: FlowDelegate, dashboardPresentationLayerDependencies: DashboardPresentationLayerDependencies, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, viewDashboardUseCase: ViewDashboardUseCase) {
        
        self.currentTab = tabs.firstIndex(of: startingTab) ?? 0
        self.flowDelegate = flowDelegate
        self.dashboardPresentationLayerDependencies = dashboardPresentationLayerDependencies
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.viewDashboardUseCase = viewDashboardUseCase
        
        numberOfTabs = tabs.count
                
        tabChanged()
        
        $appLanguage.eraseToAnyPublisher()
            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewDashboardDomainModel, Never> in
                return self.viewDashboardUseCase
                    .viewPublisher(appLanguage: appLanguage)
                    .eraseToAnyPublisher()
            })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (domainModel: ViewDashboardDomainModel) in
                
                self?.lessonsButtonTitle = domainModel.interfaceStrings.lessonsActionTitle
                self?.favoritesButtonTitle = domainModel.interfaceStrings.favoritesActionTitle
                self?.toolsButtonTitle = domainModel.interfaceStrings.toolsActionTitle
            }
            .store(in: &cancellables)
    }
    
    private func tabChanged() {
                        
        hidesLanguagesSettingsButton = tabs[currentTab] == .lessons
    }
    
    func getTab(tabIndex: Int) -> DashboardTabTypeDomainModel {
        return tabs[tabIndex]
    }
}

// MARK: - Inputs

extension DashboardViewModel {
    
    @objc func menuTapped() {
        flowDelegate?.navigate(step: .menuTappedFromTools)
    }
            
    @objc func languageSettingsTapped() {
        flowDelegate?.navigate(step: .languageSettingsTappedFromTools)
    }
    
    func getLessonsViewModel() -> LessonsViewModel {
        return dashboardPresentationLayerDependencies.lessonsViewModel
    }
    
    func getFavoritesViewModel() -> FavoritesViewModel {
        return dashboardPresentationLayerDependencies.favoritesViewModel
    }
    
    func getToolsViewModel() -> ToolsViewModel {
        return dashboardPresentationLayerDependencies.toolsViewModel
    }
    
    func tabTapped(tabIndex: Int) {
        
        currentTab = tabIndex
    }
    
    func tabTapped(tab: DashboardTabTypeDomainModel) {
        
        guard let index = tabs.firstIndex(of: tab) else {
            return
        }
        
        tabTapped(tabIndex: index)
    }
    
    func getTabBarItemViewModel(tabIndex: Int) -> DashboardTabBarItemViewModel {
        
        let imageName: String
        let title: String
        
        switch tabs[tabIndex] {
            
        case .lessons:
            imageName = ImageCatalog.toolsMenuLessons.name
            title = lessonsButtonTitle
            
        case .favorites:
            imageName = ImageCatalog.toolsMenuFavorites.name
            title = favoritesButtonTitle
            
        case .tools:
            imageName = ImageCatalog.toolsMenuAllTools.name
            title = toolsButtonTitle
        }
        
        return DashboardTabBarItemViewModel(
            tabIndex: tabIndex,
            title: title,
            imageName: imageName
        )
    }
}
