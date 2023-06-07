//
//  MenuView.swift
//  godtools
//
//  Created by Aaron Laib on 6/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct MenuView: View {
   
    private let horizontalPadding: CGFloat = 24
    
    @ObservedObject private var viewModel: MenuViewModel
    
    init(viewModel: MenuViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            ScrollView{
                VStack(alignment: .leading, spacing: 0) {
                    
                    MenuSectionView(
                        sectionTitle: "Get Started",
                        menuItems: [
                            MenuItemData(iconName: "school", title: "Tutorial"),
                            MenuItemData(iconName: "translate", title: "Language settings")
                        ]
                    )
                    
                    MenuSectionView(
                        sectionTitle: "Account",
                        menuItems: [
                            MenuItemData(iconName: "login", title: "Login / Activity"),
                            MenuItemData(iconName: "person_add", title: "Create account / Logout")
                        ]
                    )
                    
                    MenuSectionView(
                        sectionTitle: "Support", menuItems: [
                            MenuItemData(iconName: "send", title: "Send feedback"),
                            MenuItemData(iconName: "bug_report", title: "Report a bug"),
                            MenuItemData(iconName: "live_help", title: "Ask a question")
                        ]
                    )
                    
                    MenuSectionView(
                        sectionTitle: "Share", menuItems: [
                            MenuItemData(iconName: "rate_review", title: "Leave a review"),
                            MenuItemData(iconName: "description", title: "Share a story with us"),
                            MenuItemData(iconName: "share", title: "Share GodTools")
                        ]
                    )
                    
                    MenuSectionView(
                        sectionTitle: "About", menuItems: [
                            MenuItemData(iconName: "format_list_bulleted", title: "Terms of use"),
                            MenuItemData(iconName: "policy", title: "Privacy policy"),
                            MenuItemData(iconName: "copyright", title: "Copyright info")
                        ]
                    )
                    
                    MenuSectionView(
                        sectionTitle: "Version", menuItems: []
                    )
                    
                }
                .padding(EdgeInsets(top: 0, leading: horizontalPadding, bottom: 0, trailing: horizontalPadding))
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(viewModel.navTitle)
        .background(Color.white)
    }
}
