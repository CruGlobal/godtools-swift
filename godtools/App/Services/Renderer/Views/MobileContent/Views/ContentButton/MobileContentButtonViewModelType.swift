//
//  MobileContentButtonViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol MobileContentButtonViewModelType {
    
    var backgroundColor: UIColor { get }
    var buttonWidth: MobileContentViewWidth { get }
    var font: UIFont { get }
    var title: String? { get }
    var titleColor: UIColor { get }
    var borderColor: UIColor? { get }
    var borderWidth: CGFloat? { get }
    var buttonType: MobileContentButtonType { get }
    var buttonEvents: [MultiplatformEventId] { get }
    var buttonUrl: String { get }
    var rendererState: MobileContentMultiplatformState { get }
    var visibilityState: ObservableValue<MobileContentViewVisibilityState> { get }
    var icon: MobileContentButtonIcon? { get }
    
    func buttonTapped()
}
