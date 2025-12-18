//
//  PersonalizedToolToggle.swift
//  godtools
//
//  Created by Rachael Skeath on 12/11/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import SwiftUI

struct PersonalizedToolToggle: View {
    
    @ObservedObject var viewModel: PersonalizedToolToggleViewModel
    
    @State private var segmentWidth: CGFloat = 0

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
                        .frame(width: segmentWidth > 0 ? segmentWidth : nil)
                        .background(viewModel.selectedIndex == index ? ColorPalette.gtBlue.color : Color.clear)
                        .background(
                            GeometryReader { geometry in
                                Color.clear.onAppear {
                                    segmentWidth = max(segmentWidth, geometry.size.width)
                                }
                            }
                        )
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
