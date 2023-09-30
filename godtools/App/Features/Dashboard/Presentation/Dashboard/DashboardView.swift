//
//  DashboardView.swift
//  godtools
//
//  Created by Rachael Skeath on 10/6/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct DashboardView: View {
        
    static let contentHorizontalInsets: CGFloat = 16
    static let toolCardVerticalSpacing: CGFloat = 15
    static let scrollViewBottomSpacingToTabBar: CGFloat = 30
        
    @ObservedObject private var viewModel: DashboardViewModel
    
    init(viewModel: DashboardViewModel) {
       
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            VStack(alignment: .center, spacing: 0) {
                
                PagedView(numberOfPages: viewModel.numberOfTabs, currentPage: $viewModel.currentTab) { (index: Int) in
                    
                    switch viewModel.getTab(tabIndex: index) {
                        
                    case .lessons:
                        LessonsView(viewModel: viewModel.getLessonsViewModel())
                        
                    case .favorites:
                        FavoritesView(viewModel: viewModel.getFavoritesViewModel())
                        
                    case .tools:
                        ToolsView(viewModel: viewModel.getToolsViewModel())
                    }
                }
                
                DashboardTabBarView(
                    viewModel: viewModel
                )
            }
        }
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
    }
}
    
extension DashboardView {
    
    func getCurrentTab() -> DashboardTabTypeDomainModel {
        return viewModel.getTab(tabIndex: viewModel.currentTab)
    }
    
    func navigateToTab(tab: DashboardTabTypeDomainModel) {
        
        viewModel.tabTapped(tab: tab)
    }
}

// MARK: - Preview

import Combine

struct DashboardView_Previews: PreviewProvider {
    
    static func getDashboardViewModel() -> DashboardViewModel {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let viewModel = DashboardViewModel(
            startingTab: .favorites,
            flowDelegate: MockFlowDelegate(),
            dashboardPresentationLayerDependencies: DashboardPresentationLayerDependencies(appDiContainer: appDiContainer, flowDelegate: MockFlowDelegate()),
            localizationServices: appDiContainer.dataLayer.getLocalizationServices(),
            showsLanguagesSettingsButton: CurrentValueSubject<Bool, Never>(false)
        )
        
        return viewModel
    }
    
    static var previews: some View {
    
        DashboardView(viewModel: DashboardView_Previews.getDashboardViewModel())
    }
}
