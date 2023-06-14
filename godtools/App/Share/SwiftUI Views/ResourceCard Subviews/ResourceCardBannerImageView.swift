//
//  ResourceCardBannerImageView.swift
//  godtools
//
//  Created by Rachael Skeath on 5/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ResourceCardBannerImageView: View {
    
    // MARK: - Properties
    
    let bannerImage: Image?
    let isSquareLayout: Bool
    let cardWidth: CGFloat
    let cornerRadius: CGFloat
    
    // MARK: - Constants
    
    private enum Sizes {
        enum Standard {
            static let cardWidth: CGFloat = 335
            static let bannerImageHeight: CGFloat = 87
            static let bannerImageAspectRatio: CGFloat = cardWidth/bannerImageHeight
        }
        enum Square {
            static let cardWidth: CGFloat = 200
            static let bannerImageHeight: CGFloat = 162
            static let bannerImageAspectRatio: CGFloat = cardWidth/bannerImageHeight
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        let bannerImageAspectRatio = isSquareLayout ? Sizes.Square.bannerImageAspectRatio : Sizes.Standard.bannerImageAspectRatio
        
        OptionalImage(image: bannerImage, width: cardWidth, height: cardWidth / bannerImageAspectRatio)
            .cornerRadius(cornerRadius, corners: [.topLeft, .topRight])
            .animation(.default)
    }
}

// MARK: - Preview

struct ResourceCardBannerImageView_Previews: PreviewProvider {
    static var previews: some View {

        let cardType: ToolCardType = .square
        
        ResourceCardBannerImageView(
            bannerImage: Image("previewBannerImage"),
            isSquareLayout: cardType.isSquareLayout,
            cardWidth: cardType.isSquareLayout ? 200 : 375,
            cornerRadius: 6
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
