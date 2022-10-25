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
        let resource = appDiContainer.dataLayer.getResourcesRepository().getResource(id: "1")!
        let language = appDiContainer.domainLayer.getLanguageUseCase().getLanguage(locale: Locale(identifier: LanguageCodes.english))
        let tool = ToolDomainModel(abbreviation: "abbr", bannerImageId: "1", category: "Tool Category", currentTranslationLanguage: language!, dataModelId: "1", languageIds: [], name: "Tool Name", resource: resource)
        
        let viewModel = ToolCardViewModel(
            tool: tool,
            dataDownloader: appDiContainer.initialDataDownloader,
            localizationServices: appDiContainer.localizationServices,
            getBannerImageUseCase: appDiContainer.domainLayer.getBannerImageUseCase(),
            getLanguageAvailabilityUseCase: appDiContainer.domainLayer.getLanguageAvailabilityUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.domainLayer.getToolIsFavoritedUseCase(),
            delegate: nil
        )
        
        ToolCardVerticalTextView(viewModel: viewModel, cardType: cardType, cardWidth: cardType.isSquareLayout ? 200 : 375)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
