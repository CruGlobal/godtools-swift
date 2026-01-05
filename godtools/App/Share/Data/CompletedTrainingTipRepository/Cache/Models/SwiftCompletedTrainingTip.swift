//
//  SwiftCompletedTrainingTip.swift
//  godtools
//
//  Created by Rachael Skeath on 10/8/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
typealias SwiftCompletedTrainingTip = SwiftCompletedTrainingTipV1.SwiftCompletedTrainingTip

@available(iOS 17.4, *)
enum SwiftCompletedTrainingTipV1 {
    
    @Model
    class SwiftCompletedTrainingTip: IdentifiableSwiftDataObject {
        
        var trainingTipId: String = ""
        var resourceId: String = ""
        var languageId: String = ""
        
        @Attribute(.unique) var id: String = ""
        
        init() {
            
        }
    }
}
