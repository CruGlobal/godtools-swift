//
//  ToolDetailsView.swift
//  godtools
//
//  Created by Levi Eggert on 6/9/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolDetailsView: View {
    
    private static let headerViewId: String = "HeaderViewId"
    
    private let contentInsets: EdgeInsets = EdgeInsets(top: 0, leading: 40, bottom: 0, trailing: 40)
    
    @State private var selectedSegmentIndex: Int? = 0
    
    @ObservedObject var viewModel: ToolDetailsViewModel
    
    var body: some View {
        
        GeometryReader { geometry in
            
            let contentWidth: CGFloat = geometry.size.width - contentInsets.leading - contentInsets.trailing
            
            VStack(alignment: .leading, spacing: 0) {
                
                ToolDetailsMediaView(viewModel: viewModel, width: geometry.size.width)
                
                ScrollView(.vertical, showsIndicators: true) {
                    
                    if #available(iOS 14, *) {
                        
                        ScrollViewReader { scrollViewReader in
                            
                            getScrollViewContent(geometry: geometry, contentWidth: contentWidth) {
                                
                                scrollViewReader.scrollTo(ToolDetailsView.headerViewId)
                            }
                        }
                    }
                    else {
                        
                        getScrollViewContent(geometry: geometry, contentWidth: contentWidth) {
                            
                        }
                    }
                }
            }
        }
        .background(Color(.sRGB, red: 245 / 255, green: 245 / 255, blue: 245 / 255, opacity: 1))
        .onAppear {
            viewModel.pageViewed()
        }
    }
    
    @ViewBuilder
    private func getScrollViewContent(geometry: GeometryProxy, contentWidth: CGFloat, toolVersionTappedClosure: @escaping (() -> Void)) -> some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            VStack(alignment: .center, spacing: 0) {
                                         
                 ToolDetailsTitleHeaderView(viewModel: viewModel)
                     .padding(EdgeInsets(top: 40, leading: contentInsets.leading, bottom: 0, trailing: contentInsets.trailing))
                     .id(ToolDetailsView.headerViewId)
                 
                 ToolDetailsPrimaryButtonsView(viewModel: viewModel, primaryButtonWidth: contentWidth)
                     .padding(EdgeInsets(top: 16, leading: contentInsets.leading, bottom: 0, trailing: contentInsets.trailing))
                                     
                 SegmentControl(selectedIndex: $selectedSegmentIndex, segments: viewModel.segments, segmentTappedClosure: { (index: Int) in
                     
                     viewModel.segmentTapped(index: index)
                 })
                 .padding(EdgeInsets(top: 50, leading: 0, bottom: 0, trailing: 0))
             }
             .background(Rectangle()
                 .fill(Color.white)
                 .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 1)
             )
             
             Rectangle()
                 .frame(width: geometry.size.width, height: 20)
                 .foregroundColor(.clear)
             
             switch viewModel.selectedSegment {
             
             case .about:
                 ToolDetailsAboutView(viewModel: viewModel, width: contentWidth)
                     .padding(EdgeInsets(top: 0, leading: contentInsets.leading, bottom: 0, trailing: contentInsets.trailing))
             
             case .versions:
                 ToolDetailsVersionsView(
                    viewModel: viewModel,
                    geometry: geometry,
                    toolVersionTappedClosure: toolVersionTappedClosure
                 )
             }
             
             Rectangle()
                 .frame(width: geometry.size.width, height: 20)
                 .foregroundColor(.clear)
        }
        .frame(width: geometry.size.width)
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
            getTranslatedLanguageUseCase: appDiContainer.getTranslatedLanguageUseCase(),
            getToolTranslationsUseCase: appDiContainer.getToolTranslationsUseCase(),
            languagesRepository: appDiContainer.dataLayer.getLanguagesRepository(),
            getToolVersionsUseCase: appDiContainer.getToolVersionsUseCase(),
            bannerImageRepository: appDiContainer.getResourceBannerImageRepository()
        )
        
        return ToolDetailsView(viewModel: viewModel)
    }
}
