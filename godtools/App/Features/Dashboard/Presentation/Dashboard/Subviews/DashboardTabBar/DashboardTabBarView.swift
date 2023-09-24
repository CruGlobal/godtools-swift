//
//  DashboardTabBarView.swift
//  godtools
//
//  Created by Rachael Skeath on 10/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct DashboardTabBarView: View {
        
    private let layoutDirection: LayoutDirection
    
    @ObservedObject private var viewModel: DashboardViewModel
            
    init(layoutDirection: LayoutDirection = ApplicationLayout.direction.layoutDirection, viewModel: DashboardViewModel) {
        
        self.layoutDirection = layoutDirection
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        ZStack(alignment: .center) {
            
            HStack(alignment: .center, spacing: 0) {
                
                if layoutDirection == .rightToLeft {
                    
                    ForEach((0 ..< viewModel.numberOfTabs).reversed(), id: \.self) { (index: Int) in
                                            
                        DashboardTabBarItemView(
                            viewModel: viewModel.getTabBarItemViewModel(tabIndex: index),
                            currentTab: $viewModel.currentTab
                        )
                        .frame(maxWidth: .infinity)
                    }
                }
                else {
                    
                    ForEach(0 ..< viewModel.numberOfTabs, id: \.self) { (index: Int) in
                        
                        DashboardTabBarItemView(
                            viewModel: viewModel.getTabBarItemViewModel(tabIndex: index),
                            currentTab: $viewModel.currentTab
                        )
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding([.top], 16)
        .padding([.bottom], 8)
        .padding([.leading, .trailing], 8)
        .background(
            Color.white
                .edgesIgnoringSafeArea(.bottom)
                .shadow(color: .black.opacity(0.25), radius: 3, y: -2.5)
        )
        .environment(\.layoutDirection, .leftToRight)
    }
}

struct DashboardTabBarView_Previews: PreviewProvider {
        
    static var previews: some View {
        
        DashboardTabBarView(
            viewModel: DashboardView_Previews.getDashboardViewModel()
        )
    }
}
