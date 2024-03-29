//
//  SearchBarLegacy.swift
//  godtools
//
//  Created by Rachael Skeath on 3/28/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import SwiftUI

// Replaced by SearchBar for iOS 15+
@available(*, deprecated)
struct SearchBarLegacy: View {
    
    @ObservedObject private var viewModel: SearchBarViewModel

    @State private var isEditing = false
    @Binding private var searchText: String
    
    init(viewModel: SearchBarViewModel, searchText: Binding<String>) {
        
        self.viewModel = viewModel
        self._searchText = searchText
    }
        
    var body: some View {
        HStack {
         
            TextField("", text: $searchText, onEditingChanged: { _ in
                self.isEditing = true
            }, onCommit: {
                DispatchQueue.main.async {
                    
                    self.isEditing = false
                }
            })
            .padding(7)
            .padding(.horizontal, 27)
            .background(Color.white)
            .cornerRadius(6)
            .overlay(
                HStack {
                    
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 10)
                    
                    if isEditing {
                        Button(action: {
                            self.searchText = ""
                            
                        }) {
                            Image(systemName: "multiply.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 10)
                        }
                    }
                }
            )
            
            if isEditing {
                Button(action: {
                    DispatchQueue.main.async {
                        self.isEditing = false
                        self.searchText = ""
                    }
                    
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }) {
                    Text(viewModel.cancelText)
                }
            }
        }
    }
}

