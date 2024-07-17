//
//  FavoritingToolBannerView.swift
//  godtools
//
//  Created by Rachael Skeath on 4/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct FavoritingToolBannerView: View {
        
    @ObservedObject private var viewModel: ToolsViewModel
    
    init(viewModel: ToolsViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        BannerView {
            
            Text(viewModel.favoritingToolBannerMessage)
                .modifier(BannerTextStyle())
            
        } closeButtonTapHandler: {
            
            viewModel.closeFavoritingToolBannerTapped()
        }
    }
}

// MARK: - Preview

struct FavoritingToolBannerView_Preview: PreviewProvider {
    
    static var previews: some View {
        
        FavoritingToolBannerView(
            viewModel: AllToolsView_Preview.getToolsViewModel()
        )
    }
}
