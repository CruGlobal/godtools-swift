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
    
    @Binding var searchText: String
    @State private var isEditing = false
    
    var body: some View {
        HStack {
         
                    TextField("", text: $searchText)
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
                        .onTapGesture {
                            self.isEditing = true
                        }
         
                    if isEditing {
                        Button(action: {
                            self.isEditing = false
                            self.searchText = ""
         
                        }) {
                            Text("Cancel")
                        }
                    }
                }
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(searchText: .constant(""))
    }
}
