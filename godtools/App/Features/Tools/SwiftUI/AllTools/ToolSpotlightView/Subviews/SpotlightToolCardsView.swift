//
//  SpotlightToolCardsView.swift
//  godtools
//
//  Created by Rachael Skeath on 5/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct SpotlightToolCardsView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: ToolSpotlightViewModel
    let width: CGFloat
    
    // MARK: - Constants
    
    private enum Sizes {
        static let spotlightCardWidthMultiplier: CGFloat = 200/375
    }
    
    // MARK: - Body
    
    var body: some View {
        
        HStack(spacing: 15) {
            ForEach(viewModel.spotlightTools) { tool in
                
                ToolCardView(
                    viewModel: viewModel.cardViewModel(for: tool),
                    cardWidth: width * Sizes.spotlightCardWidthMultiplier,
                    isSpotlight: true
                )
                    // onTapGesture's tappable area doesn't always line up with the card's actual position-- possibly due to added padding (?).  This is especially noticeable on iOS14.  Adding .contentShape fixed this.
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.spotlightToolTapped(resource: tool)
                    }
                    .padding(.bottom, 12)
                    .padding(.top, 5)
            }
        }
    }
}

struct SpotlightToolCardsView_Previews: PreviewProvider {
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
        
        SpotlightToolCardsView(viewModel: viewModel, width: 375)
    }
}
