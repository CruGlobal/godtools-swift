//
//  YourFavoriteToolsHeaderView.swift
//  godtools
//
//  Created by Rachael Skeath on 6/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct YourFavoriteToolsHeaderView: View {
        
    private let contentHorizontalInsets: CGFloat
    
    @ObservedObject private var viewModel: FavoritesViewModel
    
    init(viewModel: FavoritesViewModel, contentHorizontalInsets: CGFloat) {
        
        self.viewModel = viewModel
        self.contentHorizontalInsets = contentHorizontalInsets
    }
    
    var body: some View {
        
        HStack(alignment: .bottom) {
            
            Text(viewModel.yourFavoriteToolsTitle)
                .font(FontLibrary.sfProTextRegular.font(size: 22))
                .foregroundColor(ColorPalette.gtGrey.color)
                .fixedSize(horizontal: false, vertical: true) // This is necessary for multiline text to push HStack height.
                .padding(.leading, contentHorizontalInsets)
                            
            if viewModel.yourFavoriteTools.count > 0 {
                
                Spacer()
                
                Button(action: {

                    viewModel.viewAllFavoriteToolsTapped()
                    
                }) {
                    
                    Text(viewModel.viewAllFavoriteToolsButtonTitle)
                        .font(FontLibrary.sfProTextRegular.font(size: 13))
                        .foregroundColor(ColorPalette.gtBlue.color)
                        .frame(alignment: .bottom)
                }
                .padding([.trailing], 20)
                .padding([.bottom], 2)
            }
        }
        .padding([.top], 6)
    }
}

// MARK: - Preview

struct YourFavoriteToolsHeaderView_Preview: PreviewProvider {
    
    static var previews: some View {
        
        YourFavoriteToolsHeaderView(
            viewModel: FavoritesView_Preview.getFavoritesViewModel(),
            contentHorizontalInsets: 20
        )
    }
}
