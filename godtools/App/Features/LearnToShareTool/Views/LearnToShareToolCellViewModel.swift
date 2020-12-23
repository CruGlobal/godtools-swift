//
//  LearnToShareToolCellViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class LearnToShareToolCellViewModel: LearnToShareToolCellViewModelType {
    
    let imageName: String?
    let animationName: String?
    let title: String
    let message: String
    
    required init(learnToShareToolItem: LearnToShareToolItem) {
        
        imageName = learnToShareToolItem.imageName
        animationName = learnToShareToolItem.animationName
        title = learnToShareToolItem.title
        message = learnToShareToolItem.message
    }
}
