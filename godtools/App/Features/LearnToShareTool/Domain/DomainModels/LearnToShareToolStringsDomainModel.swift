//
//  LearnToShareToolStringsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 12/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct LearnToShareToolStringsDomainModel: Sendable {
    
    let nextTutorialItemActionTitle: String
    let startTrainingActionTitle: String
    
    static var emptyValue: LearnToShareToolStringsDomainModel {
        return LearnToShareToolStringsDomainModel(nextTutorialItemActionTitle: "", startTrainingActionTitle: "")
    }
}
