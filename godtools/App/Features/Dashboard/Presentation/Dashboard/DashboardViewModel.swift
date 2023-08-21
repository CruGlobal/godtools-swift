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
    private let showsLanguagesSettingsButton: CurrentValueSubject<Bool, Never>
        
    private weak var flowDelegate: FlowDelegate?
        
    @Published var tabs: [DashboardTabTypeDomainModel] = [.lessons, .favorites, .tools]
    @Published var toolsTabTitle: String
    @Published var favoritesTabTitle: String
    @Published var lessonsTabTitle: String
    @Published var selectedTab: DashboardTabTypeDomainModel {
        didSet {
            tabChanged()
        }
    }
    
    init(startingTab: DashboardTabTypeDomainModel, flowDelegate: FlowDelegate, dashboardPresentationLayerDependencies: DashboardPresentationLayerDependencies, localizationServices: LocalizationServices, showsLanguagesSettingsButton: CurrentValueSubject<Bool, Never>) {
        
        self.selectedTab = startingTab
        self.flowDelegate = flowDelegate
        self.dashboardPresentationLayerDependencies = dashboardPresentationLayerDependencies
        self.localizationServices = localizationServices
        self.showsLanguagesSettingsButton = showsLanguagesSettingsButton
        
        toolsTabTitle = localizationServices.stringForSystemElseEnglish(key: "tool_menu_item.tools")
        favoritesTabTitle = localizationServices.stringForSystemElseEnglish(key: "my_tools")
        lessonsTabTitle = localizationServices.stringForSystemElseEnglish(key: "tool_menu_item.lessons")
        
        tabChanged()
    }
    
    private func tabChanged() {
                
        showsLanguagesSettingsButton.send(selectedTab != .lessons)
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
    
    func tabTapped(tab: DashboardTabTypeDomainModel) {
        
        selectedTab = tab
    }
    
    func getTabBarItemViewModel(tab: DashboardTabTypeDomainModel) -> DashboardTabBarItemViewModel {
        
        let imageName: String
        let titleLocalizedKey: String
        
        switch tab {
            
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
            tab: tab,
            title: localizationServices.stringForSystemElseEnglish(key: titleLocalizedKey),
            imageName: imageName
        )
    }
}
