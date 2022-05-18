//
//  ToolCardImageView.swift
//  godtools
//
//  Created by Rachael Skeath on 5/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolCardBannerImageView: View {
    
    // MARK: - Properties
    
    let bannerImage: Image?
    let isSpotlight: Bool
    let cardWidth: CGFloat
    let cornerRadius: CGFloat
    
    // MARK: - Constants
    
    private enum Sizes {
        enum Default {
            static let cardWidth: CGFloat = 335
            static let bannerImageHeight: CGFloat = 87
            static let bannerImageAspectRatio: CGFloat = cardWidth/bannerImageHeight
        }
        enum Spotlight {
            static let cardWidth: CGFloat = 200
            static let bannerImageHeight: CGFloat = 162
            static let bannerImageAspectRatio: CGFloat = cardWidth/bannerImageHeight
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        let bannerImageAspectRatio = isSpotlight ? Sizes.Spotlight.bannerImageAspectRatio : Sizes.Default.bannerImageAspectRatio
        
        OptionalImage(image: bannerImage, width: cardWidth, height: cardWidth / bannerImageAspectRatio)
            .cornerRadius(cornerRadius, corners: [.topLeft, .topRight])
    }
}

// MARK: - Preview

struct ToolCardBannerImageView_Previews: PreviewProvider {
    static var previews: some View {
        let isSpotlight = true
        let bannerImage = DeviceAttachmentBanners().getDeviceBanner(resourceId: "2")
        
        ToolCardBannerImageView(
            bannerImage: Image.from(uiImage: bannerImage),
            isSpotlight: isSpotlight,
            cardWidth: isSpotlight ? 200 : 375,
            cornerRadius: 6
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
