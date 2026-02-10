//
//  PersonalizedLessonsDataModelInterface.swift
//  godtools
//
//  Created by Levi Eggert on 2/10/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

protocol PersonalizedLessonsDataModelInterface {
    
    var id: String { get }
    var updatedAt: Date { get }
    var resourceIds: [String] { get }
}
