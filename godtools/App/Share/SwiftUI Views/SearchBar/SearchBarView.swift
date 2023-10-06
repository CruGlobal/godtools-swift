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
    
    @ObservedObject private var viewModel: SearchBarViewModel
        
    @Binding private var searchText: String
    
    init(viewModel: SearchBarViewModel, searchText: Binding<String>) {
        
        self.viewModel = viewModel
        self._searchText = searchText
    }
    
    var body: some View {
        
        ZStack {
            Rectangle()
                .fill(SearchBarView.ultraLightGrey)

            SearchBar(viewModel: viewModel, searchText: $searchText)
                .padding(10)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}
