//
//  main.swift
//  godtools
//
//  Created by Levi Eggert on 10/24/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

let isUnitTests: Bool = NSClassFromString("XCTestCase") != nil
let isUITests: Bool = LaunchEnvironmentReader.createFromProcessInfo().getIsUITests() ?? false
let runningForPreviews: String? = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"]

if isUnitTests {
    TestsApp.main()
}
else {
    GodToolsApp.main()
}
