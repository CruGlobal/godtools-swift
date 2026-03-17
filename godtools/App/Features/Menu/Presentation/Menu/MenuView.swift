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
                        sectionTitle: viewModel.strings.getStartedTitle,
                        menuItemsViewBuilder: {
                            
                            if viewModel.showsTutorialOption {
                                
                                MenuItemView(imageAssetName: ImageCatalog.school.name, title: viewModel.strings.tutorialOptionTitle, accessibility: .tutorial, tappedClosure: {
                                    
                                    viewModel.tutorialTapped()
                                })
                            }
                            
                            MenuItemView(imageAssetName: ImageCatalog.translate.name, title: viewModel.strings.languageSettingsOptionTitle, accessibility: .languageSettings, tappedClosure: {
                                
                                viewModel.languageSettingsTapped()
                            })
                            
                            if GodToolsAppConfig.showsPersonalization {
                                MenuItemView(imageAssetName: ImageCatalog.translate.name, title: viewModel.strings.localizationSettingsOptionTitle, accessibility: .localizationSettings, tappedClosure: {
                                    
                                    viewModel.localizationSettingsTapped()
                                })
                            }
                        }
                    )
   
                    if viewModel.accountSectionVisibility != .hidden {
                        
                        MenuSectionView(
                            sectionTitle: viewModel.strings.accountTitle,
                            menuItemsViewBuilder: {
                                
                                if viewModel.accountSectionVisibility == .visibleLoggedOut {
                                    
                                    MenuItemView(imageAssetName: ImageCatalog.login.name, title: viewModel.strings.loginOptionTitle, accessibility: .login, tappedClosure: {
                                        
                                        viewModel.loginTapped()
                                    })
                                    
                                    MenuItemView(imageAssetName: ImageCatalog.personAdd.name, title: viewModel.strings.createAccountOptionTitle, accessibility: .createAccount, tappedClosure: {
                                        
                                        viewModel.createAccountTapped()
                                    })
                                }
                                else if viewModel.accountSectionVisibility == .visibleLoggedIn {
                                    
                                    MenuItemView(imageAssetName: ImageCatalog.person.name, title: viewModel.strings.activityOptionTitle, accessibility: .activity, tappedClosure: {
                                        
                                        viewModel.activityTapped()
                                    })
                                    
                                    MenuItemView(imageAssetName: ImageCatalog.logout.name, title: viewModel.strings.logoutOptionTitle, accessibility: .logout, tappedClosure: {
                                        
                                        viewModel.logoutTapped()
                                    })
                                    
                                    MenuItemView(imageAssetName: ImageCatalog.personRemove.name, title: viewModel.strings.deleteAccountOptionTitle, accessibility: .deleteAccount, tappedClosure: {
                                        
                                        viewModel.deleteAccountTapped()
                                    })
                                }
                            }
                        )
                    }
                    
                    MenuSectionView(
                        sectionTitle: viewModel.strings.supportTitle,
                        menuItemsViewBuilder: {
                            
                            MenuItemView(imageAssetName: ImageCatalog.send.name, title: viewModel.strings.sendFeedbackOptionTitle, accessibility: .sendFeedback, tappedClosure: {
                                
                                viewModel.sendFeedbackTapped()
                            })
                            
                            MenuItemView(imageAssetName: ImageCatalog.bugReport.name, title: viewModel.strings.reportABugOptionTitle, accessibility: .reportABug, tappedClosure: {
                                
                                viewModel.reportABugTapped()
                            })
                            
                            MenuItemView(imageAssetName: ImageCatalog.liveHelp.name, title: viewModel.strings.askAQuestionOptionTitle, accessibility: .askAQuestion, tappedClosure: {
                                
                                viewModel.askAQuestionTapped()
                            })
                        }
                    )
                    
                    MenuSectionView(
                        sectionTitle: viewModel.strings.shareTitle,
                        menuItemsViewBuilder: {
                            
                            MenuItemView(imageAssetName: ImageCatalog.rateReview.name, title: viewModel.strings.leaveAReviewOptionTitle, accessibility: .leaveAReview, tappedClosure: {
                                
                                viewModel.leaveAReviewTapped()
                            })
                            
                            MenuItemView(imageAssetName: ImageCatalog.description.name, title: viewModel.strings.shareAStoryWithUsOptionTitle, accessibility: .shareAStoryWithUs, tappedClosure: {
                                
                                viewModel.shareAStoryWithUsTapped()
                            })
                            
                            MenuItemView(imageAssetName: ImageCatalog.share.name, title: viewModel.strings.shareGodToolsOptionTitle, accessibility: .shareGodTools, tappedClosure: {
                                
                                viewModel.shareGodToolsTapped()
                            })
                        }
                    )
                    
                    MenuSectionView(
                        sectionTitle: viewModel.strings.aboutTitle,
                        menuItemsViewBuilder: {
                            
                            MenuItemView(imageAssetName: ImageCatalog.formatListBulleted.name, title: viewModel.strings.termsOfUseOptionTitle, accessibility: .termsOfUse, tappedClosure: {
                                
                                viewModel.termsOfUseTapped()
                            })
                            
                            MenuItemView(imageAssetName: ImageCatalog.policy.name, title: viewModel.strings.privacyPolicyOptionTitle, accessibility: .privacyPolicy, tappedClosure: {
                                
                                viewModel.privacyPolicyTapped()
                            })
                            
                            MenuItemView(imageAssetName: ImageCatalog.copyright.name, title: viewModel.strings.copyrightInfoOptionTitle, accessibility: .copyrightInfo, tappedClosure: {
                                
                                viewModel.copyrightInfoTapped()
                            })
                        }
                    )
                    
                    MenuSectionView(
                        sectionTitle: viewModel.strings.versionTitle,
                        overrideHidesSeparator: true,
                        menuItemsViewBuilder: {
                            
                            MenuItemView(imageAssetName: nil, title: viewModel.strings.version, accessibility: nil, tappedClosure: nil)
                        }
                    )
                    
                    if !viewModel.hidesDebugSection {
                        
                        MenuSectionView(
                            sectionTitle: "Debug",
                            menuItemsViewBuilder: {
                                
                                MenuItemView(imageAssetName: ImageCatalog.bugReport.name, title: "Copy Firebase Device Token", accessibility: nil, tappedClosure: {
                                    
                                    viewModel.copyFirebaseDeviceTokenTapped()
                                })
                            }
                        )
                    }
                }
                .padding(EdgeInsets(top: 0, leading: MenuView.contentHorizontalPadding, bottom: 0, trailing: MenuView.contentHorizontalPadding))
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(viewModel.strings.title)
        .background(Color.white)
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
        .onAppear {
            viewModel.pageViewed()
        }
    }
}
