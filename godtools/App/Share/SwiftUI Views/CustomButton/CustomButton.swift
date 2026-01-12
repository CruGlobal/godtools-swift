//
//  CustomButton.swift
//  godtools
//
//  Created by Levi Eggert on 1/12/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import SwiftUI

struct CustomButton<HighlightContent: View, NonHighlightContent: View>: View {
    
    private let attributes: CustomButtonAttributes
    private let accessibilityId: String?
    private let highlightContent: () -> HighlightContent
    private let nonHighlightContent: () -> NonHighlightContent
    private let tappedClosure: (() -> Void)?
    
    init(
        attributes: CustomButtonAttributes,
        accessibilityId: String?,
        @ViewBuilder highlightContent: @escaping () -> HighlightContent,
        @ViewBuilder nonHighlightContent: @escaping () -> NonHighlightContent,
        tappedClosure: (() -> Void)?
    ) {
        
        self.attributes = attributes
        self.accessibilityId = accessibilityId
        self.highlightContent = highlightContent
        self.nonHighlightContent = nonHighlightContent
        self.tappedClosure = tappedClosure
    }
    
    var body: some View {
     
        ZStack(alignment: .center) {
            
            Button(action: {
                
                tappedClosure?()
            }) {
                
                ZStack(alignment: .center) {
                    
                    // create bounding area
                    Rectangle()
                        .fill(.clear)
                        .frame(width: attributes.width, height: attributes.height)
                    
                    highlightContent()
                }
            }
            .accessibilityIdentifier(accessibilityId ?? "")
            .background(attributes.color)
            .cornerRadius(attributes.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: attributes.cornerRadius)
                    .stroke(attributes.borderColor, lineWidth: attributes.borderWidth)
            )
            
            nonHighlightContent()
        }
    }
}
