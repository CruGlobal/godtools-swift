//
//  ToolPageHeroViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol ToolPageHeroViewModelType {
    
    var contentStackRenderer: ToolPageContentStackRenderer { get }
    
    func heroDidAppear()
    func heroDidDisappear()
}
