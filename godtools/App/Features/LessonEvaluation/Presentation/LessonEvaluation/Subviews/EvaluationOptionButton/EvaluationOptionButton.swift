//
//  EvaluationOptionButton.swift
//  godtools
//
//  Created by Levi Eggert on 10/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct EvaluationOptionButton: View {
    
    private let title: String
    private let titleFont: Font = FontLibrary.sfProTextRegular.font(size: 17)
    private let width: CGFloat = 166
    private let height: CGFloat = 50
    private let cornerRadius: CGFloat = 28
    private let action: () -> Void
    
    @Binding private var isSelected: Bool
    
    init(title: String, isSelected: Binding<Bool>, action: @escaping () -> Void) {
        
        self.title = title
        self._isSelected = isSelected
        self.action = action
    }
    
    private static func getDefaultFont(fontSize: CGFloat) -> Font {
        return FontLibrary.sfProTextRegular.font(size: fontSize)
    }
    
    var body: some View {
        
        Button(action: {
            action()
        }) {
            
            ZStack(alignment: .center) {
                
                Rectangle()
                    .fill(.clear)
                    .frame(width: width, height: height)
                    .cornerRadius(cornerRadius)
                
                Text(title)
                    .font(titleFont)
                    .foregroundColor(isSelected ? .white : ColorPalette.gtBlue.color)
                    .padding()
            }
        }
        .frame(width: width, height: height, alignment: .center)
        .background(isSelected ? ColorPalette.gtBlue.color : .white)
        .cornerRadius(cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(ColorPalette.gtBlue.color, lineWidth: 1)
        )
    }
}
