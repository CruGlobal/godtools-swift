//
//  ToolPageViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol ToolPageViewModelType {
    
    var backgroundImage: UIImage? { get }
    var hidesBackgroundImage: Bool { get }
    var hidesCards: Bool { get }
    
    func contentStackWillAppear() -> ToolPageContentStackViewModel?
    func headerWillAppear() -> ToolPageHeaderViewModel
    func heroWillAppear() -> ToolPageContentStackViewModel?
    func cardsWillAppear() -> [ToolPageCardViewModel]
    func callToActionWillAppear() -> ToolPageCallToActionViewModel
}
