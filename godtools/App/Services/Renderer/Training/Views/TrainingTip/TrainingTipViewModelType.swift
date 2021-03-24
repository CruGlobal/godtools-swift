//
//  TrainingTipViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 11/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol TrainingTipViewModelType {
    
    var trainingTipBackgroundImage: ObservableValue<UIImage?> { get }
    var trainingTipForegroundImage: ObservableValue<UIImage?> { get }
    
    func setViewType(viewType: TrainingTipViewType)
    func tipTapped() -> TrainingTipEvent?
}
