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
    private let tappedClosure: (() -> Void)?
        
    private var viewModel: DashboardTabBarItemViewModel
    
    @Binding private var selectedTab: DashboardTabTypeDomainModel
    
    init(viewModel: DashboardTabBarItemViewModel, selectedTab: Binding<DashboardTabTypeDomainModel>, tappedClosure: (() -> Void)?) {
        
        self.viewModel = viewModel
        self._selectedTab = selectedTab
        self.tappedClosure = tappedClosure
    }
    
    private var isSelected: Bool {
        return selectedTab == viewModel.tab
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
            tappedClosure?()
        }
    }
}

struct DashboardTabBarItemView_Preview: PreviewProvider {
    
    @State private static var selectedTab: DashboardTabTypeDomainModel = .lessons
    
    static var previews: some View {
        
        DashboardTabBarItemView(
            viewModel: DashboardTabBarItemViewModel(tab: .lessons, title: "Lessons", imageName: ""),
            selectedTab: $selectedTab,
            tappedClosure: nil
        )
    }
}
