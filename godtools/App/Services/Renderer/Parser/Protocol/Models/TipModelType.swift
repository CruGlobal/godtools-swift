//
//  TipModelType.swift
//  godtools
//
//  Created by Levi Eggert on 8/18/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol TipModelType {
    
    var id: String { get }
    var tipType: MobileContentTrainingTipType { get }
    var pages: [PageModelType] { get }
}
