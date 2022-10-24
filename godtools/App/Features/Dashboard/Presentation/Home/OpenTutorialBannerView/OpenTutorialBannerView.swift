//
//  OpenTutorialBannerView.swift
//  godtools
//
//  Created by Rachael Skeath on 6/25/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct OpenTutorialBannerView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: OpenTutorialBannerViewModel
    
    // MARK: - Body
    
    var body: some View {
        
        BannerView {
            VStack {
                Text(viewModel.showTutorialText)
                    .modifier(BannerTextStyle())
                
                HStack {
                    Text(viewModel.openTutorialButtonText)
                        .foregroundColor(ColorPalette.gtBlue.color)
                        .font(FontLibrary.sfProTextRegular.font(size: 17))
                        .onTapGesture {
                            viewModel.openTutorialButtonTapped()
                    }
                    
                    Image(ImageCatalog.openTutorialArrow.name)
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
            flowDelegate: MockFlowDelegate(),
            localizationServices: appDiContainer.localizationServices,
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            analytics: appDiContainer.analytics,
            delegate: nil
        )
        
        OpenTutorialBannerView(viewModel: viewModel)
            .previewLayout(.sizeThatFits)
    }
}
