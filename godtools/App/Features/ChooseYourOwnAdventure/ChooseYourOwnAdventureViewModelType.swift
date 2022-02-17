//
//  ChooseYourOwnAdventureViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 1/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

protocol ChooseYourOwnAdventureViewModelType: MobileContentPagesViewModel {
    
    var backButtonImage: ObservableValue<UIImage?> { get }
    var navBarColors: ObservableValue<ChooseYourOwnAdventureNavBarModel> { get }
    var navBarTitleType: ChooseYourOwnAdventureNavBarTitleType { get }
    
    func getNavBarLanguageTitles() -> [String]
    func navBackTapped()
    func navLanguageTapped(index: Int)
}
