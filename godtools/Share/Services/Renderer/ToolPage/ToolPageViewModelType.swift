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
    var contentStackViewModel: ToolPageContentStackViewModel? { get }
    var headerViewModel: ToolPageHeaderViewModel { get }
    var heroViewModel: ToolPageContentStackViewModel? { get }
    var hidesCards: Bool { get }
    var cardsViewModels: [ToolPageCardViewModelType] { get }
    var currentCard: ObservableValue<Int?> { get }
    var callToActionViewModel: ToolPageCallToActionViewModel { get }
}
