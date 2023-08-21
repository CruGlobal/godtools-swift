//
//  TwoRowHStack.swift
//  godtools
//
//  Created by Rachael Skeath on 5/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct TwoRowHStack<Content: View>: View {
    
    private let itemCount: Int
    private let numberOfColumns: Int
    private let spacing: CGFloat
    private let content: (Int) -> Content

    init(itemCount: Int, spacing: CGFloat, @ViewBuilder content:@escaping (Int) -> Content) {
        
        self.itemCount = itemCount
        self.numberOfColumns = Int(ceil(Double(itemCount) / 2))
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        
        LazyHStack(alignment: .center, spacing: spacing) {
                        
            ForEach(0 ..< numberOfColumns, id: \.self) { columnNumber in
                
                let topItemIndex = columnNumber * 2
                let bottomItemIndex = topItemIndex + 1
                
                VStack(alignment: .center, spacing: spacing) {
                    
                    if topItemIndex < itemCount {
                        content(topItemIndex)
                    }
                    else {
                        Spacer()
                    }
                    
                    if bottomItemIndex < itemCount {
                        content(bottomItemIndex)
                    }
                    else {
                        Spacer()
                    }
                }
            }
        }
    }
}

struct TwoRowHGrid_Previews: PreviewProvider {
    static var previews: some View {
        TwoRowHStack(itemCount: 8, spacing: 10) { itemIndex in
            ZStack {
                Color.blue
                Text("\(itemIndex)")
            }
            .frame(width: 100, height: 100)
        }
        .previewLayout(.sizeThatFits)
    }
}
