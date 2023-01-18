//
//  BackwardCompatibleList.swift
//  godtools
//
//  Created by Rachael Skeath on 6/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct BackwardCompatibleList<Content: View>: View {
    
    let content: () -> Content
    let refreshHandler: () -> Void
    
    init<T: View>(rootViewType: T.Type, @ViewBuilder content: @escaping () -> Content, refreshHandler: @escaping () -> Void) {
        self.content = content
        self.refreshHandler = refreshHandler
    }
    
    var body: some View {
        
        if #available(iOS 15.0, *) {
            // Pull to refresh is supported only in iOS 15+
            
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    content()
                }
            }
            .refreshable {
                refreshHandler()
            }
            
        } else {
            
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    content()
                }
            }
        }
    }
}

struct BackwardCompatibleList_Previews: PreviewProvider {
    static var previews: some View {
        BackwardCompatibleList(rootViewType: EmptyView.self) {
            ForEach(0..<10) { itemIndex in
                ZStack {
                    Color.blue
                    Text("\(itemIndex)")
                }
                .frame(width: 375, height: 100)
            }
        } refreshHandler: {}
    }
}
