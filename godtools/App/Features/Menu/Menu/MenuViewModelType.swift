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
    func languageSettingsTapped()
    func tutorialTapped()
    func myAccountTapped()
    func aboutTapped()
    func helpTapped()
    func contactUsTapped()
    func logoutTapped(fromViewController: UIViewController)
    func loginTapped(fromViewController: UIViewController)
    func createAccountTapped(fromViewController: UIViewController)
    func shareGodToolsTapped()
    func shareAStoryWithUsTapped()
    func termsOfUseTapped()
    func privacyPolicyTapped()
    func copyrightInfoTapped()
    func deleteAccountTapped()
}
