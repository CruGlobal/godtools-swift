//
//  UserActivityStatDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 3/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import SwiftUI

struct UserActivityStatDomainModel {
    
    let iconImageName: String
    let text: String
    let textColor: Color
    let value: Int
    
}

extension UserActivityStatDomainModel: Identifiable {
    
    var id: String {
        return text
    }
}

