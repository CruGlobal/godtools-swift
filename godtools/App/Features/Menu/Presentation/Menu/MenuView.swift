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
            
            ScrollView(.vertical, showsIndicators: false) {
               
                VStack(alignment: .leading, spacing: 0) {
                    
                    MenuSectionView(
                        sectionTitle: viewModel.getStartedSectionTitle,
                        menuItemsViewBuilder: {
                            
                            MenuItemView(imageAssetName: ImageCatalog.school.name, title: viewModel.tutorialOptionTitle, tappedClosure: {
                                
                                viewModel.tutorialTapped()
                            })
                            
                            MenuItemView(imageAssetName: ImageCatalog.translate.name, title: viewModel.languageSettingsOptionTitle, tappedClosure: {
                                
                                viewModel.languageSettingsTapped()
                            })
                        }
                    )
   
                    if viewModel.accountSectionVisibility != .hidden {
                        
                        MenuSectionView(
                            sectionTitle: viewModel.accountSectionTitle,
                            menuItemsViewBuilder: {
                                
                                if viewModel.accountSectionVisibility == .visibleLoggedOut {
                                    
                                    MenuItemView(imageAssetName: ImageCatalog.login.name, title: viewModel.loginOptionTitle, tappedClosure: {
                                        
                                        viewModel.loginTapped()
                                    })
                                    
                                    MenuItemView(imageAssetName: ImageCatalog.personAdd.name, title: viewModel.createAccountOptionTitle, tappedClosure: {
                                        
                                        viewModel.createAccountTapped()
                                    })
                                }
                                else if viewModel.accountSectionVisibility == .visibleLoggedIn {
                                    
                                    MenuItemView(imageAssetName: ImageCatalog.person.name, title: viewModel.activityOptionTitle, tappedClosure: {
                                        
                                        viewModel.activityTapped()
                                    })
                                    
                                    MenuItemView(imageAssetName: ImageCatalog.logout.name, title: viewModel.logoutOptionTitle, tappedClosure: {
                                        
                                        viewModel.logoutTapped()
                                    })
                                    
                                    MenuItemView(imageAssetName: ImageCatalog.personRemove.name, title: viewModel.deleteAccountOptionTitle, tappedClosure: {
                                        
                                        viewModel.deleteAccountTapped()
                                    })
                                }
                            }
                        )
                    }
                    
                    MenuSectionView(
                        sectionTitle: viewModel.supportSectionTitle,
                        menuItemsViewBuilder: {
                            
                            MenuItemView(imageAssetName: ImageCatalog.send.name, title: viewModel.sendFeedbackOptionTitle, tappedClosure: {
                                
                                viewModel.sendFeedbackTapped()
                            })
                            
                            MenuItemView(imageAssetName: ImageCatalog.bugReport.name, title: viewModel.reportABugOptionTitle, tappedClosure: {
                                
                                viewModel.reportABugTapped()
                            })
                            
                            MenuItemView(imageAssetName: ImageCatalog.liveHelp.name, title: viewModel.askAQuestionOptionTitle, tappedClosure: {
                                
                                viewModel.askAQuestionTapped()
                            })
                        }
                    )
                    
                    MenuSectionView(
                        sectionTitle: viewModel.shareSectionTitle,
                        menuItemsViewBuilder: {
                            
                            MenuItemView(imageAssetName: ImageCatalog.rateReview.name, title: viewModel.leaveAReviewOptionTitle, tappedClosure: {
                                
                                viewModel.leaveAReviewTapped()
                            })
                            
                            MenuItemView(imageAssetName: ImageCatalog.description.name, title: viewModel.shareAStoryWithUsOptionTitle, tappedClosure: {
                                
                                viewModel.shareAStoryWithUsTapped()
                            })
                            
                            MenuItemView(imageAssetName: ImageCatalog.share.name, title: viewModel.shareGodToolsOptionTitle, tappedClosure: {
                                
                                viewModel.shareGodToolsTapped()
                            })
                        }
                    )
                    
                    MenuSectionView(
                        sectionTitle: viewModel.aboutSectionTitle,
                        menuItemsViewBuilder: {
                            
                            MenuItemView(imageAssetName: ImageCatalog.formatListBulleted.name, title: viewModel.termsOfUseOptionTitle, tappedClosure: {
                                
                                viewModel.termsOfUseTapped()
                            })
                            
                            MenuItemView(imageAssetName: ImageCatalog.policy.name, title: viewModel.privacyPolicyOptionTitle, tappedClosure: {
                                
                                viewModel.privacyPolicyTapped()
                            })
                            
                            MenuItemView(imageAssetName: ImageCatalog.copyright.name, title: viewModel.copyrightInfoOptionTitle, tappedClosure: {
                                
                                viewModel.copyrightInfoTapped()
                            })
                        }
                    )
                    
                    MenuSectionView(
                        sectionTitle: viewModel.versionSectionTitle,
                        overrideHidesSeparator: true,
                        menuItemsViewBuilder: {
                            
                            MenuItemView(imageAssetName: nil, title: viewModel.appVersion, tappedClosure: nil)
                        }
                    )
                }
                .padding(EdgeInsets(top: 0, leading: MenuView.contentHorizontalPadding, bottom: 0, trailing: MenuView.contentHorizontalPadding))
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(viewModel.navTitle)
        .background(Color.white)
        .onAppear {
            viewModel.pageViewed()
        }
    }
}
