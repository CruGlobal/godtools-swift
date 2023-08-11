//
//  PullToRefreshList.swift
//  godtools
//
//  Created by Rachael Skeath on 6/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct PullToRefreshList<Content: View>: View {
    
    let content: () -> Content
    let refreshHandler: () -> Void
    
    init<T: View>(rootViewType: T.Type, @ViewBuilder content: @escaping () -> Content, refreshHandler: @escaping () -> Void) {
        self.content = content
        self.refreshHandler = refreshHandler
    }
    
    var body: some View {
    
        // NOTE: Pull to refresh is supported only in iOS 15+
        
        if #available(iOS 15.0, *) {
    
            ScrollView(.vertical) {
                LazyVStack(alignment: .leading, spacing: 0) {
                    content()
                }
            }
            .refreshable {
                refreshHandler()
            }
        }
        else {
            
            ScrollView(.vertical) {
                LazyVStack(alignment: .leading, spacing: 0) {
                    content()
                }
            }
        }
    }
}

struct PullToRefreshList_Previews: PreviewProvider {
    
    static var previews: some View {
    
        GeometryReader { geometry in
            
            PullToRefreshList(rootViewType: EmptyView.self) {
                
                ForEach(0..<10) { itemIndex in
                    
                    ZStack {
                        Color.blue
                        Text("\(itemIndex)")
                    }
                    .frame(height: 100)
                }
                
            } refreshHandler: {
                
            }
        }
    }
}
