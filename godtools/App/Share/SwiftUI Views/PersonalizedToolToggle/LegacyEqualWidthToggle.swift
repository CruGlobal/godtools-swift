//
//  LegacyEqualWidthToggle.swift
//  godtools
//
//  Created by Rachael Skeath on 1/6/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import SwiftUI

@available(iOS, deprecated: 16.0, message: "Use EqualWidthHStack for iOS 16+")
struct LegacyEqualWidthToggle: View {

    @ObservedObject var viewModel: PersonalizedToolToggleViewModel
    
    @State private var segmentWidths: [String: CGFloat] = [:]

    private var maxWidth: CGFloat {
        segmentWidths.values.max() ?? 0
    }

    var body: some View {
        HStack(spacing: 0) {
            
            ForEach(viewModel.items.indices, id: \.self) { index in
                Button {
                    viewModel.selectedIndex = index
                } label: {
                    Text(viewModel.items[index])
                        .font(FontLibrary.sfProTextRegular.font(size: 12))
                        .foregroundColor(viewModel.selectedIndex == index ? .white : ColorPalette.gtBlue.color)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .frame(width: maxWidth > 0 ? maxWidth : nil)
                        .background(viewModel.selectedIndex == index ? ColorPalette.gtBlue.color : Color.clear)
                }
            }
        }
        .background(    // Hidden background to calculate appropriate segment widths
            HStack(spacing: 0) {
                ForEach(viewModel.items.indices, id: \.self) { index in
                    Text(viewModel.items[index])
                        .font(FontLibrary.sfProTextRegular.font(size: 12))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            GeometryReader { geometry in
                                Color.clear
                                    .onAppear {
                                        let key = viewModel.items[index]
                                        if segmentWidths[key] == nil {
                                            segmentWidths[key] = geometry.size.width
                                        }
                                    }
                            }
                        )
                }
            }
            .opacity(0)
        )
        .animation(.none, value: maxWidth)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(ColorPalette.gtBlue.color, lineWidth: 1)
        )
    }
}
