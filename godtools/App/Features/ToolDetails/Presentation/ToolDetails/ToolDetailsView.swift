//
//  ToolDetailsView.swift
//  godtools
//
//  Created by Levi Eggert on 6/9/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolDetailsView: View {
    
    private let contentInsets: EdgeInsets = EdgeInsets(top: 0, leading: 40, bottom: 0, trailing: 40)
    
    @ObservedObject var viewModel: ToolDetailsViewModel
    
    var body: some View {
        
        GeometryReader { geometry in
            
            VStack(alignment: .leading, spacing: 0) {
                
                ToolDetailsMediaView(viewModel: viewModel, geometry: geometry)
                
                ToolDetailsTitleHeaderView(viewModel: viewModel)
                    .padding(EdgeInsets(top: 40, leading: contentInsets.leading, bottom: 0, trailing: contentInsets.trailing))
                
                ToolDetailsPrimaryButtonsView(viewModel: viewModel, contentInsets: contentInsets, geometry: geometry)
                    .padding(EdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0))
                
                ToolDetailsSectionsHeaderView(geometry: geometry)
            }
        }
        .onAppear {
            viewModel.pageViewed()
        }
    }
}

struct ToolDetailsView_Preview: PreviewProvider {
    
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let viewModel = ToolDetailsViewModel(
            flowDelegate: MockFlowDelegate(),
            resource: appDiContainer.initialDataDownloader.resourcesCache.getResource(id: "1")!,
            dataDownloader: appDiContainer.initialDataDownloader,
            languageSettingsService: appDiContainer.languageSettingsService,
            localizationServices: appDiContainer.localizationServices,
            favoritedResourcesCache: appDiContainer.favoritedResourcesCache,
            analytics: appDiContainer.analytics,
            getToolTranslationsUseCase: appDiContainer.getToolTranslationsUseCase(),
            languagesRepository: appDiContainer.getLanguagesRepository()
        )
        
        return ToolDetailsView(viewModel: viewModel)
    }
}
