//
//  MenuViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 1/31/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol MenuViewModelType {
    
    var navTitle: ObservableValue<String> { get }
    var navDoneButtonTitle: String { get }
    var menuDataSource: ObservableValue<MenuDataSource> { get }
    
    func menuSectionWillAppear(sectionIndex: Int) -> MenuSectionHeaderViewModelType
    func menuItemWillAppear(sectionIndex: Int, itemIndexRelativeToSection: Int) -> MenuItemViewModelType
    func pageViewed()
    func doneTapped()
    func tutorialTapped()
    func languageSettingsTapped()
    func loginTapped(fromViewController: UIViewController)
    func activityTapped()
    func createAccountTapped(fromViewController: UIViewController)
    func logoutTapped(fromViewController: UIViewController)
    func deleteAccountTapped()
    func sendFeedbackTapped()
    func reportABugTapped()
    func askAQuestionTapped()
    func leaveAReviewTapped()
    func shareAStoryWithUsTapped()
    func shareGodToolsTapped()
    func termsOfUseTapped()
    func privacyPolicyTapped()
    func copyrightInfoTapped()
}
