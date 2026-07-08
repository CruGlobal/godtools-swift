//
//  PersonalizedToolToggle.swift
//  godtools
//
//  Created by Rachael Skeath on 12/11/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import SwiftUI

struct PersonalizedToolToggle: View {

    private static let contentHorizontalPadding: CGFloat = 50
    private static let cornerRadius: CGFloat = 20
    private static let borderWidth: CGFloat = 1
    
    static let height: CGFloat = 38
    
    private let geometry: GeometryProxy
    private let toggleOptions: [PersonalizationToggleOption]
    private let font: Font = FontLibrary.sfProTextRegular.font(size: 14)
    
    @Binding private var selectedToggle: PersonalizationToggleOptionValue

    init(geometry: GeometryProxy, selectedToggle: Binding<PersonalizationToggleOptionValue>, toggleOptions: [PersonalizationToggleOption]) {

        self.geometry = geometry
        self._selectedToggle = selectedToggle
        self.toggleOptions = toggleOptions
    }

    var body: some View {

        EqualWidthHStack(spacing: 0, maxContainerWidth: geometry.size.width - (Self.contentHorizontalPadding * 2)) {

            ForEach(toggleOptions.indices, id: \.self) { index in

                let toggleOption: PersonalizationToggleOption = toggleOptions[index]
                
                Button {
                    selectedToggle = toggleOption.selection
                } label: {

                    Text(toggleOption.title)
                        .font(font)
                        .foregroundColor(selectedToggle == toggleOption.selection ? .white : ColorPalette.gtBlue.color)
                        .frame(maxWidth: .infinity)
                        .frame(height: Self.height)
                        .padding(.horizontal, 16)
                        .background(selectedToggle == toggleOption.selection ? ColorPalette.gtBlue.color : Color.clear)
                }
                .accessibilityIdentifier(toggleOption.buttonAccessibility.id)
            }
        }
        .cornerRadius(Self.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Self.cornerRadius)
                .stroke(ColorPalette.gtBlue.color, lineWidth: Self.borderWidth)
        )
    }
}
