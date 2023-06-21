//
//  FavoritingToolBannerView.swift
//  godtools
//
//  Created by Rachael Skeath on 4/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct FavoritingToolBannerView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: FavoritingToolBannerViewModel
    
    // MARK: - Body
    
    var body: some View {
        
        BannerView {
            
            Text(viewModel.message)
                .modifier(BannerTextStyle())
            
        } closeButtonTapHandler: {
            
            viewModel.closeTapped()
        }
    }
}

struct FavoritingToolBannerView_Previews: PreviewProvider {
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        let viewModel = FavoritingToolBannerViewModel(localizationServices: appDiContainer.dataLayer.getLocalizationServices(), delegate: nil)
        
        FavoritingToolBannerView(viewModel: viewModel)
            .frame(width: 375)
            .previewLayout(.sizeThatFits)
    }
}
