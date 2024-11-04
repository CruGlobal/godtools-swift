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
                
                if viewModel.tabs.count > 0 {
                 
                    TabView(selection: $viewModel.currentTab) {
                        
                        Group {
                            
                            if ApplicationLayout.shared.layoutDirection == .rightToLeft {
                                
                                ForEach((0 ..< viewModel.tabs.count).reversed(), id: \.self) { index in
                                    
                                    getDashboardPageView(index: index)
                                        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
                                        .tag(index)
                                }
                            }
                            else {
                                
                                ForEach(0 ..< viewModel.tabs.count, id: \.self) { index in
                                    
                                    getDashboardPageView(index: index)
                                        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
                                        .tag(index)
                                }
                            }
                        }
                    }
                    .environment(\.layoutDirection, .leftToRight)
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeOut, value: viewModel.currentTab)
                    
                    DashboardTabBarView(
                        viewModel: viewModel
                    )
                }
            }
        }
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
    }
    
    @ViewBuilder private func getDashboardPageView(index: Int) -> some View {
        
        switch viewModel.tabs[index] {
            
        case .lessons:
            LessonsView(viewModel: viewModel.getLessonsViewModel())
            
        case .favorites:
            FavoritesView(viewModel: viewModel.getFavoritesViewModel())
            
        case .tools:
            ToolsView(viewModel: viewModel.getToolsViewModel())
        }
    }
}
    
extension DashboardView {
    
    func getCurrentTab() -> DashboardTabTypeDomainModel {
        return viewModel.getTab(tabIndex: viewModel.currentTab) ?? .favorites
    }
    
    func navigateToTab(tab: DashboardTabTypeDomainModel) {
        
        viewModel.tabTapped(tab: tab)
    }
}

// MARK: - Preview

import Combine

struct DashboardView_Previews: PreviewProvider {
    
    private static let diContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
    private static let flowDelegate: FlowDelegate = MockFlowDelegate()
    private static let dashboardDependencies: DashboardPresentationLayerDependencies = DashboardPresentationLayerDependencies(appDiContainer: DashboardView_Previews.diContainer, flowDelegate: DashboardView_Previews.flowDelegate)
        
    static func getDashboardViewModel() -> DashboardViewModel {
        
        let appDiContainer: AppDiContainer = DashboardView_Previews.diContainer
        
        let viewModel = DashboardViewModel(
            startingTab: .favorites,
            flowDelegate: DashboardView_Previews.flowDelegate,
            dashboardPresentationLayerDependencies: DashboardView_Previews.dashboardDependencies,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            viewDashboardUseCase: appDiContainer.feature.dashboard.domainLayer.getViewDashboardUseCase(), 
            dashboardTabObserver: CurrentValueSubject(.favorites)
        )
        
        return viewModel
    }
    
    static var previews: some View {
    
        DashboardView(viewModel: DashboardView_Previews.getDashboardViewModel())
    }
}
