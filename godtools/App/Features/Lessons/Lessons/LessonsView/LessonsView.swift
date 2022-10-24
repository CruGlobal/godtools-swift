//
//  LessonsView.swift
//  godtools
//
//  Created by Rachael Skeath on 7/12/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct LessonsView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: LessonsViewModel
    
    // MARK: - Body
    
    var body: some View {
        
        if viewModel.isLoading {
            
            ActivityIndicator(style: .medium, isAnimating: .constant(true))
            
        } else {
            
            GeometryReader { geo in
                let width = geo.size.width
                let leadingTrailingPadding = ToolsMenuView.getMargin(for: width)
                
                BackwardCompatibleList(rootViewType: Self.self) {
                    
                    VStack(alignment: .leading, spacing: 5) {
                        
                        Text(viewModel.sectionTitle)
                            .font(FontLibrary.sfProTextRegular.font(size: 22))
                            .foregroundColor(ColorPalette.gtGrey.color)
                        
                        Text(viewModel.subtitle)
                            .font(FontLibrary.sfProTextRegular.font(size: 14))
                            .foregroundColor(ColorPalette.gtGrey.color)
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 7)
                    .padding([.leading, .trailing], leadingTrailingPadding)
                    .listRowInsets(EdgeInsets())
                    
                    ForEach(viewModel.lessons) { lesson in
                        
                        LessonCardView(viewModel: viewModel.cardViewModel(for: lesson), cardWidth: width - 2 * leadingTrailingPadding)
                            .listRowInsets(EdgeInsets())
                            .contentShape(Rectangle())
                            .padding([.top, .bottom], 8)
                            .padding([.leading, .trailing], leadingTrailingPadding)
                        
                    }
                    .listRowInsets(EdgeInsets())
                    
                } refreshHandler: {
                    viewModel.refreshData()
                }
                .animation(.default, value: viewModel.lessons)
            }
        }
    }
}

struct LessonsView_Previews: PreviewProvider {
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let viewModel = LessonsViewModel(
            flowDelegate: MockFlowDelegate(),
            dataDownloader: appDiContainer.initialDataDownloader,
            localizationServices: appDiContainer.localizationServices,
            analytics: appDiContainer.analytics,
            getBannerImageUseCase: appDiContainer.domainLayer.getBannerImageUseCase(),
            getLanguageAvailabilityUseCase: appDiContainer.domainLayer.getLanguageAvailabilityUseCase(),
            getLessonsUseCase: appDiContainer.domainLayer.getLessonsUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            translationsRepository: appDiContainer.dataLayer.getTranslationsRepository()
        )
        
        LessonsView(viewModel: viewModel)
    }
}
