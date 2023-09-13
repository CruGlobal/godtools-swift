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

struct PagedView<Content: View>: View {
    
    private let layoutDirection: LayoutDirection
    private let numberOfPages: Int
    private let content: (_ page: Int) -> Content
    
    @Binding private var currentPage: Int
    
    init(layoutDirection: LayoutDirection, numberOfPages: Int, currentPage: Binding<Int>, @ViewBuilder content: @escaping (_ page: Int) -> Content) {
        
        self.layoutDirection = layoutDirection
        self.numberOfPages = numberOfPages
        self._currentPage = currentPage
        self.content = content
    }
    
    var body: some View {
     
        VStack(spacing: 0) {
            
            TabView(selection: $currentPage) {
                
                Group {
                    
                    if layoutDirection == .rightToLeft {
                        
                        ForEach((0 ..< numberOfPages).reversed(), id: \.self) { index in
                            
                            content(index)
                                .environment(\.layoutDirection, layoutDirection)
                                .tag(index)
                        }
                    }
                    else {
                        
                        ForEach(0 ..< numberOfPages, id: \.self) { index in
                            
                            content(index)
                                .environment(\.layoutDirection, layoutDirection)
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

struct PagedView_Previews: PreviewProvider {
       
    @State private static var currentPage: Int = 1
    
    static var previews: some View {
                
        PagedView(layoutDirection: .leftToRight, numberOfPages: 5, currentPage: $currentPage) { page in
            
            ZStack(alignment: .center) {
                
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 100, height: 100)
                
                Text("Item: \(page)")
                    .foregroundColor(Color.black)
            }
            .frame(width: 100, height: 100)
        }
    }
}
