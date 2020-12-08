//
//  ToolPageContentTabsViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol ToolPageContentTabsViewModelType {
    
    var tabLabels: [String] { get }
    var selectedTab: ObservableValue<Int> { get }
    var tabContent: ObservableValue<ToolPageContentStackContainerViewModel?> { get }
    var languageDirectionSemanticContentAttribute: UISemanticContentAttribute { get }
    
    func tabTapped(tab: Int)
}
