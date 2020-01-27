//
//  TutorialCellViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TutorialCellViewModel {
    
    let title: String
    let message: String
    
    required init(item: TutorialItem) {
        title = item.title
        message = item.message
    }
}
