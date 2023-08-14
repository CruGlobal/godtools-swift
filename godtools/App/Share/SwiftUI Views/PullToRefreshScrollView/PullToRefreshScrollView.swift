//
//  PullToRefreshScrollView.swift
//  godtools
//
//  Created by Rachael Skeath on 6/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct PullToRefreshScrollView<Content: View>: View {
    
    private let showsIndicators: Bool
    private let content: () -> Content
    private let refreshHandler: () -> Void
    
    init(showsIndicators: Bool = false, @ViewBuilder content: @escaping () -> Content, refreshHandler: @escaping () -> Void) {
        
        self.showsIndicators = showsIndicators
        self.content = content
        self.refreshHandler = refreshHandler
    }
    
    var body: some View {
    
        // NOTE: Pull to refresh is supported only in iOS 15+
        
        if #available(iOS 15.0, *) {
    
            ScrollView(.vertical, showsIndicators: showsIndicators) {
                content()
            }
            .refreshable {
                refreshHandler()
            }
        }
        else {
            
            ScrollView(.vertical, showsIndicators: showsIndicators) {
                content()
            }
        }
    }
}
