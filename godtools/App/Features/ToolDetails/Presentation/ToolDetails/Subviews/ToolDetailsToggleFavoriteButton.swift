//
//  ToolDetailsToggleFavoriteButton.swift
//  godtools
//
//  Created by Levi Eggert on 6/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolDetailsToggleFavoriteButton: View {
    
    private let iconName: String
    private let title: String
    private let color: Color
    private let width: CGFloat
    private let height: CGFloat
    private let cornerRadius: CGFloat
    
    @ObservedObject private var viewModel: ToolDetailsViewModel
        
    init(viewModel: ToolDetailsViewModel, width: CGFloat, height: CGFloat, cornerRadius: CGFloat) {
        
        self.viewModel = viewModel
        
        if viewModel.isFavorited {
            
            iconName = ImageCatalog.unfavoriteIcon.name
            title = viewModel.removeFromFavoritesButtonTitle
            color = Color(.sRGB, red: 229 / 255, green: 91 / 255, blue: 54 / 255, opacity: 1.0)
        }
        else {
            
            iconName = ImageCatalog.favoriteIcon.name
            title = viewModel.addToFavoritesButtonTitle
            color = ColorPalette.gtBlue.color
        }
        
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        
        Button(action: {
            viewModel.toggleFavorited()
        }) {
            
            HStack(alignment: .center, spacing: 8) {
                Image(iconName)
                Text(title)
                    .foregroundColor(color)
            }
            .background(Color.white)
            .frame(width: width, height: height, alignment: .center)
        }
        .accentColor(color)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(color, lineWidth: 1)
        )
    }
}

