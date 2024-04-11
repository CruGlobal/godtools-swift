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
        
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
        
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    
    @Published var tabs: [DashboardTabTypeDomainModel] = [.lessons, .favorites, .tools]
    @Published var lessonsButtonTitle: String = ""
    @Published var favoritesButtonTitle: String = ""
    @Published var toolsButtonTitle: String = ""
    @Published var currentTab: Int = 0
    
    init(startingTab: DashboardTabTypeDomainModel, flowDelegate: FlowDelegate, dashboardPresentationLayerDependencies: DashboardPresentationLayerDependencies, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, viewDashboardUseCase: ViewDashboardUseCase) {
        
        self.flowDelegate = flowDelegate
        self.dashboardPresentationLayerDependencies = dashboardPresentationLayerDependencies
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.viewDashboardUseCase = viewDashboardUseCase
        self.currentTab = tabs.firstIndex(of: startingTab) ?? 0
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .assign(to: &$appLanguage)
        
        $appLanguage.eraseToAnyPublisher()
            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewDashboardDomainModel, Never> in
                return viewDashboardUseCase
                    .viewPublisher(appLanguage: appLanguage)
                    .eraseToAnyPublisher()
            })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (domainModel: ViewDashboardDomainModel) in
                
                self?.lessonsButtonTitle = domainModel.interfaceStrings.lessonsActionTitle
                self?.favoritesButtonTitle = domainModel.interfaceStrings.favoritesActionTitle
                self?.toolsButtonTitle = domainModel.interfaceStrings.toolsActionTitle
                
                self?.reloadTabs() // NOTE: Needed since button title interface strings aren't connected to the View. ~Levi
            }
            .store(in: &cancellables)        
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func reloadTabs() {
        
        let currentTabs: [DashboardTabTypeDomainModel] = tabs
        tabs = currentTabs
    }
    
    func getTab(tabIndex: Int) -> DashboardTabTypeDomainModel? {
        guard tabIndex >= 0 && tabIndex < tabs.count else {
            return nil
        }
        return tabs[tabIndex]
    }
}

// MARK: - Inputs

extension DashboardViewModel {
    
    @objc func menuTapped() {
        flowDelegate?.navigate(step: .menuTappedFromTools)
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
