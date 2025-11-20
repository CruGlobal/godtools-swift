//
//  PersonalizedToolsCountrySelectionView.swift
//  godtools
//
//  Created by Rachael Skeath on 11/19/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import SwiftUI

struct PersonalizedToolsCountrySelectionView: View {
    
    @ObservedObject private var viewModel: PersonalizedToolsCountrySelectionViewModel
    
    init(viewModel: PersonalizedToolsCountrySelectionViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            AccessibilityScreenElementView(screenAccessibility: .personalizedToolCountrySelection)
                        
            SearchBarView(viewModel: viewModel.getSearchBarViewModel(), searchText: $viewModel.searchText)
            
            List {
                ForEach(viewModel.countrySearchResults) { country in
                    
                    PersonalizedToolsCountryItemView(country: country) {
                        
                        viewModel.countryTapped(country: country)
                    }
                }
            }
            .listStyle(.inset)
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(viewModel.navTitle)
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
        
    }
}
