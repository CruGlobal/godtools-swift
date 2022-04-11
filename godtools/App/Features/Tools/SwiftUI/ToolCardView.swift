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
    var isSpotlight: Bool = false
    
    private var cardHeight: CGFloat { isSpotlight ? Sizes.cardHeightSpotlight : Sizes.cardHeight }
    private var cardWidth: CGFloat? { isSpotlight ? Sizes.cardWidthSpotlight : nil }
    private var bannerImageHeight: CGFloat { isSpotlight ? Sizes.bannerImageHeightSpotlight : Sizes.bannerImageHeight }
    private var titleWidth: CGFloat? {
        if let cardWidth = cardWidth {
            return cardWidth - (Sizes.leadingPadding * 2)
        } else {
            return nil
        }
    }
    
    // MARK: - Constants
    
    private enum Sizes {
        static let cardHeight: CGFloat = 150
        static let cardHeightSpotlight: CGFloat = 240
        static let cardWidth: CGFloat = 335
        static let cardWidthSpotlight: CGFloat = 200
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
                .frame(width: cardWidth, height: cardHeight)
                .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
            
            VStack(alignment: .leading, spacing: 12) {
                viewModel.bannerImage?
                    .resizable()
                    .frame(width: cardWidth, height: bannerImageHeight)
                    .clipped()
                    .cornerRadius(Sizes.cornerRadius, corners: [.topLeft, .topRight])
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("Knowing God Personally")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(ColorPalette.gtGrey.color)
                    Text("Subtitle")
                        .font(.system(size: 12))
                }
                .frame(maxWidth: titleWidth, alignment: .leading)
                .padding([.leading, .trailing], 15)
            }
            
        }
    }
}

// MARK: - Preview

struct ToolCardView_Previews: PreviewProvider {
    private static let viewModel = ToolCardViewModel(getBannerImageUseCase: MockGetBannerImageUseCase())
    
    static var previews: some View {
        ToolCardView(viewModel: viewModel)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
