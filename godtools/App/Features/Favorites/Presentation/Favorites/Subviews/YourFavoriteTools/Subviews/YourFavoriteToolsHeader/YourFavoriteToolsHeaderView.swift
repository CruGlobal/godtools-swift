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
            
            Text(viewModel.strings.favoriteToolsTitle)
                .font(FontLibrary.sfProTextRegular.font(size: 22))
                .foregroundColor(ColorPalette.gtGrey.color)
                .fixedSize(horizontal: false, vertical: true) // This is necessary for multiline text to push HStack height.
                .padding(.leading, contentHorizontalInsets)
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
