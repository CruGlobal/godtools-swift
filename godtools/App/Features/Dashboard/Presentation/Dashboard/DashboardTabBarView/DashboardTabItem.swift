//
//  DashboardTabItem.swift
//  godtools
//
//  Created by Rachael Skeath on 10/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct DashboardTabItem: View {
    
    let title: String
    let imageName: String
    
    let isSelected: Bool
    
    let unSelectedColor = Color(red: 170 / 255, green: 170 / 255, blue: 170 / 255)
    let selectedColor = ColorPalette.gtBlue.color
    
    var body: some View {
        VStack(spacing: 5) {
            Image(imageName)
                .foregroundColor(isSelected ? selectedColor : unSelectedColor)
            Text(title)
                .font(FontLibrary.sfProTextRegular.font(size: 12))
                .foregroundColor(isSelected ? selectedColor : unSelectedColor)
        }
    }
}

struct DashboardTabItem_Previews: PreviewProvider {
    static var previews: some View {
        DashboardTabItem(title: "Lessons", imageName: ImageCatalog.toolsMenuLessons.name, isSelected: true)
    }
}
