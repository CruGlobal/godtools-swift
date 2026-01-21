//
//  LocalizationSettingsView.swift
//  godtools
//
//  Created by Rachael Skeath on 11/19/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import SwiftUI

struct LocalizationSettingsView: View {
    
    private static let lightBlue = Color.getColorWithRGB(red: 223, green: 240, blue: 249, opacity: 1)
    
    @ObservedObject private var viewModel: LocalizationSettingsViewModel
    
    init(viewModel: LocalizationSettingsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            AccessibilityScreenElementView(screenAccessibility: .localizationSettings)
                        
            SearchBarView(viewModel: viewModel.getSearchBarViewModel(), searchText: $viewModel.searchText)
            
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(LocalizationSettingsView.lightBlue)
                
                VStack(alignment: .leading) {
                    Text(viewModel.strings.localizationHeaderTitle)
                        .font(FontLibrary.sfProTextSemibold.font(size: 16))
                    Text(viewModel.strings.localizationHeaderDescription)
                        .font(FontLibrary.sfProTextRegular.font(size: 12))
                }
                .multilineTextAlignment(.leading)
                .padding(25)
            }
            .fixedSize(horizontal: false, vertical: true)
            
            List {
                ForEach(viewModel.countrySearchResults) { country in

                    LocalizationSettingsCountryItemView(
                        country: country,
                        isSelected: country.isoRegionCode == viewModel.selectedCountryIsoRegionCode
                    ) {
                        
                        viewModel.countryTapped(country: country)
                    }
                }
            }
            .listStyle(.inset)
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(viewModel.strings.navTitle)
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
        
    }
}
