//
//  ToolCardsCarouselView.swift
//  godtools
//
//  Created by Rachael Skeath on 5/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolCardsCarouselView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: ToolCardProvider
    let width: CGFloat
    let leadingTrailingPadding: CGFloat
    
    // MARK: - Constants
    
    private enum Sizes {
        static let spotlightCardWidthMultiplier: CGFloat = 200/375
    }
    
    // MARK: - Body
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: 15) {
                ForEach(viewModel.tools) { tool in
                    
                    ToolCardView(
                        viewModel: viewModel.cardViewModel(for: tool),
                        cardWidth: width * Sizes.spotlightCardWidthMultiplier
                    )
                        // onTapGesture's tappable area doesn't always line up with the card's actual position-- possibly due to added padding (?).  This is especially noticeable on iOS14.  Adding .contentShape fixed this.
                        .contentShape(Rectangle())
                        .padding(.bottom, 12)
                        .padding(.top, 5)
                }
            }
            .padding([.leading, .trailing], leadingTrailingPadding)
        }
    }
}

struct ToolCardsCarouselView_Previews: PreviewProvider {
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()

        let viewModel = ToolSpotlightViewModel(
            dataDownloader: appDiContainer.initialDataDownloader,
            deviceAttachmentBanners: appDiContainer.deviceAttachmentBanners,
            favoritedResourcesCache: appDiContainer.favoritedResourcesCache,
            languageSettingsService: appDiContainer.languageSettingsService,
            localizationServices: appDiContainer.localizationServices,
            delegate: nil
        )
        
        ToolCardsCarouselView(viewModel: viewModel, width: 375, leadingTrailingPadding: 20)
    }
}
