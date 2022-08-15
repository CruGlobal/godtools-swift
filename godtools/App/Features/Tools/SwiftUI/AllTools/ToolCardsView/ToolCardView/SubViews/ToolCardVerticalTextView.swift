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
    let cardType: ToolCardType
    let cardWidth: CGFloat
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            
            ToolCardTitleView(title: viewModel.title)
            
            switch cardType {
            case .standard, .standardWithNavButtons:
                ToolCardCategoryView(category: viewModel.category)
                
            case .square:
                Spacer(minLength: 0)
                ResourceCardLanguageView(languageName: viewModel.parallelLanguageName)
                
            case .squareWithNavButtons:
                ToolCardCategoryView(category: viewModel.category)
                ResourceCardLanguageView(languageName: viewModel.parallelLanguageName)
                    .padding(.top, 2)
            }
        }
    }
}

struct ToolCardVerticalTextView_Previews: PreviewProvider {
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        let cardType: ToolCardType = .squareWithNavButtons
        
        let viewModel = ToolCardViewModel(
            resource: appDiContainer.initialDataDownloader.resourcesCache.getAllVisibleTools().first!,
            dataDownloader: appDiContainer.initialDataDownloader,
            languageSettingsService: appDiContainer.languageSettingsService,
            localizationServices: appDiContainer.localizationServices,
            getBannerImageUseCase: appDiContainer.domainLayer.getBannerImageUseCase(),
            getLanguageAvailabilityStringUseCase: appDiContainer.getLanguageAvailabilityStringUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.domainLayer.getToolIsFavoritedUseCase(),
            delegate: nil
        )
        
        ToolCardVerticalTextView(viewModel: viewModel, cardType: cardType, cardWidth: cardType.isSquareLayout ? 200 : 375)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
