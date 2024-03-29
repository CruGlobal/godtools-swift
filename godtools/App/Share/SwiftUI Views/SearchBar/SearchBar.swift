//
//  SearchBar.swift
//  godtools
//
//  Created by Rachael Skeath on 8/29/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

// adapted from https://www.appcoda.com/swiftui-search-bar/

@available(iOS 15.0, *)
struct SearchBar: View {
    
    @ObservedObject private var viewModel: SearchBarViewModel

    @Binding private var searchText: String
    @FocusState private var textFieldIsFocused: Bool
    
    init(viewModel: SearchBarViewModel, searchText: Binding<String>) {
        
        self.viewModel = viewModel
        self._searchText = searchText
    }
        
    var body: some View {
        HStack {
         
            TextField("", text: $searchText)
            .padding(7)
            .padding(.horizontal, 27)
            .background(Color.white)
            .cornerRadius(6)
            .focused($textFieldIsFocused)
            .onTapGesture {
                textFieldIsFocused = true
            }
            .overlay(
                HStack {
                    
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 10)
                    
                    if textFieldIsFocused {
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
            
            if textFieldIsFocused {
                Button(action: {
                    self.searchText = ""
                    self.textFieldIsFocused = false

                }) {
                    Text(viewModel.cancelText)
                }
            }
        }
    }
}
