//
//  ToolCardNavButtonView.swift
//  godtools
//
//  Created by Rachael Skeath on 6/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolCardNavButtonView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: BaseToolCardViewModel
    private let buttonWidth: CGFloat
    private let buttonSpacing: CGFloat
    
    init(sizeToFit width: CGFloat, leadingPadding: CGFloat, buttonSpacing: CGFloat, viewModel: BaseToolCardViewModel) {
        let whiteSpaceAroundButtons = 2 * leadingPadding + buttonSpacing
        let buttonWidth = (width - whiteSpaceAroundButtons)/2
        
        self.buttonWidth = buttonWidth
        self.buttonSpacing = buttonSpacing
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    
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
        let resource = appDiContainer.initialDataDownloader.resourcesCache.getAllVisibleTools().first!
        let tool = ToolDomainModel(abbreviation: "abbr", bannerImageId: "1", category: "Tool Category", currentTranslation: .englishFallback(translation: nil), dataModelId: "1", languageIds: [], name: "Tool Name", resource: resource)
        
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
        
        ToolCardNavButtonView(sizeToFit: 200, leadingPadding: 20, buttonSpacing: 4, viewModel: viewModel)
            .previewLayout(.sizeThatFits)
    }
}
