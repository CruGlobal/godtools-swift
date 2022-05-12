//
//  ItemsList.swift
//  godtools
//
//  Created by Levi Eggert on 5/12/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI
import UIKit

struct ItemsList<ListItem: Identifiable, ListItemView: View>: View {
    
    private let refreshList: (() -> Void)
    private let viewForItem: ((_ item: ListItem) -> ListItemView)
    private let itemTapped: ((_ item: ListItem) -> Void)
    
    let listTopPadding: CGFloat?
    let listRowInsets: EdgeInsets?
    let lazyVStackItemHorizontalPadding: CGFloat?
    let lazyVStackItemVerticalPadding: CGFloat?
    let lazyVStackTopPadding: CGFloat?
    
    var listItems: Binding<[ListItem]>
    
    init(hidesSeparatorInContainerTypes: [UIAppearanceContainer.Type], listItems: Binding<[ListItem]>, refreshList: @escaping (() -> Void), viewForItem: @escaping ((_ item: ListItem) -> ListItemView), itemTapped: @escaping ((_ item: ListItem) -> Void), listTopPadding: CGFloat?, listRowInsets: EdgeInsets?, lazyVStackItemHorizontalPadding: CGFloat?, lazyVStackItemVerticalPadding: CGFloat?, lazyVStackTopPadding: CGFloat?) {
        
        /*
         About removing the List separators:
         - iOS 15 - use the `listRowSeparator` view modifier to hide the separators
         - iOS 13 - list is built on UITableView, so `UITableView.appearance` works to set the separator style
         - iOS 14 - `appearance` no longer works, and the modifier doesn't yet exist.  Solution is the AllToolsListIOS14 view.
         */
        if #available(iOS 14.0, *) {
            
        }
        else if !hidesSeparatorInContainerTypes.isEmpty {
                        
            // TODO: - When we stop supporting iOS 13, get rid of this.
            UITableView.appearance(whenContainedInInstancesOf: hidesSeparatorInContainerTypes).separatorStyle = .none
        }
        
        self.listItems = listItems
        self.refreshList = refreshList
        self.viewForItem = viewForItem
        self.itemTapped = itemTapped
        self.listTopPadding = listTopPadding
        self.listRowInsets = listRowInsets
        self.lazyVStackItemHorizontalPadding = lazyVStackItemHorizontalPadding
        self.lazyVStackItemVerticalPadding = lazyVStackItemVerticalPadding
        self.lazyVStackTopPadding = lazyVStackTopPadding
    }
    
    var body: some View {
                
        if #available(iOS 15.0, *) {
            
            swiftUIList.refreshable {
                refreshList()
            }
        }
        else if #available(iOS 14.0, *) {
            swiftUILazyVList
        }
        else {
            swiftUIList
        }
    }
    
    @available(iOS 14.0, *)
    private var swiftUILazyVList: some View {
        
        return ScrollView {
            LazyVStack {
                
                ForEach(listItems) { item in
                    
                    let view = viewForItem(item.wrappedValue)
                    
                    view.onTapGesture {
                        itemTapped(item.wrappedValue)
                    }
                }
                .padding([.leading, .trailing], lazyVStackItemHorizontalPadding)
                .padding([.top, .bottom], lazyVStackItemVerticalPadding)
            }
            .padding(.top, lazyVStackTopPadding)
        }
    }
    
    private var swiftUIList: some View {
        
        return List(listItems) { item in
            
            let view = viewForItem(item.wrappedValue)
            
            view.onTapGesture {
                itemTapped(item.wrappedValue)
            }
            .listRowInsets(listRowInsets)
            .condition({ view in
                if #available(iOS 15.0, *) {
                    view.listRowSeparator(.hidden)
                }
                else {
                    view
                }
            })
        }
        .frame(maxWidth: .infinity)
        .edgesIgnoringSafeArea([.leading, .trailing])
        .listStyle(.plain)
        .padding(.top, listTopPadding)
    }
}
