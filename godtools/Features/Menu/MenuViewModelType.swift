//
//  MenuViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 1/31/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import TheKeyOAuthSwift

protocol MenuViewModelType {
    
    var loginClient: TheKeyOAuthClient { get }
    var navTitle: ObservableValue<String> { get }
    var navDoneButtonTitle: String { get }
    var menuDataSource: ObservableValue<MenuDataSource> { get }
    
    func pageViewed()
    func doneTapped()
    func reloadMenuDataSource()
    func languageSettingsTapped()
    func tutorialTapped()
    func myAccountTapped()
    func aboutTapped()
    func helpTapped()
    func contactUsTapped()
    func logoutTapped()
    func shareGodToolsTapped()
    func shareAStoryWithUsTapped()
    func termsOfUseTapped()
    func privacyPolicyTapped()
    func copyrightInfoTapped()
}
