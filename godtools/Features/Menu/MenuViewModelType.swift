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
    var menuDataSource: ObservableValue<MenuDataSource> { get }
    
    func reloadMenuDataSource()
    func tutorialTapped()
    func myAccountTapped()
    func helpTapped()
    func contactUsTapped()
    func shareAStoryWithUsTapped()
    func termsOfUseTapped()
    func privacyPolicyTapped()
    func copyrightInfoTapped()
}
