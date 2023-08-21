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
        
    @Published var allToolsTabTitle: String
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
        
        allToolsTabTitle = localizationServices.stringForSystemElseEnglish(key: "tool_menu_item.tools")
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
}
