//
//  DashboardTabBarItemView.swift
//  godtools
//
//  Created by Rachael Skeath on 10/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct DashboardTabBarItemView: View {
    
    private let unSelectedColor = Color(red: 170 / 255, green: 170 / 255, blue: 170 / 255)
    private let selectedColor = ColorPalette.gtBlue.color
        
    private var viewModel: DashboardTabBarItemViewModel
    
    @Binding private var currentTab: Int
    
    init(viewModel: DashboardTabBarItemViewModel, currentTab: Binding<Int>) {
        
        self.viewModel = viewModel
        self._currentTab = currentTab
    }
    
    private var isSelected: Bool {
        return currentTab == viewModel.tabIndex
    }
     
    var body: some View {
        
        ZStack(alignment: .center) {
            
            VStack(alignment: .center, spacing: 5) {
                
                Image(viewModel.imageName)
                    .foregroundColor(isSelected ? selectedColor : unSelectedColor)
                
                Text(viewModel.title)
                    .font(FontLibrary.sfProTextRegular.font(size: 14))
                    .foregroundColor(isSelected ? selectedColor : unSelectedColor)
            }
        }
        .onTapGesture {
            currentTab = viewModel.tabIndex
        }
    }
}

struct DashboardTabBarItemView_Preview: PreviewProvider {
    
    @State private static var currentTab: Int = 0
    
    static var previews: some View {
        
        DashboardTabBarItemView(
            viewModel: DashboardTabBarItemViewModel(tabIndex: 0, title: "Lessons", imageName: ""),
            currentTab: $currentTab
        )
    }
}
