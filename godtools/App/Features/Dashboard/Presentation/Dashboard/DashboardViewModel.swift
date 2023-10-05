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
    private let localizationServices: LocalizationServices
    private let hidesLanguagesSettingsButton: CurrentValueSubject<Bool, Never>
    private let tabs: [DashboardTabTypeDomainModel] = [.lessons, .favorites, .tools]
        
    private weak var flowDelegate: FlowDelegate?
        
    @Published var numberOfTabs: Int = 0
    @Published var currentTab: Int {
        didSet {
            tabChanged()
        }
    }
    
    init(startingTab: DashboardTabTypeDomainModel, flowDelegate: FlowDelegate, dashboardPresentationLayerDependencies: DashboardPresentationLayerDependencies, localizationServices: LocalizationServices, hidesLanguagesSettingsButton: CurrentValueSubject<Bool, Never>) {
        
        self.currentTab = tabs.firstIndex(of: startingTab) ?? 0
        self.flowDelegate = flowDelegate
        self.dashboardPresentationLayerDependencies = dashboardPresentationLayerDependencies
        self.localizationServices = localizationServices
        self.hidesLanguagesSettingsButton = hidesLanguagesSettingsButton
        
        numberOfTabs = tabs.count
                
        tabChanged()
    }
    
    private func tabChanged() {
                
        hidesLanguagesSettingsButton.send(tabs[currentTab] == .lessons)
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
        let titleLocalizedKey: String
        
        switch tabs[tabIndex] {
            
        case .lessons:
            imageName = ImageCatalog.toolsMenuLessons.name
            titleLocalizedKey = "tool_menu_item.lessons"
            
        case .favorites:
            imageName = ImageCatalog.toolsMenuFavorites.name
            titleLocalizedKey = "my_tools"
            
        case .tools:
            imageName = ImageCatalog.toolsMenuAllTools.name
            titleLocalizedKey = "tool_menu_item.tools"
        }
        
        return DashboardTabBarItemViewModel(
            tabIndex: tabIndex,
            title: localizationServices.stringForSystemElseEnglish(key: titleLocalizedKey),
            imageName: imageName
        )
    }
}
