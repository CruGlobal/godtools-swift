//
//  AccountSectionsView.swift
//  godtools
//
//  Created by Levi Eggert on 11/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct AccountSectionsView: View {
    
    static let sectionTitleFont: Font = FontLibrary.sfProTextRegular.font(size: 22)
    static let sectionTitleColor: Color = ColorPalette.gtGrey.color
    
    private let sections: [AccountSectionType] = [.activity, .globalActivity]
    private let sectionHorizontalPadding: CGFloat = 20
    
    @State private var selectedSegmentIndex: Int = 0
    
    @ObservedObject private var viewModel: AccountViewModel
    
    let geometry: GeometryProxy
    
    init(viewModel: AccountViewModel, geometry: GeometryProxy) {
        
        self.viewModel = viewModel
        self.geometry = geometry
    }
    
    var body: some View {
        
        let sectionFrameWidth: CGFloat = geometry.size.width - (sectionHorizontalPadding * 2)
        
        let segmentTitles: [String] = sections.map({
            switch $0 {
            case .activity:
                return viewModel.activityButtonTitle
            case .globalActivity:
                return viewModel.globalActivityButtonTitle
            }
        })
        
        VStack(alignment: .leading, spacing: 0) {
         
            VStack(alignment: .center, spacing: 0) {
                
                FixedVerticalSpacer(height: 20)
                
                SegmentControl(selectedIndex: $selectedSegmentIndex, segments: segmentTitles, segmentTappedClosure: { (index: Int) in
                    
                    switch sections[selectedSegmentIndex] {
                    case .activity:
                        viewModel.activityViewed()
                    case .globalActivity:
                        viewModel.globalActivityViewed()
                    }
                })
            }
            .frame(width: geometry.size.width)
            .background(Rectangle()
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 1)
                .mask(Rectangle().padding(.bottom, -8))
            )
            
            VStack(alignment: .leading, spacing: 0) {
             
                switch sections[selectedSegmentIndex] {
                    
                case .activity:
                    
                    AccountActivityView(
                        viewModel: viewModel,
                        sectionFrameWidth: sectionFrameWidth
                    )
                    
                case .globalActivity:
                    
                    AccountGlobalActivity(
                        viewModel: viewModel,
                        sectionFrameWidth: sectionFrameWidth
                    )
                }
            }
            .frame(width: sectionFrameWidth, alignment: .leading)
            .padding(EdgeInsets(top: 20, leading: sectionHorizontalPadding, bottom: 20, trailing: sectionHorizontalPadding))
            .onAppear {
                switch sections[selectedSegmentIndex] {
                case .activity:
                    viewModel.activityViewed()
                case .globalActivity:
                    viewModel.globalActivityViewed()
                }
            }
        }
    }
}
