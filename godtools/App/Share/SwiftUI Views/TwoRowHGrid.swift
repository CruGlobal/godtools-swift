//
//  TwoRowHGrid.swift
//  godtools
//
//  Created by Rachael Skeath on 5/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

// TODO: (DEPRECATED) Once we stop supporting iOS 13, we can use a LazyHGrid instead
@available(*, deprecated)
struct TwoRowHGrid<Content: View>: View {
    let itemCount: Int
    let spacing: CGFloat
    let content: (Int) -> Content

    init(itemCount: Int, spacing: CGFloat, @ViewBuilder content:@escaping (Int) -> Content) {
        self.itemCount = itemCount
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        HStack(spacing: spacing) {
            
            let numColumns = itemCount / 2
            
            ForEach(0..<numColumns, id: \.self) { columnNumber in
                
                let topItemIndex = columnNumber * 2
                let bottomItemIndex = topItemIndex + 1
                
                VStack(spacing: spacing) {
                    content(topItemIndex)
                    content(bottomItemIndex)
                }
            }
        }
    }
}

struct TwoRowHGrid_Previews: PreviewProvider {
    static var previews: some View {
        TwoRowHGrid(itemCount: 8, spacing: 10) { itemIndex in
            ZStack {
                Color.blue
                Text("\(itemIndex)")
            }
            .frame(width: 100, height: 100)
        }
        .previewLayout(.sizeThatFits)
    }
}
