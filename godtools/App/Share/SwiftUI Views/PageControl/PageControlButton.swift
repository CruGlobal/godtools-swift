//
//  PageControlButton.swift
//  godtools
//
//  Created by Levi Eggert on 8/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct PageControlButton: View {
    
    let page: Int
    let attributes: PageControlAttributesType
    
    @Binding var currentPage: Int
    
    init(page: Int, attributes: PageControlAttributesType, currentPage: Binding<Int>) {
        
        self.page = page
        self.attributes = attributes
        self._currentPage = currentPage
    }
    
    var body: some View {
        
        let buttonWidth: CGFloat = attributes.circleSize + attributes.circleSpacing
        let buttonHeight: CGFloat = attributes.circleSize
        
        Button(action: {
                        
            currentPage = page
        }) {
            
            ZStack(alignment: .center) {
             
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: buttonWidth, height: buttonHeight)
                
                Circle()
                    .fill(currentPage == page ? attributes.selectedColor : attributes.deselectedColor)
                    .frame(width: attributes.circleSize, height: attributes.circleSize)
            }
            
        }
        .frame(width: buttonWidth, height: buttonHeight, alignment: .center)
    }
}

struct PageControlButton_Previews: PreviewProvider {
    
    @State private static var currentPage: Int = 1
    
    static var previews: some View {
        
        let attributes = PageControlAttributes(deselectedColor: .gray, selectedColor: .blue, circleSize: 10, circleSpacing: 20)
        
        PageControlButton(page: 0, attributes: attributes, currentPage: $currentPage)
    }
}
