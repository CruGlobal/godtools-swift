//
//  PagedView.swift
//  godtools
//
//  Created by Levi Eggert on 9/13/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

// NOTE: This view is a wrapper around TabView and was created to fix a bug specifically to iOS 16 where a TabView page index would get reversed when the device settings is using a right to left language.
// This would cause the TabBar tied to the TabView to reverse as well and navigation was also reversed when tapping Tabs to navigate the TabView. ~Levi

@available(iOS, obsoleted: 14.0, message: "Marking as obsoleted due to a retain cycle happening in @ViewBuilder content: @escaping (_ page: Int) -> Content that was unable to be resolved.")
struct PagedView<Content: View>: View {
    
    private let numberOfPages: Int
    private let content: (_ page: Int) -> Content
    
    @Binding private var currentPage: Int
    
    init(numberOfPages: Int, currentPage: Binding<Int>, @ViewBuilder content: @escaping (_ page: Int) -> Content) {
        
        self.numberOfPages = numberOfPages
        self._currentPage = currentPage
        self.content = content
        
        assertionFailure("Don't allocate PagedView directly.  There is a possible retain cycle happening with @ViewBuilder content: @escaping (_ page: Int) -> Content.  Instead copy the TabView portion (be sure to include modifiers when copying) and paste into desired location of custom paged view.")
    }
    
    var body: some View {
     
        VStack(spacing: 0) {
            
            TabView(selection: $currentPage) {
                
                Group {
                    
                    if ApplicationLayout.shared.layoutDirection == .rightToLeft {
                        
                        ForEach((0 ..< numberOfPages).reversed(), id: \.self) { index in
                            
                            content(index)
                                .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
                                .tag(index)
                        }
                    }
                    else {
                        
                        ForEach(0 ..< numberOfPages, id: \.self) { index in
                            
                            content(index)
                                .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
                                .tag(index)
                        }
                    }
                }
            }
            .environment(\.layoutDirection, .leftToRight)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeOut, value: currentPage)
        }
    }
}
