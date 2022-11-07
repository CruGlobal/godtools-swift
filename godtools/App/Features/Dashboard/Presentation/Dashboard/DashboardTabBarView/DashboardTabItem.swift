//
//  DashboardTabItem.swift
//  godtools
//
//  Created by Rachael Skeath on 10/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct DashboardTabItem: View {
    
    let tabType: DashboardTabTypeDomainModel
    let title: String
    let imageName: String
    
    @Binding var selectedTab: DashboardTabTypeDomainModel
    
    private let unSelectedColor = Color(red: 170 / 255, green: 170 / 255, blue: 170 / 255)
    private let selectedColor = ColorPalette.gtBlue.color
    
    var body: some View {
        
        let isSelected = selectedTab == tabType
        
        VStack(spacing: 5) {
            
            Image(imageName)
                .foregroundColor(isSelected ? selectedColor : unSelectedColor)
            
            Text(title)
                .font(FontLibrary.sfProTextRegular.font(size: 12))
                .foregroundColor(isSelected ? selectedColor : unSelectedColor)
        }
        .onTapGesture {
            selectedTab = tabType
        }
    }
}

struct DashboardTabItem_Previews: PreviewProvider {
    static var previews: some View {
        DashboardTabItem(tabType: .lessons, title: "Lessons", imageName: ImageCatalog.toolsMenuLessons.name, selectedTab: .constant(.allTools))
    }
}
