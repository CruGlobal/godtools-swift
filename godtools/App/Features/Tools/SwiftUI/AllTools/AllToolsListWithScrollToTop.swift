//
//  AllToolsListWithScrollToTop.swift
//  godtools
//
//  Created by Rachael Skeath on 4/25/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

// ScrollViewReader only supported on iOS 14+
@available(iOS 14.0, *)
struct AllToolsListWithScrollToTop: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: AllToolsContentViewModel
    var width: CGFloat
    
    // MARK: - Body
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            
           AllToolsList(viewModel: viewModel, width: width)
            .onReceive(viewModel.scrollToTopSignal) { isAnimated in
                guard let firstToolId = viewModel.tools.first?.id else { return }
                
                if isAnimated {
                    withAnimation {
                        scrollProxy.scrollTo(firstToolId, anchor: .top)
                    }
                } else {
                    scrollProxy.scrollTo(firstToolId, anchor: .top)
                }
            }
        }
    }
}
