//
//  LocalizationSettingsFlowTests.swift
//  godtools
//
//  Created by Levi Eggert on 7/9/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import XCTest

final class LocalizationSettingsFlowTests: BaseFlowTests {
       
    private func launchApp() {
        
        super.launchApp(
            flowDeepLinkUrl: DeepLinkUrl.getSettingsLocalization(),
            checkInitialScreenExists: .localizationSettings
        )
    }
    
    func testInitialScreenIsLocalizationSettings() {
        
        launchApp()
        
        super.assertIfInitialScreenDoesntExist()
    }
    
    func testTappingLocalizationSettingsCountryNavigatesToConfirmLocalizationSettings() {
        
        launchApp()
                
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .localizationSettingsCountryListItem, buttonQueryType: .firstMatch)
        
        assertIfScreenDoesNotExist(screenAccessibility: .confirmLocalizationSettings)
    }
    
    func testTappingEditLocalizationFromConfirmLocalizationSettingsNavigatesBackToLocalizationSettings() {
        
        launchApp()
                
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .localizationSettingsCountryListItem, buttonQueryType: .firstMatch)
        
        assertIfScreenDoesNotExist(screenAccessibility: .confirmLocalizationSettings)
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .editLocalization)
        
        assertIfScreenDoesNotExist(screenAccessibility: .localizationSettings)
    }
    
    func testConfirmingSelectedCountryMovesItToTopOfList() {
        
        launchApp()
        
        let selectedCountry: String = countryListItemLabel(atIndex: Self.countryIndexToSelect)
        
        confirmCountryListItem(atIndex: Self.countryIndexToSelect)
        
        assertCountryListItem(atIndex: 0, eventuallyHasLabel: selectedCountry)
    }

    
    func testCancellingSelectedCountryDoesNotMoveItToTopOfList() {
        
        launchApp()
        
        let firstCountryBeforeSelection: String = countryListItemLabel(atIndex: 0)
        let selectedCountry: String = countryListItemLabel(atIndex: Self.countryIndexToSelect)
        
        tapCountryListItem(atIndex: Self.countryIndexToSelect)
        
        assertIfScreenDoesNotExist(screenAccessibility: .confirmLocalizationSettings)
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .editLocalization)
        
        assertIfScreenDoesNotExist(screenAccessibility: .localizationSettings)
        
        XCTAssertEqual(countryListItemLabel(atIndex: 0), firstCountryBeforeSelection)
        XCTAssertNotEqual(countryListItemLabel(atIndex: 0), selectedCountry)
    }
}

// MARK: - Test Helpers

extension LocalizationSettingsFlowTests {
    
    private static let countryIndexToSelect: Int = 2
    private static let waitForCountryListItemExistence: TimeInterval = 2
    private static let waitForCountryListReorder: TimeInterval = 5
    
    private func queryCountryListItem(atIndex index: Int) -> XCUIElement {
        
        let countryListItem: XCUIElement = app.buttons
            .matching(identifier: AccessibilityStrings.Button.localizationSettingsCountryListItem.id)
            .element(boundBy: index)
        
        XCTAssertTrue(
            countryListItem.waitForExistence(timeout: Self.waitForCountryListItemExistence),
            "Expected a country list item at index \(index)."
        )
        
        return countryListItem
    }
    
    private func countryListItemLabel(atIndex index: Int) -> String {
        return queryCountryListItem(atIndex: index).label
    }
    
    private func tapCountryListItem(atIndex index: Int) {
        queryCountryListItem(atIndex: index).tap()
    }
    
    private func confirmCountryListItem(atIndex index: Int) {
        
        tapCountryListItem(atIndex: index)
        
        assertIfScreenDoesNotExist(screenAccessibility: .confirmLocalizationSettings)
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .continueForward)
        
        assertIfScreenDoesNotExist(screenAccessibility: .localizationSettings)
    }
    
    private func assertCountryListItem(atIndex index: Int, eventuallyHasLabel expectedLabel: String) {
        
        let countryListItem: XCUIElement = queryCountryListItem(atIndex: index)
        
        let labelMatchesExpectedLabel = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "label == %@", expectedLabel),
            object: countryListItem
        )
        
        let waiterResult: XCTWaiter.Result = XCTWaiter()
            .wait(for: [labelMatchesExpectedLabel], timeout: Self.waitForCountryListReorder)
        
        XCTAssertEqual(
            waiterResult,
            .completed,
            "Expected country list item at index \(index) to be \"\(expectedLabel)\" but found \"\(countryListItem.label)\"."
        )
    }
}
