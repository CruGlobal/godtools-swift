//
//  ToolDetailsView.swift
//  godtools
//
//  Created by Levi Eggert on 6/9/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolDetailsView: View {
    
    static let scrollToTopViewId: String = "ToolDetailsView.scrollToTopViewId"
    
    static let sectionDescriptionTextInsets: EdgeInsets = EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30)
    
    private let contentInsets: EdgeInsets = EdgeInsets(top: 0, leading: 40, bottom: 0, trailing: 40)
    
    @State private var selectedSegmentIndex: Int = 0
    
    @ObservedObject private var viewModel: ToolDetailsViewModel
    
    init(viewModel: ToolDetailsViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            let contentWidth: CGFloat = geometry.size.width - contentInsets.leading - contentInsets.trailing
              
            ScrollView(.vertical, showsIndicators: true) {
                
                ScrollViewReader { scrollViewReader in
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        ToolDetailsScrollViewTopView(geometry: geometry)
                        
                        ToolDetailsMediaView(viewModel: viewModel, width: geometry.size.width)
                        
                        VStack(alignment: .center, spacing: 0) {
                                                     
                             ToolDetailsTitleHeaderView(viewModel: viewModel)
                                 .padding(EdgeInsets(top: 40, leading: contentInsets.leading, bottom: 0, trailing: contentInsets.trailing))
                             
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
                             .mask(Rectangle().padding(.bottom, -8))
                         )
                         
                         Rectangle()
                             .frame(width: geometry.size.width, height: 20)
                             .foregroundColor(.clear)
                         
                         switch viewModel.selectedSegment {
                         
                         case .about:
                             ToolDetailsAboutView(
                                viewModel: viewModel,
                                geometry: geometry
                             )
                         
                         case .versions:
                             ToolDetailsVersionsView(
                                viewModel: viewModel,
                                geometry: geometry,
                                toolVersionTappedClosure: {
                                    scrollViewReader.scrollTo(ToolDetailsView.scrollToTopViewId)
                                }
                             )
                         }
                         
                         Rectangle()
                             .frame(width: geometry.size.width, height: 20)
                             .foregroundColor(.clear)
                    }
                    .frame(width: geometry.size.width)
                }
            }
        }
        .navigationBarBackButtonHidden(true) // TODO: (GT-1794) This is a temp fix for iOS 16.  Will need to update to configure the navigation bar using SwiftUI instead of UIHostingController's. ~Levi
        .background(Color(.sRGB, red: 245 / 255, green: 245 / 255, blue: 245 / 255, opacity: 1))
        .edgesIgnoringSafeArea(.bottom)
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
        .onAppear {
            viewModel.pageViewed()
        }
    }
}

struct ToolDetailsView_Preview: PreviewProvider {
    
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let tool: ToolDomainModel = appDiContainer.domainLayer.getToolUseCase().getTool(id: "1")!
        
        let viewModel = ToolDetailsViewModel(
            flowDelegate: MockFlowDelegate(),
            tool: tool,
            primaryLanguage: LanguageCodeDomainModel.english.rawValue,
            parallelLanguage: nil,
            selectedLanguageIndex: nil,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getToolUseCase: appDiContainer.domainLayer.getToolUseCase(),
            viewToolDetailsUseCase: appDiContainer.feature.toolDetails.domainLayer.getViewToolDetailsUseCase(),
            getToolDetailsMediaUseCase: appDiContainer.feature.toolDetails.domainLayer.getToolDetailsMediaUseCase(),
            getToolDetailsLearnToShareToolIsAvailableUseCase: appDiContainer.feature.toolDetails.domainLayer.getToolDetailsLearnToShareToolIsAvailableUseCase(),
            toggleToolFavoritedUseCase: appDiContainer.domainLayer.getToggleToolFavoritedUseCase(),
            attachmentsRepository: appDiContainer.dataLayer.getAttachmentsRepository(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.domainLayer.getTrackActionAnalyticsUseCase()
        )
        
        return ToolDetailsView(viewModel: viewModel)
    }
}
