//
//  AccountView.swift
//  godtools
//
//  Created by Levi Eggert on 11/15/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct AccountView: View {
    
    static let sectionTitleFont: Font = FontLibrary.sfProTextRegular.font(size: 22)
    static let sectionTitleColor: Color = ColorPalette.gtGrey.color
    
    private let sections: [AccountSectionType] = [.activity, .globalActivity]
    private let sectionHorizontalPadding: CGFloat = 20
    
    @ObservedObject var viewModel: AccountViewModel
    
    @State private var selectedSegmentIndex: Int = 0
        
    var body: some View {
        
        GeometryReader { geometry in
            
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    VStack(alignment: .center, spacing: 0) {
                        
                        FixedVerticalSpacer(height: 40)
                        
                        AccountUserDetailsView(viewModel: viewModel)
                        
                        FixedVerticalSpacer(height: 32)
                        
                        let segmentTitles: [String] = sections.map({
                            switch $0 {
                            case .activity:
                                return viewModel.activityButtonTitle
                            case .globalActivity:
                                return viewModel.globalActivityButtonTitle
                            }
                        })
                        
                        SegmentControl(selectedIndex: $selectedSegmentIndex, segments: segmentTitles, segmentTappedClosure: { (index: Int) in
                            
                            switch sections[selectedSegmentIndex] {
                            case .activity:
                                viewModel.activityTapped()
                            case .globalActivity:
                                viewModel.globalActivityTapped()
                            }
                        })
                    }
                    .background(Rectangle()
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 1)
                        .mask(Rectangle().padding(.bottom, -8))
                    )
                    
                    FixedVerticalSpacer(height: 20)
                }
                
                let sectionFrameWidth: CGFloat = geometry.size.width - (sectionHorizontalPadding * 2)
                
                VStack(alignment: .leading, spacing: 0) {
                 
                    switch sections[selectedSegmentIndex] {
                        
                    case .activity:
                        
                        Rectangle()
                            .fill(Color.red)
                            .frame(height: 500)
                        
                    case .globalActivity:
                        
                        AccountGlobalActivity(
                            viewModel: viewModel,
                            sectionFrameWidth: sectionFrameWidth
                        )
                    }
                }
                .frame(width: sectionFrameWidth, alignment: .leading)
                .padding(EdgeInsets(top: 32, leading: sectionHorizontalPadding, bottom: 20, trailing: sectionHorizontalPadding))
            }//end ScrollView
        }//end Geometry
        .navigationTitle(viewModel.navTitle)
        .navigationBarBackButtonHidden(true)
        .background(ColorPalette.getColorWithRGB(red: 245, green: 245, blue: 245, opacity: 1))
        .edgesIgnoringSafeArea(.bottom)
    }//end body
}
