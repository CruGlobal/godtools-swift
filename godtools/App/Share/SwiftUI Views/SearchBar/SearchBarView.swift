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
    
    private let strings: SearchBarStringsDomainModel
    
    @Binding private var searchText: String
        
    init(searchText: Binding<String>, strings: SearchBarStringsDomainModel) {
        
        self._searchText = searchText
        self.strings = strings
    }
    
    var body: some View {
        
        ZStack {
            Rectangle()
                .fill(SearchBarView.ultraLightGrey)

            SearchBar(searchText: $searchText, strings: strings)
                .padding(10)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}
