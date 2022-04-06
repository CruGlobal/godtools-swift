//
//  AllToolsContentView.swift
//  godtools
//
//  Created by Rachael Skeath on 3/30/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolCardView: View {
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
    
    private enum Sizes {
        static let cardHeight: CGFloat = 150
        static let cardHeightSpotlight: CGFloat = 240
        static let cardWidth: CGFloat = 335
        static let cardWidthSpotlight: CGFloat = 200
        static let bannerImageHeight: CGFloat = 87
        static let bannerImageHeightSpotlight: CGFloat = 162
        static let leadingPadding: CGFloat = 15
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 6, style: .circular)
                .fill(.white)
                .frame(width: cardWidth, height: cardHeight)
                .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
            
            VStack(alignment: .leading, spacing: 12) {
                Image("share_tool_tutorial_people")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: cardWidth, height: bannerImageHeight)
                    .clipped()
                
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

struct ToolCardView_Previews: PreviewProvider {
    static var previews: some View {
        ToolCardView()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
