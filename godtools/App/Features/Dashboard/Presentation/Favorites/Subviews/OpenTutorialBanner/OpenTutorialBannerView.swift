//
//  OpenTutorialBannerView.swift
//  godtools
//
//  Created by Rachael Skeath on 6/25/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct OpenTutorialBannerView: View {
        
    @ObservedObject private var viewModel: OpenTutorialBannerViewModel
    
    init(viewModel: OpenTutorialBannerViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        BannerView {
            
            VStack {
                
                Text(viewModel.showTutorialText)
                    .modifier(BannerTextStyle())
                
                HStack(alignment: .center) {
                    
                    Text(viewModel.openTutorialButtonText)
                        .foregroundColor(ColorPalette.gtBlue.color)
                        .font(FontLibrary.sfProTextRegular.font(size: 17))
                        .onTapGesture {
                            viewModel.openTutorialButtonTapped()
                    }
                    
                    Image(ImageCatalog.openTutorialArrow.name)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 9, height: 17)
                        .clipped()
                }
            }
            
        } closeButtonTapHandler: {
            viewModel.closeTapped()
        }
    }
}

struct OpenTutorialBannerView_Previews: PreviewProvider {
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let viewModel = OpenTutorialBannerViewModel(
            localizationServices: appDiContainer.dataLayer.getLocalizationServices(),
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            analytics: appDiContainer.dataLayer.getAnalytics(),
            delegate: nil
        )
        
        OpenTutorialBannerView(viewModel: viewModel)
            .previewLayout(.sizeThatFits)
    }
}
