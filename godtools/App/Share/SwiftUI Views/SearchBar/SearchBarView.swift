//
//  SearchBarView.swift
//  godtools
//
//  Created by Rachael Skeath on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct SearchBarView: View {
    
    private static let ultraLightGrey = Color.getColorWithRGB(red: 246, green: 246, blue: 246, opacity: 1)
    
    @Binding private var searchText: String
    
    @ObservedObject private var viewModel: SearchBarViewModel
    
    init(viewModel: SearchBarViewModel, searchText: Binding<String>) {
        
        self.viewModel = viewModel
        self._searchText = searchText
    }
    
    var body: some View {
        
        ZStack {
            Rectangle()
                .fill(SearchBarView.ultraLightGrey)

            if #available(iOS 15.0, *) {
                
                SearchBar(viewModel: viewModel, searchText: $searchText)
                    .padding(10)
                
            } else {
                
                SearchBarLegacy(viewModel: viewModel, searchText: $searchText)
                    .padding(10)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}
