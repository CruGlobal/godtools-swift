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
        
        /*
         About removing the List separators:
         - iOS 15 - use the `listRowSeparator` view modifier to hide the separators
         - iOS 13 - list is built on UITableView, so `UITableView.appearance` works to set the separator style
         - iOS 14 - `appearance` no longer works, and the modifier doesn't yet exist.  Solution is the AllToolsListIOS14 view.
         */
        if #available(iOS 14.0, *) {} else {
            // TODO: - When we stop supporting iOS 13, get rid of this.
            UITableView.appearance(whenContainedInInstancesOf: [UIHostingController<T>.self]).separatorStyle = .none
        }
    }
    
    var body: some View {
        
        if #available(iOS 15.0, *) {
            // Pull to refresh is supported only in iOS 15+
            
            List {
                content()
                    .listRowSeparator(.hidden)
                    
            }
            .modifier(PlainList())
            .refreshable {
                refreshHandler()
            }
            
        } else if #available(iOS 14.0, *) {
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    content()
                }
            }
                                    
        } else {
            
            List {
                content()
            }
            .modifier(PlainList())
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
