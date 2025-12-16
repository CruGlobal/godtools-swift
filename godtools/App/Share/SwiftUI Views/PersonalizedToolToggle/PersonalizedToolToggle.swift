//
//  PersonalizedToolToggle.swift
//  godtools
//
//  Created by Rachael Skeath on 12/11/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import SwiftUI
  
enum ViewMode: String, CaseIterable, Identifiable {
    case personalized = "Personalized"
    case allTools = "Al"

    var id: String { rawValue }
}

struct PersonalizedToolToggle: View {
    @State var selectedIndex: Int = 0
    @State private var segmentWidth: CGFloat = 0
    let items: [String]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items.indices, id: \.self) { index in
                Button {
                    selectedIndex = index
                } label: {
                    Text(items[index])
                        .font(FontLibrary.sfProTextRegular.font(size: 12))
                        .foregroundColor(selectedIndex == index ? .white : ColorPalette.gtBlue.color)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .frame(width: segmentWidth > 0 ? segmentWidth : nil)
                        .background(selectedIndex == index ? ColorPalette.gtBlue.color : Color.clear)
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
        .padding(1)
    }
}

#Preview {
    PersonalizedToolToggle(items: ViewMode.allCases.map { $0.rawValue })
}
