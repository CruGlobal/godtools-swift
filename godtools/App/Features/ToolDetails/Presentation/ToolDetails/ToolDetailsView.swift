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
    
    @State private var selectedSegmentIndex: Int? = 0
    
    @ObservedObject var viewModel: ToolDetailsViewModel
    
    var body: some View {
        
        GeometryReader { geometry in
            
            VStack(alignment: .leading, spacing: 0) {
                
                ToolDetailsMediaView(viewModel: viewModel, width: geometry.size.width)
                
                ScrollView(.vertical, showsIndicators: true) {
                    
                    ToolDetailsTitleHeaderView(viewModel: viewModel)
                        .padding(EdgeInsets(top: 40, leading: contentInsets.leading, bottom: 0, trailing: contentInsets.trailing))
                    
                    ToolDetailsPrimaryButtonsView(viewModel: viewModel, primaryButtonWidth: geometry.size.width - contentInsets.leading - contentInsets.trailing)
                        .padding(EdgeInsets(top: 16, leading: contentInsets.leading, bottom: 0, trailing: contentInsets.trailing))                    
                                        
                    SegmentControl(selectedIndex: $selectedSegmentIndex, segments: [viewModel.aboutTitle, viewModel.versionsTitle], segmentTappedClosure: { (index: Int) in
                                                
                    })
                    .padding(EdgeInsets(top: 50, leading: 0, bottom: 0, trailing: 0))
                    
                    Rectangle()
                        .frame(width: geometry.size.width, height: 20)
                        .foregroundColor(.clear)
                                        
                    ToolDetailsAboutView(viewModel: viewModel, width: geometry.size.width - contentInsets.leading - contentInsets.trailing)
                        .padding(EdgeInsets(top: 0, leading: contentInsets.leading, bottom: 0, trailing: contentInsets.trailing))
                }
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
