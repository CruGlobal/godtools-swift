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
    
    init(viewModel: SearchBarViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        ZStack {
            Rectangle()
                .fill(SearchBarView.ultraLightGrey)

            SearchBar(viewModel: viewModel)
                .padding(10)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}
