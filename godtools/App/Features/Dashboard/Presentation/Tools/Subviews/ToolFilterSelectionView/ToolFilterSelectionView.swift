//
//  ToolFilterSelectionView.swift
//  godtools
//
//  Created by Rachael Skeath on 8/28/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct ToolFilterSelectionView: View {
    
    private static let ultraLightGrey = Color.getColorWithRGB(red: 246, green: 246, blue: 246, opacity: 1)
    
    @ObservedObject private var viewModel: ToolFilterSelectionViewModel
    @State private var searchText = ""
    
    init(viewModel: ToolFilterSelectionViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            ZStack {
                Rectangle()
                    .fill(ToolFilterSelectionView.ultraLightGrey)

                SearchBar(searchText: $searchText)
                    .padding(10)
            }
            .fixedSize(horizontal: false, vertical: true)
            
            List {
                ForEach(0..<5) { _ in
                    
                    ToolFilterSelectionRowView(viewModel: viewModel.getToolFilterSelectionRowViewModel())
                        .onTapGesture {
                            print("tap")
                        }
                }
            }
            .listStyle(.inset)
        }
        .navigationBarBackButtonHidden(true) // TODO: (GT-1794) This is a temp fix for iOS 16.  Will need to update to configure the navigation bar using SwiftUI instead of UIHostingController's. ~Levi
        .navigationTitle(viewModel.navTitle)
    }
}
