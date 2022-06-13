//
//  ToolDetailsPrimaryButtonsView.swift
//  godtools
//
//  Created by Levi Eggert on 6/9/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolDetailsPrimaryButtonsView: View {
    
    private let primaryButtonHeight: CGFloat = 55
    private let primaryButtonCornerRadius: CGFloat = 8
    private let addToFavoritesButtonColor: Color = ColorPalette.gtBlue.color
    private let removeFromFavoritesButtonColor: Color = Color(.sRGB, red: 229 / 255, green: 91 / 255, blue: 54 / 255, opacity: 1.0)
    
    @ObservedObject var viewModel: ToolDetailsViewModel
       
    let primaryButtonWidth: CGFloat
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 12) {
            
            Button(action: {
                viewModel.openToolTapped()
            }) {
                Text(viewModel.openToolButtonTitle)
                    .foregroundColor(Color.white)
            }
            .frame(width: primaryButtonWidth, height: primaryButtonHeight, alignment: .center)
            .background(ColorPalette.gtBlue.color)
            .cornerRadius(primaryButtonCornerRadius)
            
            if !viewModel.hidesLearnToShareToolButton {
                
                Button(action: {
                    viewModel.learnToShareToolTapped()
                }) {
                    Text(viewModel.learnToShareToolButtonTitle)
                        .foregroundColor(Color.white)
                }
                .frame(width: primaryButtonWidth, height: primaryButtonHeight, alignment: .center)
                .background(ColorPalette.gtBlue.color)
                .cornerRadius(primaryButtonCornerRadius)
            }
            
            if !viewModel.hidesAddToFavoritesButton {
                
                Button(action: {
                    viewModel.addToFavoritesTapped()
                }) {
                    
                    HStack(alignment: .center, spacing: 8) {
                        Image(ImageCatalog.favoriteIcon.name)
                        Text(viewModel.addToFavoritesButtonTitle)
                            .foregroundColor(addToFavoritesButtonColor)
                    }
                }
                .frame(width: primaryButtonWidth, height: primaryButtonHeight, alignment: .center)
                .background(Color.white)
                .accentColor(addToFavoritesButtonColor)
                .overlay(
                        RoundedRectangle(cornerRadius: primaryButtonCornerRadius)
                            .stroke(addToFavoritesButtonColor, lineWidth: 1)
                    )
            }
            
            if !viewModel.hidesRemoveFromFavoritesButton {
                
                Button(action: {
                    viewModel.removeFromFavoritesTapped()
                }) {
                    
                    HStack(alignment: .center, spacing: 8) {
                        Image(ImageCatalog.unfavoriteIcon.name)
                        Text(viewModel.removeFromFavoritesButtonTitle)
                            .foregroundColor(removeFromFavoritesButtonColor)
                    }
                }
                .frame(width: primaryButtonWidth, height: primaryButtonHeight, alignment: .center)
                .background(Color.white)
                .accentColor(removeFromFavoritesButtonColor)
                .overlay(
                        RoundedRectangle(cornerRadius: primaryButtonCornerRadius)
                            .stroke(removeFromFavoritesButtonColor, lineWidth: 1)
                    )
            }
        }
    }
}
