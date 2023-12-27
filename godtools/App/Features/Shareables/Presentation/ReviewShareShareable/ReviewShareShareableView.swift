//
//  ReviewShareShareableView.swift
//  godtools
//
//  Created by Levi Eggert on 6/15/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ReviewShareShareableView: View {
    
    private let maxPreviewImageSize: CGFloat = 250
    private let bottomSpacing: CGFloat = 50
    
    @ObservedObject private var viewModel: ReviewShareShareableViewModel
    
    init(viewModel: ReviewShareShareableViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        GeometryReader { geometry in
                        
            VStack(alignment: .center, spacing: 0) {
                
                HStack {
                    Spacer()
                    CloseButton {
                        viewModel.closeTapped()
                    }
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 10))
                }
                
                Spacer()
                
                OptionalImage(
                    imageData: viewModel.imagePreviewData,
                    imageSize: .fixed(width: maxPreviewImageSize, height: maxPreviewImageSize),
                    contentMode: .fit,
                    placeholderColor: ColorPalette.gtLightestGrey.color
                )
                .padding(EdgeInsets(top: 0, leading: 50, bottom: 0, trailing: 50))
                
                Spacer()
                
                Button(action: {
                    viewModel.shareImageTapped()
                }) {
                    
                    HStack(alignment: .center, spacing: 8) {
                        Image(ImageCatalog.toolSettingsShareImageButtonIcon.name)
                        Text(viewModel.shareImageButtonTitle)
                            .foregroundColor(.white)
                    }
                }
                .frame(width: 200, height: 50, alignment: .center)
                .background(ColorPalette.gtBlue.color)
                .cornerRadius(6)
            }
            .frame(width: geometry.size.width)
            .padding(EdgeInsets(top: 0, leading: 0, bottom: bottomSpacing, trailing: 0))
        }
        .background(Color.white)
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
    }
}

struct ReviewShareShareableViewPreview: PreviewProvider {
    
    static var previews: some View {
        
        ReviewShareShareableView(viewModel: ReviewShareShareableViewPreview.getReviewShareShareableViewModel())
    }
    
    static func getReviewShareShareableViewModel() -> ReviewShareShareableViewModel {
                
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let resource: ResourceModel = appDiContainer.dataLayer.getResourcesRepository().getResource(id: "1")!
                
        return ReviewShareShareableViewModel(
            flowDelegate: MockFlowDelegate(),
            resource: resource,
            shareable: ShareableDomainModel(dataModelId: "", imageName: "", title: ""),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            viewReviewShareShareableUseCase: appDiContainer.feature.shareables.domainLayer.getViewReviewShareShareableUseCase(),
            getShareableImageUseCase: appDiContainer.feature.shareables.domainLayer.getShareableImageUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.domainLayer.getTrackActionAnalyticsUseCase()
        )
    }
}
