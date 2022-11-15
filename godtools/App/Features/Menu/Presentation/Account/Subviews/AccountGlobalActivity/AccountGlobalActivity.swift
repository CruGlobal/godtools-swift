//
//  AccountGlobalActivity.swift
//  godtools
//
//  Created by Levi Eggert on 11/15/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct AccountGlobalActivity: View {
    
    private let itemSpacing: CGFloat = 20
    
    @ObservedObject var viewModel: AccountViewModel
    
    let sectionFrameWidth: CGFloat
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            Text(viewModel.globalActivityTitle)
                .font(AccountView.sectionTitleFont)
                .foregroundColor(AccountView.sectionTitleColor)
                .multilineTextAlignment(.leading)
            
            FixedVerticalSpacer(height: 15)
            
            let itemWidth: CGFloat = (sectionFrameWidth - itemSpacing) / 2
            let itemAspectRatio = CGSize(width: 158, height: 128)
            let itemSize = CGSize(width: itemWidth, height: (itemAspectRatio.height / itemAspectRatio.width) * itemWidth)
            
            VStack(alignment: .leading, spacing: itemSpacing) {
             
                ForEach(0 ..< viewModel.numberOfGlobalActivityThisWeekItems, id: \.self) { index in
                    
                    let isNewColumn: Bool = index % 2 == 0
                    
                    if isNewColumn {
                       
                        HStack(alignment: .center, spacing: itemSpacing) {
                            
                            let leftIndex: Int = index
                            let rightIndex: Int = index + 1
                            
                            AccountGlobalActivityAnalyticsItemView(viewModel: viewModel.globalActivityAnalyticsItemWillAppear(index: leftIndex))
                                .frame(width: itemSize.width, height: itemSize.height)
                                                        
                            if rightIndex < viewModel.numberOfGlobalActivityThisWeekItems {
                                
                                AccountGlobalActivityAnalyticsItemView(viewModel: viewModel.globalActivityAnalyticsItemWillAppear(index: rightIndex))
                                    .frame(width: itemSize.width, height: itemSize.height)
                            }
                        }
                    }
                }
            }
        }
    }
}
