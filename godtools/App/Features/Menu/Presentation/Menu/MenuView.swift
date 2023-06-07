//
//  MenuView.swift
//  godtools
//
//  Created by Aaron Laib on 6/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct MenuView: View {
   
    static let contentHorizontalPadding: CGFloat = 22
    static let sectionTitleVerticalSpacing: CGFloat = 24
    static let itemSpacing: CGFloat = 24
    
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
                            MenuItemView(imageAssetName: "school", title: "Tutorial", tappedClosure: {
                                
                            }),
                            MenuItemView(imageAssetName: "translate", title: "Language settings", tappedClosure: {

                            })
                        ]
                    )
                    
                    MenuSectionView(
                        sectionTitle: "Account",
                        menuItems: [
                            MenuItemView(imageAssetName: "login", title: "Login / Activity", tappedClosure: {
                                
                            }),
                            MenuItemView(imageAssetName: "person_add", title: "Create account / Logout", tappedClosure: {
                                
                            })
                        ]
                    )
                    
                    MenuSectionView(
                        sectionTitle: "Support", menuItems: [
                            MenuItemView(imageAssetName: "send", title: "Send feedback", tappedClosure: {
                                
                            }),
                            MenuItemView(imageAssetName: "bug_report", title: "Report a bug", tappedClosure: {
                                
                            }),
                            MenuItemView(imageAssetName: "live_help", title: "Ask a question", tappedClosure: {
                                
                            })
                        ]
                    )
                    
                    MenuSectionView(
                        sectionTitle: "Share", menuItems: [
                            MenuItemView(imageAssetName: "rate_review", title: "Leave a review", tappedClosure: {
                                
                            }),
                            MenuItemView(imageAssetName: "description", title: "Share a story with us", tappedClosure: {
                                
                            }),
                            MenuItemView(imageAssetName: "share", title: "Share GodTools", tappedClosure: {
                                
                            })
                        ]
                    )
                    
                    MenuSectionView(
                        sectionTitle: "About", menuItems: [
                            MenuItemView(imageAssetName: "format_list_bulleted", title: "Terms of use", tappedClosure: {
                                
                            }),
                            MenuItemView(imageAssetName: "policy", title: "Privacy policy", tappedClosure: {
                                
                            }),
                            MenuItemView(imageAssetName: "copyright", title: "Copyright info", tappedClosure: {
                                
                            })
                        ]
                    )
                    
                    MenuSectionView(
                        sectionTitle: "Version", menuItems: []
                    )
                    
                }
                .padding(EdgeInsets(top: 0, leading: MenuView.contentHorizontalPadding, bottom: 0, trailing: MenuView.contentHorizontalPadding))
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(viewModel.navTitle)
        .background(Color.white)
    }
}
