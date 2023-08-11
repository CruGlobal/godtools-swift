//
//  ToolCardNavButtonView.swift
//  godtools
//
//  Created by Rachael Skeath on 6/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolCardNavButtonView: View {
        
    private let buttonWidth: CGFloat
    private let buttonSpacing: CGFloat
    
    @ObservedObject private var viewModel: BaseToolCardViewModel
    
    init(viewModel: BaseToolCardViewModel, sizeToFit width: CGFloat, leadingPadding: CGFloat, buttonSpacing: CGFloat) {
        
        let whiteSpaceAroundButtons = 2 * leadingPadding + buttonSpacing
        let buttonWidth = (width - whiteSpaceAroundButtons)/2
        
        self.viewModel = viewModel
        self.buttonWidth = buttonWidth
        self.buttonSpacing = buttonSpacing
        self.viewModel = viewModel
    }
        
    var body: some View {
        HStack(spacing: buttonSpacing) {
            
            GTWhiteButton(title: viewModel.detailsButtonTitle, width: buttonWidth, height: 30) {
                viewModel.toolDetailsButtonTapped()
            }
            GTBlueButton(title: viewModel.openButtonTitle, width: buttonWidth, height: 30) {
                viewModel.openToolButtonTapped()
            }
        }
    }
}

struct ToolCardNavButtonView_Previews: PreviewProvider {
    static var previews: some View {
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        let resource = appDiContainer.dataLayer.getResourcesRepository().getResource(id: "1")!
        let language = appDiContainer.domainLayer.getLanguageUseCase().getLanguage(locale: Locale(identifier: LanguageCodes.english))
        let tool = ToolDomainModel(abbreviation: "abbr", bannerImageId: "1", category: "Tool Category", currentTranslationLanguage: language!, dataModelId: "1", languageIds: [], name: "Tool Name", resource: resource)
        
        let viewModel = ToolCardViewModel(
            tool: tool,
            localizationServices: appDiContainer.dataLayer.getLocalizationServices(),
            getBannerImageUseCase: appDiContainer.domainLayer.getBannerImageUseCase(),
            getLanguageAvailabilityUseCase: appDiContainer.domainLayer.getLanguageAvailabilityUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.domainLayer.getToolIsFavoritedUseCase(),
            delegate: nil
        )
        
        ToolCardNavButtonView(viewModel: viewModel, sizeToFit: 200, leadingPadding: 20, buttonSpacing: 4)
            .previewLayout(.sizeThatFits)
    }
}
