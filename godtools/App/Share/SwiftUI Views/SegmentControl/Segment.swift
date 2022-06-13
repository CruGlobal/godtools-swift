//
//  Segment.swift
//  godtools
//
//  Created by Levi Eggert on 6/11/22.
//

import SwiftUI

struct Segment: View {
    
    private let selectedTextColor: Color = ColorPalette.primaryTextColor.color
    private let deselectedTextColor: Color = Color(.sRGB, red: 190 / 255, green: 190 / 255, blue: 190 / 255, opacity: 1)
    private let underlineColor: Color = ColorPalette.gtBlue.color
    private let underlineHeight: CGFloat = 3
    
    @State private var textWidth: CGFloat = 0
    
    let text: String
    let index: Int
    @Binding var selectedIndex: Int?
    let tappedClosure: ((_ index: Int) -> Void)
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 4) {
            Text(text)
                .font(FontLibrary.sfProTextSemibold.font(size: 19))
                .foregroundColor(index == selectedIndex ? selectedTextColor : deselectedTextColor)
                .background(ViewGeometry())
                .onPreferenceChange(ViewSizePreferenceKey.self) { size in
                    textWidth = size.width
                }
                .onTapGesture {
                    self.selectedIndex = index
                    tappedClosure(index)
                }
            Rectangle()
                .fill(index == selectedIndex ? underlineColor : .clear)
                .frame(width: textWidth, height: underlineHeight, alignment: .leading)
        }
    }
}
