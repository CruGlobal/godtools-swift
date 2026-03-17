//
//  ResumeLessonProgressStringsDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 11/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct ResumeLessonProgressStringsDomainModel: Sendable {
    
    let title: String
    let subtitle: String
    let startOverButtonText: String
    let continueButtonText: String
    
    static var emptyValue: ResumeLessonProgressStringsDomainModel {
        return ResumeLessonProgressStringsDomainModel(title: "", subtitle: "", startOverButtonText: "", continueButtonText: "")
    }
}
