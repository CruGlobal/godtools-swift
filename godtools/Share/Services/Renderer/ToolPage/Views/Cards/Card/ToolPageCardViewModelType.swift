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
    var titleColor: UIColor { get }
    var titleFont: UIFont { get }
    var contentStackViewModel: ToolPageContentStackViewModel { get }
    var isHiddenCard: Bool { get }
    var cardPositionLabel: String? { get }
    var cardPositionLabelTextColor: UIColor { get }
    var cardPositionLabelFont: UIFont { get }
    var previousButtonTitle: String? { get }
    var previousButtonTitleColor: UIColor { get }
    var previousButtonTitleFont: UIFont { get }
    var nextButtonTitle: String? { get }
    var nextButtonTitleColor: UIColor { get }
    var nextButtonTitleFont: UIFont { get }
    var hidesCardNavigation: Bool { get }
    
    func headerTapped()
    func previousTapped()
    func nextTapped()
    func didSwipeCardUp()
    func didSwipeCardDown()
}
