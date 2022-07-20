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
    
    @ObservedObject var viewModel: BaseLessonCardViewModel
    let cardWidth: CGFloat
    
    // MARK: - Constants
    
    private enum Sizes {
        static let cornerRadius: CGFloat = 6
        static let leadingPadding: CGFloat = 15
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .top) {
            
            RoundedCardBackgroundView(cornerRadius: Sizes.cornerRadius)
            
            VStack(alignment: .leading, spacing: 0) {
                ResourceCardBannerImageView(bannerImage: viewModel.bannerImage, isSquareLayout: false, cardWidth: cardWidth, cornerRadius: Sizes.cornerRadius)
                
                ResourceCardProgressView(frontProgress: viewModel.translationDownloadProgressValue, backProgress: viewModel.attachmentsDownloadProgressValue)
                
                VStack(alignment: .leading, spacing: 9) {
                    
                    Text(viewModel.title)
                        .font(FontLibrary.sfProTextBold.font(size: 17))
                        .foregroundColor(ColorPalette.gtGrey.color)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.trailing, 41)
                    
                    HStack {
                        Spacer()
                        ResourceCardLanguageView(languageName: viewModel.translationAvailableText)
                    }
                }
                .padding([.top, .bottom], 15)
                .padding([.leading, .trailing], Sizes.leadingPadding)
                .frame(width: cardWidth, alignment: .topLeading)
            }
            
        }
        .fixedSize(horizontal: true, vertical: true)
        // onTapGesture's tappable area doesn't always line up with the card's actual position-- possibly due to added padding (?).  This is especially noticeable on iOS14.  Adding .contentShape fixed this.
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.lessonCardTapped()
        }
    }
}

struct LessonCardView_Previews: PreviewProvider {
    static var previews: some View {
        
        let viewModel = MockLessonCardViewModel()
        
        LessonCardView(viewModel: viewModel, cardWidth: 345)
    }
}
