//
//  ToolCardVerticalTextView.swift
//  godtools
//
//  Created by Rachael Skeath on 6/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolCardVerticalTextView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: BaseToolCardViewModel
    let cardWidth: CGFloat
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            
            ToolCardTitleView(title: viewModel.title)
            
            switch viewModel.cardType {
            case .standard, .standardWithNavButtons:
                ToolCardCategoryView(category: viewModel.category)
                
            case .square:
                Spacer(minLength: 0)
                ToolCardParallelLanguageView(languageName: viewModel.parallelLanguageName)
                
            case .squareWithNavButtons:
                ToolCardCategoryView(category: viewModel.category)
                ToolCardParallelLanguageView(languageName: viewModel.parallelLanguageName)
                    .padding(.top, 2)
            }
        }
    }
}

struct ToolCardVerticalTextView_Previews: PreviewProvider {
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        let cardType: ToolCardType = .squareWithNavButtons
        
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
        
        ToolCardVerticalTextView(viewModel: viewModel, cardWidth: cardType.isSquareLayout ? 200 : 375)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
