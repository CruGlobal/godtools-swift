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
            
            AccessibilityScreenElementView(screenAccessibility: .menu)
            
            ScrollView(.vertical, showsIndicators: false) {
               
                VStack(alignment: .leading, spacing: 0) {
                    
                    MenuSectionView(
                        sectionTitle: viewModel.getStartedSectionTitle,
                        menuItemsViewBuilder: {
                            
                            if viewModel.showsTutorialOption {
                                
                                MenuItemView(imageAssetName: ImageCatalog.school.name, title: viewModel.tutorialOptionTitle, accessibility: .tutorial, tappedClosure: {
                                    
                                    viewModel.tutorialTapped()
                                })
                            }
                            
                            MenuItemView(imageAssetName: ImageCatalog.translate.name, title: viewModel.languageSettingsOptionTitle, accessibility: .languageSettings, tappedClosure: {
                                
                                viewModel.languageSettingsTapped()
                            })
                        }
                    )
   
                    if viewModel.accountSectionVisibility != .hidden {
                        
                        MenuSectionView(
                            sectionTitle: viewModel.accountSectionTitle,
                            menuItemsViewBuilder: {
                                
                                if viewModel.accountSectionVisibility == .visibleLoggedOut {
                                    
                                    MenuItemView(imageAssetName: ImageCatalog.login.name, title: viewModel.loginOptionTitle, accessibility: .login, tappedClosure: {
                                        
                                        viewModel.loginTapped()
                                    })
                                    
                                    MenuItemView(imageAssetName: ImageCatalog.personAdd.name, title: viewModel.createAccountOptionTitle, accessibility: .createAccount, tappedClosure: {
                                        
                                        viewModel.createAccountTapped()
                                    })
                                }
                                else if viewModel.accountSectionVisibility == .visibleLoggedIn {
                                    
                                    MenuItemView(imageAssetName: ImageCatalog.person.name, title: viewModel.activityOptionTitle, accessibility: .activity, tappedClosure: {
                                        
                                        viewModel.activityTapped()
                                    })
                                    
                                    MenuItemView(imageAssetName: ImageCatalog.logout.name, title: viewModel.logoutOptionTitle, accessibility: .logout, tappedClosure: {
                                        
                                        viewModel.logoutTapped()
                                    })
                                    
                                    MenuItemView(imageAssetName: ImageCatalog.personRemove.name, title: viewModel.deleteAccountOptionTitle, accessibility: .deleteAccount, tappedClosure: {
                                        
                                        viewModel.deleteAccountTapped()
                                    })
                                }
                            }
                        )
                    }
                    
                    MenuSectionView(
                        sectionTitle: viewModel.supportSectionTitle,
                        menuItemsViewBuilder: {
                            
                            MenuItemView(imageAssetName: ImageCatalog.send.name, title: viewModel.sendFeedbackOptionTitle, accessibility: .sendFeedback, tappedClosure: {
                                
                                viewModel.sendFeedbackTapped()
                            })
                            
                            MenuItemView(imageAssetName: ImageCatalog.bugReport.name, title: viewModel.reportABugOptionTitle, accessibility: .reportABug, tappedClosure: {
                                
                                viewModel.reportABugTapped()
                            })
                            
                            MenuItemView(imageAssetName: ImageCatalog.liveHelp.name, title: viewModel.askAQuestionOptionTitle, accessibility: .askAQuestion, tappedClosure: {
                                
                                viewModel.askAQuestionTapped()
                            })
                        }
                    )
                    
                    MenuSectionView(
                        sectionTitle: viewModel.shareSectionTitle,
                        menuItemsViewBuilder: {
                            
                            MenuItemView(imageAssetName: ImageCatalog.rateReview.name, title: viewModel.leaveAReviewOptionTitle, accessibility: .leaveAReview, tappedClosure: {
                                
                                viewModel.leaveAReviewTapped()
                            })
                            
                            MenuItemView(imageAssetName: ImageCatalog.description.name, title: viewModel.shareAStoryWithUsOptionTitle, accessibility: .shareAStoryWithUs, tappedClosure: {
                                
                                viewModel.shareAStoryWithUsTapped()
                            })
                            
                            MenuItemView(imageAssetName: ImageCatalog.share.name, title: viewModel.shareGodToolsOptionTitle, accessibility: .shareGodTools, tappedClosure: {
                                
                                viewModel.shareGodToolsTapped()
                            })
                        }
                    )
                    
                    MenuSectionView(
                        sectionTitle: viewModel.aboutSectionTitle,
                        menuItemsViewBuilder: {
                            
                            MenuItemView(imageAssetName: ImageCatalog.formatListBulleted.name, title: viewModel.termsOfUseOptionTitle, accessibility: .termsOfUse, tappedClosure: {
                                
                                viewModel.termsOfUseTapped()
                            })
                            
                            MenuItemView(imageAssetName: ImageCatalog.policy.name, title: viewModel.privacyPolicyOptionTitle, accessibility: .privacyPolicy, tappedClosure: {
                                
                                viewModel.privacyPolicyTapped()
                            })
                            
                            MenuItemView(imageAssetName: ImageCatalog.copyright.name, title: viewModel.copyrightInfoOptionTitle, accessibility: .copyrightInfo, tappedClosure: {
                                
                                viewModel.copyrightInfoTapped()
                            })
                        }
                    )
                    
                    MenuSectionView(
                        sectionTitle: viewModel.versionSectionTitle,
                        overrideHidesSeparator: true,
                        menuItemsViewBuilder: {
                            
                            MenuItemView(imageAssetName: nil, title: viewModel.appVersion, accessibility: nil, tappedClosure: nil)
                        }
                    )
                }
                .padding(EdgeInsets(top: 0, leading: MenuView.contentHorizontalPadding, bottom: 0, trailing: MenuView.contentHorizontalPadding))
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(viewModel.navTitle)
        .background(Color.white)
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
        .onAppear {
            viewModel.pageViewed()
        }
    }
}
