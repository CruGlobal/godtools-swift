//
//  MobileContentBackgroundImageRendererTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 3/4/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import XCTest
@testable import godtools

class MobileContentBackgroundImageRendererTests: XCTestCase {

    private let backgroundImageRenderer: MobileContentBackgroundImageRenderer = MobileContentBackgroundImageRenderer()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testRectIsPositionedCorrectlyInContainerWithScaleFillAndAlignCenter() {
        
        let scale: String = MobileContentBackgroundImageScaleType.fill.rawValue
        let align: [String] = [MobileContentBackgroundImageAlignType.center.rawValue]
        
        let container: CGRect = CGRect(x: 0, y: 0, width: 320, height: 568)
        
        let rect_A: CGRect = CGRect(x: 0, y: 0, width: 1242, height: 2688)
        
        let expectedRendered_rect_A: CGRect = CGRect(x: 0, y: -62, width: 320, height: 692)
        
        let rendered_rect_A: CGRect = backgroundImageRenderer.getBackgroundImageRectForRenderingInContainer(
            container: container,
            backgroundImageSizePixels: rect_A.size,
            backgroundImageNode: TestBackgroundImageNode(backgroundImageAlign: align, backgroundImageScaleType: scale)
        )
        
        assertFailureIfExpectedRectIsNotEqualToRenderedRect(renderedRect: rendered_rect_A, expectedRect: expectedRendered_rect_A)
        
        
        let rect_B: CGRect = CGRect(x: 0, y: 0, width: 2688, height: 1242)
        
        let expectedRendered_rect_B: CGRect = CGRect(x: -454, y: 0, width: 1229, height: 568)
        
        let rendered_rect_B: CGRect = backgroundImageRenderer.getBackgroundImageRectForRenderingInContainer(
            container: container,
            backgroundImageSizePixels: rect_B.size,
            backgroundImageNode: TestBackgroundImageNode(backgroundImageAlign: align, backgroundImageScaleType: scale)
        )
        
        assertFailureIfExpectedRectIsNotEqualToRenderedRect(renderedRect: rendered_rect_B, expectedRect: expectedRendered_rect_B)
        
        
        let rect_C: CGRect = CGRect(x: 0, y: 0, width: 120, height: 120)
        
        let expectedRendered_rect_C: CGRect = CGRect(x: -124, y: 0, width: 568, height: 568)
        
        let rendered_rect_C: CGRect = backgroundImageRenderer.getBackgroundImageRectForRenderingInContainer(
            container: container,
            backgroundImageSizePixels: rect_C.size,
            backgroundImageNode: TestBackgroundImageNode(backgroundImageAlign: align, backgroundImageScaleType: scale)
        )
        
        assertFailureIfExpectedRectIsNotEqualToRenderedRect(renderedRect: rendered_rect_C, expectedRect: expectedRendered_rect_C)
    }
    
    private func assertFailureIfExpectedRectIsNotEqualToRenderedRect(renderedRect: CGRect, expectedRect: CGRect) {
        
        XCTAssertTrue(renderedRect.origin.x == expectedRect.origin.x, "Rendered failed, x positions do not match.\n  renderedRect: \(renderedRect)\n  expectedRect: \(expectedRect)")
        XCTAssertTrue(renderedRect.origin.y == expectedRect.origin.y, "Rendered failed, y positions do not match.\n  renderedRect: \(renderedRect)\n  expectedRect: \(expectedRect)")
        XCTAssertTrue(renderedRect.size.width == expectedRect.size.width, "Rendered failed, widths do not match.\n  renderedRect: \(renderedRect)\n  expectedRect: \(expectedRect)")
        XCTAssertTrue(renderedRect.size.height == expectedRect.size.height, "Rendered failed, heights do not match.\n  renderedRect: \(renderedRect)\n  expectedRect: \(expectedRect)")
    }
}
