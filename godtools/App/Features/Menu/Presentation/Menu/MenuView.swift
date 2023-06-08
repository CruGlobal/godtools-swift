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
                        sectionTitle: viewModel.getStartedSectionTitle,
                        menuItems: [
                            MenuItemView(imageAssetName: "school", title: viewModel.tutorialOptionTitle, tappedClosure: {
                                
                            }),
                            MenuItemView(imageAssetName: "translate", title: viewModel.languageSettingsOptionTitle, tappedClosure: {

                            })
                        ]
                    )
                    
                    MenuSectionView(
                        sectionTitle: viewModel.accountSectionTitle,
                        menuItems: [
                            MenuItemView(imageAssetName: "login", title: viewModel.loginOptionTitle, tappedClosure: {
                                
                            }),
                            MenuItemView(imageAssetName: "person_add", title: viewModel.createAccountOptionTitle, tappedClosure: {
                                
                            })
                        ]
                    )
                    
                    MenuSectionView(
                        sectionTitle: viewModel.supportSectionTitle, menuItems: [
                            MenuItemView(imageAssetName: "send", title: viewModel.sendFeedbackOptionTitle, tappedClosure: {
                                
                            }),
                            MenuItemView(imageAssetName: "bug_report", title: viewModel.reportABugOptionTitle, tappedClosure: {
                                
                            }),
                            MenuItemView(imageAssetName: "live_help", title: viewModel.askAQuestionOptionTitle, tappedClosure: {
                                
                            })
                        ]
                    )
                    
                    MenuSectionView(
                        sectionTitle: viewModel.shareSectionTitle, menuItems: [
                            MenuItemView(imageAssetName: "rate_review", title: viewModel.leaveAReviewOptionTitle, tappedClosure: {
                                
                            }),
                            MenuItemView(imageAssetName: "description", title: viewModel.shareAStoryWithUsOptionTitle, tappedClosure: {
                                
                            }),
                            MenuItemView(imageAssetName: "share", title: viewModel.shareGodToolsOptionTitle, tappedClosure: {
                                
                            })
                        ]
                    )
                    
                    MenuSectionView(
                        sectionTitle: viewModel.aboutSectionTitle, menuItems: [
                            MenuItemView(imageAssetName: "format_list_bulleted", title: viewModel.termsOfUseOptionTitle, tappedClosure: {
                                
                            }),
                            MenuItemView(imageAssetName: "policy", title: viewModel.privacyPolicyOptionTitle, tappedClosure: {
                                
                            }),
                            MenuItemView(imageAssetName: "copyright", title: viewModel.copyrightInfoOptionTitle, tappedClosure: {
                                
                            })
                        ]
                    )
                    
                    MenuSectionView(
                        sectionTitle: viewModel.versionSectionTitle, menuItems: []
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
