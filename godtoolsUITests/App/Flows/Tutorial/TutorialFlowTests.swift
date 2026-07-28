//
//  TutorialFlowTests.swift
//  godtools
//
//  Created by Levi Eggert on 7/9/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import XCTest

class TutorialFlowTests: BaseFlowTests {

    private func launchApp() {

        super.launchApp(
            flowDeepLinkUrl: DeepLinkUrl.getTutorial(),
            checkInitialScreenExists: .tutorial
        )
    }

    func testInitialScreenIsTutorial() {

        launchApp()

        super.assertIfInitialScreenDoesntExist()
    }

    func testBackButtonIsHiddenOnFirstTutorialPage() {

        launchApp()

        assertIfButtonExists(buttonAccessibility: .back)
    }

    func testTappingContinueNavigatesForwardThroughTutorialPages() {

        launchApp()

        assertIfButtonExists(buttonAccessibility: .back)

        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .continueForward)

        assertIfButtonDoesNotExist(buttonAccessibility: .back)

        assertIfScreenDoesNotExist(screenAccessibility: .tutorial)
    }

    func testTappingBackNavigatesBackwardThroughTutorialPages() {

        launchApp()

        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .continueForward)

        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .back)

        assertIfButtonExists(buttonAccessibility: .back)

        assertIfScreenDoesNotExist(screenAccessibility: .tutorial)
    }
}
