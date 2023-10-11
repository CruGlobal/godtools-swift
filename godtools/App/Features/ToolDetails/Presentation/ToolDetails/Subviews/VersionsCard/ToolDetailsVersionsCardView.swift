//
//  ToolDetailsVersionsCardView.swift
//  godtools
//
//  Created by Levi Eggert on 6/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolDetailsVersionsCardView: View {
        
    @ObservedObject private var viewModel: ToolDetailsVersionsCardViewModel
    
    let width: CGFloat
        
    init(viewModel: ToolDetailsVersionsCardViewModel, width: CGFloat) {
        
        self.viewModel = viewModel
        self.width = width
    }
    
    var body: some View {
        
        ZStack {
            
            Color.white
            
            VStack(alignment: .leading, spacing: 0) {
                
                OptionalImage(
                    imageData: viewModel.bannerImageData,
                    imageSize: .aspectRatio(width: width, aspectRatio: CGSize(width: 335, height: 87)),
                    contentMode: .fill,
                    placeholderColor: ColorPalette.gtLightestGrey.color
                )
                
                HStack(alignment: .top, spacing: 0) {
                    
                    CircleSelectorView(isSelected: viewModel.isSelected)
                        .padding(EdgeInsets(top: 3, leading: 0, bottom: 0, trailing: 0))
                    
                    Rectangle()
                        .fill(.clear)
                        .frame(width: 16)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        Text(viewModel.name)
                            .foregroundColor(ColorPalette.gtGrey.color)
                            .font(FontLibrary.sfProTextSemibold.font(size: 19))
                        
                        Rectangle()
                            .fill(.clear)
                            .frame(height: 5)
                        
                        Text(viewModel.description)
                            .foregroundColor(ColorPalette.gtGrey.color)
                            .font(FontLibrary.sfProTextRegular.font(size: 15))
                        
                        Rectangle()
                            .fill(.clear)
                            .frame(height: 35)
                        
                        HStack(alignment: .top, spacing: 0) {
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 5) {
                                
                                Text(viewModel.languages)
                                
                                if let toolLanguageName = viewModel.toolLanguageName, !toolLanguageName.isEmpty {
                                    LanguageSupportedText(languageName: toolLanguageName, isSupported: viewModel.toolLanguageNameIsSupported)
                                }
                            }
                            .foregroundColor(ColorPalette.gtLightGrey.color)
                            .font(FontLibrary.sfProTextRegular.font(size: 13))
                        }
                    }
                }
                .padding(EdgeInsets(top: 15, leading: 25, bottom: 25, trailing: 25))
            }
        }
        .cornerRadius(6)
        .shadow(color: Color.black.opacity(0.3), radius: 4, x: 1, y: 1)
    }
}

struct ToolDetailsVersionsCardView_Preview: PreviewProvider {
    
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let toolVersion = ToolVersionDomainModel(
            bannerImageId: "1",
            dataModelId: "1",
            description: "Tool description",
            name: "Tool name",
            numberOfLanguages: "45 languages",
            toolLanguageName: "Spanish",
            toolLanguageNameIsSupported: true
        )
        
        let viewModel = ToolDetailsVersionsCardViewModel(
            toolVersion: toolVersion,
            attachmentsRepository: appDiContainer.dataLayer.getAttachmentsRepository(),
            isSelected: false
        )
        
        ToolDetailsVersionsCardView(viewModel: viewModel, width: 320)
    }
}
