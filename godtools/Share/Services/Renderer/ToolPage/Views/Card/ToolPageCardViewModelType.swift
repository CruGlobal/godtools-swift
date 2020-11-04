//
//  ToolPageCardViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 11/3/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol ToolPageCardViewModelType {
    
    var title: String? { get }
    var cardPositionLabel: String? { get }
    var previousButtonTitle: String? { get }
    var nextButtonTitle: String? { get }
    
    func contentStackWillAppear() -> ToolPageContentStackViewModel
    func headerTapped()
    func previousTapped()
    func nextTapped()
}
