//
//  main.swift
//  godtools
//
//  Created by Levi Eggert on 10/24/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

let isUnitTests: Bool = NSClassFromString("XCTestCase") != nil

if isUnitTests {
    TestsApp.main()
}
else {
    GodToolsApp.main()
}
