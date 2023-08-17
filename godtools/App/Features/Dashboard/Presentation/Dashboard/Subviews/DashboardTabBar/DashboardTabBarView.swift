//
//  DashboardTabBarView.swift
//  godtools
//
//  Created by Rachael Skeath on 10/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct DashboardTabBarView: View {
    
    @ObservedObject private var viewModel: DashboardViewModel
    
    init(viewModel: DashboardViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        ZStack {
            
            HStack {
                                
                DashboardTabItemView(tabType: .lessons, title: viewModel.lessonsTabTitle, imageName: ImageCatalog.toolsMenuLessons.name, selectedTab: $viewModel.selectedTab)
                    .frame(maxWidth: .infinity)
                
                DashboardTabItemView(tabType: .favorites, title: viewModel.favoritesTabTitle, imageName: ImageCatalog.toolsMenuFavorites.name, selectedTab: $viewModel.selectedTab)
                    .frame(maxWidth: .infinity)
                                
                DashboardTabItemView(tabType: .tools, title: viewModel.allToolsTabTitle, imageName: ImageCatalog.toolsMenuAllTools.name, selectedTab: $viewModel.selectedTab)
                    .frame(maxWidth: .infinity)
                
            }
            .padding(.top, 16)
            .padding(.bottom, 8)
            .padding([.leading, .trailing], 8)
            .frame(maxWidth: .infinity)
            .background(
                Color.white
                    .edgesIgnoringSafeArea(.bottom)
                    .shadow(color: .black.opacity(0.35), radius: 4, y: 0)
            )
        }
    }
}

struct DashboardTabBarView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        DashboardTabBarView(viewModel: DashboardView_Previews.getDashboardViewModel())
    }
}
