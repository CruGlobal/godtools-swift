//
//  AllToolsContentView.swift
//  godtools
//
//  Created by Rachael Skeath on 3/30/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolCardView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: ToolCardViewModel
    
    // MARK: - Constants
    
    private enum Sizes {
        static let cardAspectRatio: CGFloat = cardWidth/cardHeight
        static let cardHeight: CGFloat = 150
        static let cardHeightSpotlight: CGFloat = 240
        static let cardWidth: CGFloat = 335
        static let cardWidthSpotlight: CGFloat = 200
        static let bannerImageAspectRatio: CGFloat = cardWidth/bannerImageHeight
        static let bannerImageHeight: CGFloat = 87
        static let bannerImageHeightSpotlight: CGFloat = 162
        static let leadingPadding: CGFloat = 15
        static let cornerRadius: CGFloat = 6
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: Sizes.cornerRadius, style: .circular)
                .fill(.white)
                .aspectRatio(Sizes.cardAspectRatio, contentMode: .fit)
                .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
            
            VStack(alignment: .leading, spacing: 12) {
                viewModel.bannerImage?
                    .resizable()
                    .aspectRatio(Sizes.bannerImageAspectRatio, contentMode: .fit)
                    .cornerRadius(Sizes.cornerRadius, corners: [.topLeft, .topRight])
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(viewModel.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(ColorPalette.gtGrey.color)
                    Text(viewModel.category)
                        .font(.system(size: 12))
                }
                .padding([.leading, .trailing], 15)
            }
            
        }
    }
}

// MARK: - Preview

struct ToolCardView_Previews: PreviewProvider {
    private static let viewModel = ToolCardViewModel(
        getBannerImageUseCase: MockGetBannerImageUseCase(),
        getToolDataUseCase: MockGetToolDataUseCase()
    )
    
    static var previews: some View {
        ToolCardView(viewModel: viewModel)
            .padding()
    }
}
