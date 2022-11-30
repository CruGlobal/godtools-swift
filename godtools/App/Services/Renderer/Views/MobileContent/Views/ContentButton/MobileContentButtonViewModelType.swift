//
//  MobileContentButtonViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

protocol MobileContentButtonViewModelType: ClickableMobileContentViewModel {
    
    var backgroundColor: UIColor { get }
    var buttonWidth: MobileContentViewWidth { get }
    var font: UIFont { get }
    var title: String? { get }
    var titleColor: UIColor { get }
    var borderColor: UIColor? { get }
    var borderWidth: CGFloat? { get }
    var buttonType: Button.Type_ { get }
    var buttonEvents: [EventId] { get }
    var rendererState: State { get }
    var visibilityState: ObservableValue<MobileContentViewVisibilityState> { get }
    var icon: MobileContentButtonIcon? { get }
    
    func buttonTapped()
}
