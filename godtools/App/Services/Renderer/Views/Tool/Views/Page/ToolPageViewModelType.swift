//
//  ToolPageViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol ToolPageViewModelType: MobileContentPageViewModelType {
    
    var bottomViewColor: UIColor { get }
    var page: Int { get }
    var hidesCallToAction: Bool { get }
    var numberOfVisibleCards: Int { get }
    
    func callToActionWillAppear() -> ToolPageCallToActionView?
    func pageDidAppear()
    func didChangeCardPosition(cardPosition: Int?)
}
