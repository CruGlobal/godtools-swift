//
//  LessonCardView.swift
//  godtools
//
//  Created by Rachael Skeath on 6/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct LessonCardView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: BaseToolCardViewModel
    let cardWidth: CGFloat
    
    // MARK: - Constants
    
    private enum Sizes {
        static let cornerRadius: CGFloat = 6
        static let leadingPadding: CGFloat = 15
        static let navButtonWidthMultiplier: CGFloat = 192/335
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .top) {
            
            RoundedCardBackgroundView(cornerRadius: Sizes.cornerRadius)
            
            VStack(alignment: .leading, spacing: 0) {
                ToolCardBannerImageView(bannerImage: viewModel.bannerImage, cardType: viewModel.cardType, cardWidth: cardWidth, cornerRadius: Sizes.cornerRadius)
                ZStack(alignment: .topTrailing) {
                    
                }
                
                Text("How to move your everyday conversations to a deeper level")
                    .font(FontLibrary.sfProTextBold.font(size: 15))
                    .foregroundColor(ColorPalette.gtGrey.color)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 12)
                    .padding(.bottom, 14)
                    .padding([.leading, .trailing], Sizes.leadingPadding)
                    .frame(width: cardWidth, alignment: .topLeading)
            }
            
        }
        .fixedSize(horizontal: true, vertical: true)
        .environment(\.layoutDirection, viewModel.layoutDirection)
        // onTapGesture's tappable area doesn't always line up with the card's actual position-- possibly due to added padding (?).  This is especially noticeable on iOS14.  Adding .contentShape fixed this.
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.toolCardTapped()
        }
    }
}

struct LessonCardView_Previews: PreviewProvider {
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        let cardType: ToolCardType = .standard
        
        let viewModel = MockToolCardViewModel(
            cardType: cardType,
            title: "Knowing God Personally",
            category: "Gospel Invitation",
            showParallelLanguage: true,
            showBannerImage: true,
            attachmentsDownloadProgress: 0.80,
            translationDownloadProgress: 0.55,
            deviceAttachmentBanners: appDiContainer.deviceAttachmentBanners
        )
        
        LessonCardView(viewModel: viewModel, cardWidth: 375)
    }
}
