//
//  MobileContentPageViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 5/17/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol MobileContentPageViewModelType {
    
    var backgroundColor: UIColor { get }
    
    func backgroundImageWillAppear() -> MobileContentBackgroundImageViewModel?
    func buttonWithUrlTapped(url: String)
    func trainingTipTapped(event: TrainingTipEvent)
    func errorOccurred(error: MobileContentErrorViewModel)
}
