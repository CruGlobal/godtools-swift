//
//  LessonsContentView.swift
//  godtools
//
//  Created by Rachael Skeath on 7/12/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct LessonsContentView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: LessonsContentViewModel
    
    // MARK: - Body
    
    var body: some View {
        
        if viewModel.isLoading {
            
            ActivityIndicator(style: .medium, isAnimating: .constant(true))
            
        } else {
            
            GeometryReader { geo in
                let width = geo.size.width
                let leadingTrailingPadding = ToolsMenuView.getMargin(for: width)
                
                BackwardCompatibleList(rootViewType: Self.self) {
                    
                    LessonsListView(viewModel: viewModel.lessonsListViewModel, width: width, leadingPadding: leadingTrailingPadding)
                        .listRowInsets(EdgeInsets())
                    
                } refreshHandler: {
                    viewModel.refreshData()
                }
            }
        }
    }
}

struct LessonsContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let viewModel = LessonsContentViewModel(
            flowDelegate: MockFlowDelegate(),
            dataDownloader: appDiContainer.initialDataDownloader,
            languageSettingsService: appDiContainer.languageSettingsService,
            localizationServices: appDiContainer.localizationServices,
            analytics: appDiContainer.analytics
        )
        
        LessonsContentView(viewModel: viewModel)
    }
}
