//
//  MockStringWithLocaleCount.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/29/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools

class MockStringWithLocaleCount: StringWithLocaleCountInterface {
    
    init() {
        
    }
    
    func getString(format: String, locale: Locale, count: Int) -> String {
        
        return format + " " + "\(count)"
    }
}
