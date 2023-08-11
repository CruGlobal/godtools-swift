//
//  PageControl.swift
//  godtools
//
//  Created by Levi Eggert on 8/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct PageControl: View {
    
    private let backgroundColor: Color = Color.white
    
    let numberOfPages: Int
    let attributes: PageControlAttributesType
    
    @Binding var currentPage: Int
    
    init(numberOfPages: Int, attributes: PageControlAttributesType, currentPage: Binding<Int>) {
        
        self.numberOfPages = numberOfPages
        self.attributes = attributes
        self._currentPage = currentPage
    }
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 0) {
            
            Rectangle()
                .fill(Color.clear)
                .frame(width: 1, height: 10)
            
            HStack(alignment: .center, spacing: 0) {
                
                Rectangle()
                    .fill(backgroundColor)
                    .frame(height: attributes.circleSize)
                    .onTapGesture {
                        scrollToPreviousPage()
                    }
                
                ForEach((0 ..< numberOfPages), id: \.self) { index in
                    PageControlButton(page: index, attributes: attributes, currentPage: $currentPage)
                }
                
                Rectangle()
                    .fill(backgroundColor)
                    .frame(height: attributes.circleSize)
                    .onTapGesture {
                        scrollToNextPage()
                    }
                
            }
            .background(backgroundColor)
            .frame(maxWidth: .infinity)
            
            Rectangle()
                .fill(.clear)
                .frame(width: 1, height: 10)
        }
    }
    
    private func scrollToPreviousPage() {
        
        let previousPage: Int = currentPage - 1
        
        if previousPage >= 0 {
            currentPage = previousPage
        }
    }
    
    private func scrollToNextPage() {
        
        let nextPage: Int = currentPage + 1
        
        if nextPage < numberOfPages {
            currentPage = nextPage
        }
    }
}

struct PageControl_Previews: PreviewProvider {
    
    @State private static var currentPage: Int = 1
    
    static var previews: some View {
        
        let attributes = PageControlAttributes(deselectedColor: .gray, selectedColor: .blue, circleSize: 10, circleSpacing: 20)
        
        PageControl(numberOfPages: 3, attributes: attributes, currentPage: $currentPage)
    }
}
