//
//  ChooseYourOwnAdventureViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 1/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

protocol ChooseYourOwnAdventureViewModelType: MobileContentPagesViewModel {
    
    func getNavBarLanguageTitles() -> [String]
    func navBackTapped()
    func languageTapped(index: Int)
}
