//
//  ToolPageViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol ToolPageViewModelType {
    
    var backgroundColor: UIColor { get }
    var backgroundImage: UIImage? { get }
    var contentStackViewModel: ToolPageContentStackViewModel? { get }
    var headerViewModel: ToolPageHeaderViewModel { get }
    var heroViewModel: ToolPageContentStackViewModel? { get }
    var hidesCards: Bool { get }
    var cardsViewModels: [ToolPageCardViewModelType] { get }
    var currentCard: ObservableValue<Int?> { get }
    var hiddenCard: ObservableValue<ToolPageCardViewModel?> { get }
    var callToActionViewModel: ToolPageCallToActionViewModel { get }
    var modal: ObservableValue<ToolPageModalViewModel?> { get }
    
    func handleCallToActionNextButtonTapped()
}
