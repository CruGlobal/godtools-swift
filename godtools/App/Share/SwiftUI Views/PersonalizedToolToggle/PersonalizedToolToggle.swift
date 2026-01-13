//
//  PersonalizedToolToggle.swift
//  godtools
//
//  Created by Rachael Skeath on 12/11/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import SwiftUI

struct PersonalizedToolToggle: View {

    @Binding private var selectedToggle: PersonalizationToggleOptionValue
    private let toggleOptions: [PersonalizationToggleOption]

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
                        .font(FontLibrary.sfProTextRegular.font(size: 12))
                        .foregroundColor(selectedToggle == toggleOptions[index].selection ? .white : ColorPalette.gtBlue.color)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
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
