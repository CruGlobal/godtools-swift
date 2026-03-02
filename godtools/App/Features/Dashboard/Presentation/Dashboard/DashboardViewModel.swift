//
//  DashboardViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 10/6/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

@MainActor class DashboardViewModel: ObservableObject {
    
    private let dashboardPresentationLayerDependencies: DashboardPresentationLayerDependencies
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getDashboardStringsUseCase: GetDashboardStringsUseCase
        
    private var cancellables: Set<AnyCancellable> = Set()
    private var initialTabSet: Bool = false
    
    private weak var flowDelegate: FlowDelegate?
        
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    
    @Published var tabs: [DashboardTabTypeDomainModel] = [.lessons, .favorites, .tools]
    @Published var lessonsButtonTitle: String = ""
    @Published var favoritesButtonTitle: String = ""
    @Published var toolsButtonTitle: String = ""
    @Published var currentTab: Int = 0
        
    init(startingTab: DashboardTabTypeDomainModel, flowDelegate: FlowDelegate, dashboardPresentationLayerDependencies: DashboardPresentationLayerDependencies, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getDashboardStringsUseCase: GetDashboardStringsUseCase, dashboardTabObserver: CurrentValueSubject<DashboardTabTypeDomainModel, Never>) {
        
        self.flowDelegate = flowDelegate
        self.dashboardPresentationLayerDependencies = dashboardPresentationLayerDependencies
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getDashboardStringsUseCase = getDashboardStringsUseCase
        
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                getDashboardStringsUseCase
                    .execute(translateInLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (strings: DashboardStringsDomainModel) in
                
                self?.lessonsButtonTitle = strings.lessonsActionTitle
                self?.favoritesButtonTitle = strings.favoritesActionTitle
                self?.toolsButtonTitle = strings.toolsActionTitle
                
                self?.reloadTabs() // NOTE: Needed since button title interface strings aren't connected to the View. ~Levi
                self?.setStartingTabIfNeeded(startingTab: startingTab, tabs: self?.tabs ?? Array())
            }
            .store(in: &cancellables)
        
        $currentTab.eraseToAnyPublisher()
            .sink { [weak self] currentTab in
                
                guard let self = self else {
                    return
                }
                
                dashboardTabObserver.send(self.tabs[currentTab])
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
    
    private func setStartingTabIfNeeded(startingTab: DashboardTabTypeDomainModel, tabs: [DashboardTabTypeDomainModel]) {
        
        guard !initialTabSet else {
            return
        }
        
        guard tabs.count > 0 else {
            return
        }
        
        initialTabSet = true
        
        currentTab = tabs.firstIndex(of: startingTab) ?? 0
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
