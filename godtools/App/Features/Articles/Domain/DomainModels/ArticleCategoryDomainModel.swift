//
//  ArticleCategoryDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/12/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import SwiftUI

struct ArticleCategoryDomainModel: Sendable, Identifiable {
    
    let id: String
    let title: String
    let image: Image?
}
