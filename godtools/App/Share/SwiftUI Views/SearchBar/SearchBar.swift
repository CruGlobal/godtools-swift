//
//  SearchBar.swift
//  godtools
//
//  Created by Rachael Skeath on 8/29/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

// adapted from https://www.appcoda.com/swiftui-search-bar/

struct SearchBar: View {
    
    @ObservedObject private var viewModel: SearchBarViewModel

    //@State private var searchText: String
    @State private var isEditing = false
    
    @Binding private var searchText: String
        
    init(viewModel: SearchBarViewModel, searchText: Binding<String>) {
        
        self.viewModel = viewModel
        //self.searchText = viewModel.searchTextPublisher.value
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
        .onChange(of: searchText) { newValue in
            self.searchText = searchText
        }

    }
}
