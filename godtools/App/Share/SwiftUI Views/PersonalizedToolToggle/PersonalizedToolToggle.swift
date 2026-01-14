//
//  PersonalizedToolToggle.swift
//  godtools
//
//  Created by Rachael Skeath on 12/11/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import SwiftUI

struct PersonalizedToolToggle: View {

    static let height: CGFloat = 38
    
    private let items: [String]
    private let font: Font = FontLibrary.sfProTextRegular.font(size: 14)
    private let borderWidth: CGFloat = 1
    
    @Binding private var selectedIndex: Int

    init(selectedIndex: Binding<Int>, items: [String]) {
        
        self._selectedIndex = selectedIndex
        self.items = items
    }

    var body: some View {

        EqualWidthHStack(spacing: 0) {

            ForEach(items.indices, id: \.self) { index in

                Button {
                    selectedIndex = index
                } label: {

                    Text(items[index])
                        .font(font)
                        .foregroundColor(selectedIndex == index ? .white : ColorPalette.gtBlue.color)
                        .frame(maxWidth: .infinity)
                        .frame(height: Self.height - (borderWidth * 1))
                        .padding(.horizontal, 16)
                        .background(selectedIndex == index ? ColorPalette.gtBlue.color : Color.clear)
                }
            }
        }
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(ColorPalette.gtBlue.color, lineWidth: borderWidth)
        )
    }
}
