//
//  XCTWaiter+Wait.swift
//  godtools
//
//  Created by Levi Eggert on 7/18/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import XCTest

extension XCTWaiter {
    
    static func waitHalfSecond() -> XCTWaiter.Result {
        return waitSeconds(seconds: 0.5)
    }
    
    static func waitOneSecond() -> XCTWaiter.Result {
        return waitSeconds(seconds: 1)
    }
    
    static func waitSeconds(seconds: TimeInterval) -> XCTWaiter.Result {
        return XCTWaiter.wait(for: [XCTestExpectation(description: "delay")], timeout: seconds)
    }
}
