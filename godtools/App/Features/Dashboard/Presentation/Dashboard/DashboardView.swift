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
                
                TabView(selection: $viewModel.selectedTab) {
                    
                    Group {
                        
                        ForEach(viewModel.tabs) { (tab: DashboardTabTypeDomainModel) in
                                                        
                            switch tab {
                                
                            case .lessons:
                                LessonsView(viewModel: viewModel.getLessonsViewModel())
                                    .tag(tab)
                                
                            case .favorites:
                                FavoritesView(viewModel: viewModel.getFavoritesViewModel())
                                    .tag(tab)
                                
                            case .tools:
                                ToolsView(viewModel: viewModel.getToolsViewModel())
                                    .tag(tab)
                            }
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeOut, value: viewModel.selectedTab)
                
                DashboardTabBarView(
                    viewModel: viewModel,
                    selectedTab: $viewModel.selectedTab
                )
            }
        }
    }
}
    
extension DashboardView {
    
    func navigateToTab(_ tab: DashboardTabTypeDomainModel) {
        
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

