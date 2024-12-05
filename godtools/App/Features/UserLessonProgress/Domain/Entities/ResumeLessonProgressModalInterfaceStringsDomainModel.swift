//
//  ResumeLessonProgressModalInterfaceStringsDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 11/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct ResumeLessonProgressModalInterfaceStringsDomainModel {
    let title: String
    let subtitle: String
    let startOverButtonText: String
    let continueButtonText: String
    
    static func emptyStrings() -> ResumeLessonProgressModalInterfaceStringsDomainModel {
        return ResumeLessonProgressModalInterfaceStringsDomainModel(title: "", subtitle: "", startOverButtonText: "", continueButtonText: "")
    }
}
