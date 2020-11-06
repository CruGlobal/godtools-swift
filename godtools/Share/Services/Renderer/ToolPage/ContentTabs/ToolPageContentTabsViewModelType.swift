//
//  ToolPageContentTabsViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ToolPageContentTabsViewModelType {
    
    var tabLabels: [String] { get }
    var selectedTab: ObservableValue<Int> { get }
    var tabContent: ObservableValue<ToolPageContentStackViewModel?> { get }
    
    func tabTapped(tab: Int)
}
