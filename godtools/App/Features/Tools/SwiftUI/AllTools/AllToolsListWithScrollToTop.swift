//
//  AllToolsListWithScrollToTop.swift
//  godtools
//
//  Created by Rachael Skeath on 4/25/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

// TODO: - GT-1541 will remove the ability to programmatically scroll to the top and just reset the whole view instead, so this whole file can be trashed.

// ScrollViewReader only supported on iOS 14+
@available(iOS 14.0, *)
struct AllToolsListWithScrollToTop: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: AllToolsContentViewModel
    let width: CGFloat
    
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
