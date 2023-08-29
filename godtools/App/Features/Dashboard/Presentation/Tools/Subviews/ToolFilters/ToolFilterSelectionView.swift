//
//  ToolFilterSelectionView.swift
//  godtools
//
//  Created by Rachael Skeath on 8/28/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct ToolFilterSelectionView: View {
    
    
    private static let lightGrey = Color.getColorWithRGB(red: 151, green: 151, blue: 151, opacity: 1)
    private static let ultraLightGrey = Color.getColorWithRGB(red: 246, green: 246, blue: 246, opacity: 1)
    
    @State private var searchText = ""
    
    var body: some View {
        
        VStack {
            
            ZStack {
                Rectangle()
                    .fill(ToolFilterSelectionView.ultraLightGrey)

                SearchBar(searchText: $searchText)
                    .padding(10)
            }
            .fixedSize(horizontal: false, vertical: true)
            
            List {
                ForEach(0..<5) { _ in
                    
                    cell()
                }
            }
            .listStyle(.inset)
        }
    }
    
    @ViewBuilder func cell() -> some View {
        
        VStack(alignment: .leading, spacing: 10) {
            
            HStack(spacing: 9.5) {
                
                Text("Any language")
                    .font(FontLibrary.sfProTextRegular.font(size: 15))
                    .foregroundColor(ColorPalette.gtGrey.color)
                
                Text("Translation")
                    .font(FontLibrary.sfProTextRegular.font(size: 15))
                    .foregroundColor(ToolFilterSelectionView.lightGrey)
            }
            
            Text("All Tools available")
                .font(FontLibrary.sfProTextRegular.font(size: 12))
                .foregroundColor(ToolFilterSelectionView.lightGrey)
        }
    }
}

struct ToolFilterSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ToolFilterSelectionView()
    }
}
