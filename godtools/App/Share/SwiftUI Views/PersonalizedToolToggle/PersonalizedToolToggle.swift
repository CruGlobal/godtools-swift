//
//  PersonalizedToolToggle.swift
//  godtools
//
//  Created by Rachael Skeath on 12/11/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import SwiftUI

// TODO: - remove legacy layout when we bump to iOS 16
struct PersonalizedToolToggle: View {

    @ObservedObject var viewModel: PersonalizedToolToggleViewModel

    var body: some View {
        if #available(iOS 16.0, *) {
            customLayout
        } else {
            legacyLayout
        }
    }

    @available(iOS 16.0, *)
    private var customLayout: some View {
        EqualWidthHStack(spacing: 0) {
            ForEach(viewModel.items.indices, id: \.self) { index in
                Button {
                    viewModel.selectedIndex = index
                } label: {
                    Text(viewModel.items[index])
                        .font(FontLibrary.sfProTextRegular.font(size: 12))
                        .foregroundColor(viewModel.selectedIndex == index ? .white : ColorPalette.gtBlue.color)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(viewModel.selectedIndex == index ? ColorPalette.gtBlue.color : Color.clear)
                }
            }
        }
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(ColorPalette.gtBlue.color, lineWidth: 1)
        )
    }

    @available(iOS, deprecated: 16.0, message: "Use customLayout for iOS 16+")
    private var legacyLayout: some View {
        LegacyEqualWidthToggle(viewModel: viewModel)
    }
}
