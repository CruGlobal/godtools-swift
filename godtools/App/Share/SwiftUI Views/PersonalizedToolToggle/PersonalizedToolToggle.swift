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
    
    private let toggleOptions: [PersonalizationToggleOption]
    private let font: Font = FontLibrary.sfProTextRegular.font(size: 14)
    private let borderWidth: CGFloat = 1
    
    @Binding private var selectedToggle: PersonalizationToggleOptionValue

    init(selectedToggle: Binding<PersonalizationToggleOptionValue>, toggleOptions: [PersonalizationToggleOption]) {

        self._selectedToggle = selectedToggle
        self.toggleOptions = toggleOptions
    }

    var body: some View {

        EqualWidthHStack(spacing: 0) {

            ForEach(toggleOptions.indices, id: \.self) { index in

                Button {
                    selectedToggle = toggleOptions[index].selection
                } label: {

                    Text(toggleOptions[index].title)
                        .font(font)
                        .foregroundColor(selectedToggle == toggleOptions[index].selection ? .white : ColorPalette.gtBlue.color)
                        .frame(maxWidth: .infinity)
                        .frame(height: Self.height - (borderWidth * 1))
                        .padding(.horizontal, 16)
                        .background(selectedToggle == toggleOptions[index].selection ? ColorPalette.gtBlue.color : Color.clear)
                }
            }
        }
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(ColorPalette.gtBlue.color, lineWidth: 1)
        )
    }
}
