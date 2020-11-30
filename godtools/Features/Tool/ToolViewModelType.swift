//
//  ToolViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 10/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol ToolViewModelType {
    
    var currentPage: ObservableValue<AnimatableValue<Int>> { get }
    var numberOfToolPages: ObservableValue<Int> { get }
    
    func navBarWillAppear() -> ToolNavBarViewModelType
    func viewLoaded()
    func toolPageWillAppear(page: Int) -> ToolPageViewModelType?
    func toolPageDidChange(page: Int)
    func toolPageDidAppear(page: Int)
    func toolPageDidDisappear(page: Int)
}
