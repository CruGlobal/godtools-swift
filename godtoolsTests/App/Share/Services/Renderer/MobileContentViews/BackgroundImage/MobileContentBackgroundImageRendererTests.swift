//
//  MobileContentBackgroundImageRendererTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 3/4/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import XCTest
import GodToolsToolParser
@testable import godtools

class MobileContentBackgroundImageRendererTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    private func assertFailureIfExpectedRectIsNotEqualToRenderedRect(renderedRect: CGRect, expectedRect: CGRect) {
        
        XCTAssertTrue(renderedRect.origin.x == expectedRect.origin.x, "Rendered failed, x positions do not match.\n  renderedRect: \(renderedRect)\n  expectedRect: \(expectedRect)")
        XCTAssertTrue(renderedRect.origin.y == expectedRect.origin.y, "Rendered failed, y positions do not match.\n  renderedRect: \(renderedRect)\n  expectedRect: \(expectedRect)")
        XCTAssertTrue(renderedRect.size.width == expectedRect.size.width, "Rendered failed, widths do not match.\n  renderedRect: \(renderedRect)\n  expectedRect: \(expectedRect)")
        XCTAssertTrue(renderedRect.size.height == expectedRect.size.height, "Rendered failed, heights do not match.\n  renderedRect: \(renderedRect)\n  expectedRect: \(expectedRect)")
    }
    
    func testRectIsPositionedCorrectlyInContainerWithScaleFitAndAlignCenter() {
        
        let backgroundImageRenderer: MobileContentBackgroundImageRenderer = MobileContentBackgroundImageRenderer()
        
        let scale: ImageScaleType = .fit
        let horizontal: Gravity.Horizontal = .center
        let vertical: Gravity.Vertical = .center
        let languageDirection: LanguageDirection = .leftToRight
        
        let container: CGRect = CGRect(x: 0, y: 0, width: 320, height: 568)
        
        // ** rect_A
        
        let rect_A: CGRect = CGRect(x: 0, y: 0, width: 1242, height: 2688)
        
        let expectedRendered_rect_A: CGRect = CGRect(x: 28, y: 0, width: 262, height: 568)
        
        let rendered_rect_A: CGRect = backgroundImageRenderer.getBackgroundImageRectForRenderingInContainer(
            container: container,
            backgroundImageSizePixels: rect_A.size,
            scale: scale,
            horizontal: horizontal,
            vertical: vertical,
            languageDirection: languageDirection
        )
        
        assertFailureIfExpectedRectIsNotEqualToRenderedRect(renderedRect: rendered_rect_A, expectedRect: expectedRendered_rect_A)
        
        // ** rect_B
        
        let rect_B: CGRect = CGRect(x: 0, y: 0, width: 2688, height: 1242)
        
        let expectedRendered_rect_B: CGRect = CGRect(x: 0, y: 210, width: 320, height: 147)
        
        let rendered_rect_B: CGRect = backgroundImageRenderer.getBackgroundImageRectForRenderingInContainer(
            container: container,
            backgroundImageSizePixels: rect_B.size,
            scale: scale,
            horizontal: horizontal,
            vertical: vertical,
            languageDirection: languageDirection
        )
        
        assertFailureIfExpectedRectIsNotEqualToRenderedRect(renderedRect: rendered_rect_B, expectedRect: expectedRendered_rect_B)
        
        // ** rect_C
        
        let rect_C: CGRect = CGRect(x: 0, y: 0, width: 120, height: 120)
        
        let expectedRendered_rect_C: CGRect = CGRect(x: 0, y: 124, width: 320, height: 320)
        
        let rendered_rect_C: CGRect = backgroundImageRenderer.getBackgroundImageRectForRenderingInContainer(
            container: container,
            backgroundImageSizePixels: rect_C.size,
            scale: scale,
            horizontal: horizontal,
            vertical: vertical,
            languageDirection: languageDirection
        )
        
        assertFailureIfExpectedRectIsNotEqualToRenderedRect(renderedRect: rendered_rect_C, expectedRect: expectedRendered_rect_C)
        
        // ** rect_D
        
        let rect_D: CGRect = CGRect(x: 0, y: 0, width: 55, height: 1400)
        
        let expectedRendered_rect_D: CGRect = CGRect(x: 148, y: 0, width: 22, height: 568)
        
        let rendered_rect_D: CGRect = backgroundImageRenderer.getBackgroundImageRectForRenderingInContainer(
            container: container,
            backgroundImageSizePixels: rect_D.size,
            scale: scale,
            horizontal: horizontal,
            vertical: vertical,
            languageDirection: languageDirection
        )
        
        assertFailureIfExpectedRectIsNotEqualToRenderedRect(renderedRect: rendered_rect_D, expectedRect: expectedRendered_rect_D)
        
        // ** rect_E
        
        let rect_E: CGRect = CGRect(x: 0, y: 0, width: 1800, height: 200)
        
        let expectedRendered_rect_E: CGRect = CGRect(x: 0, y: 266, width: 320, height: 35)
        
        let rendered_rect_E: CGRect = backgroundImageRenderer.getBackgroundImageRectForRenderingInContainer(
            container: container,
            backgroundImageSizePixels: rect_E.size,
            scale: scale,
            horizontal: horizontal,
            vertical: vertical,
            languageDirection: languageDirection
        )
        
        assertFailureIfExpectedRectIsNotEqualToRenderedRect(renderedRect: rendered_rect_E, expectedRect: expectedRendered_rect_E)
    }
    
    func testRectIsPositionedCorrectlyInContainerWithScaleFillAndAlignCenter() {
        
        let backgroundImageRenderer: MobileContentBackgroundImageRenderer = MobileContentBackgroundImageRenderer()
        
        let scale: ImageScaleType = .fill
        let horizontal: Gravity.Horizontal = .center
        let vertical: Gravity.Vertical = .center
        let languageDirection: LanguageDirection = .leftToRight
        
        let container: CGRect = CGRect(x: 0, y: 0, width: 320, height: 568)
        
        // ** rect_A
        
        let rect_A: CGRect = CGRect(x: 0, y: 0, width: 1242, height: 2688)
        
        let expectedRendered_rect_A: CGRect = CGRect(x: 0, y: -62, width: 320, height: 692)
        
        let rendered_rect_A: CGRect = backgroundImageRenderer.getBackgroundImageRectForRenderingInContainer(
            container: container,
            backgroundImageSizePixels: rect_A.size,
            scale: scale,
            horizontal: horizontal,
            vertical: vertical,
            languageDirection: languageDirection
        )
        
        assertFailureIfExpectedRectIsNotEqualToRenderedRect(renderedRect: rendered_rect_A, expectedRect: expectedRendered_rect_A)
        
        // ** rect_B
        
        let rect_B: CGRect = CGRect(x: 0, y: 0, width: 2688, height: 1242)
        
        let expectedRendered_rect_B: CGRect = CGRect(x: -454, y: 0, width: 1229, height: 568)
        
        let rendered_rect_B: CGRect = backgroundImageRenderer.getBackgroundImageRectForRenderingInContainer(
            container: container,
            backgroundImageSizePixels: rect_B.size,
            scale: scale,
            horizontal: horizontal,
            vertical: vertical,
            languageDirection: languageDirection
        )
        
        assertFailureIfExpectedRectIsNotEqualToRenderedRect(renderedRect: rendered_rect_B, expectedRect: expectedRendered_rect_B)
        
        // ** rect_C
        
        let rect_C: CGRect = CGRect(x: 0, y: 0, width: 120, height: 120)
        
        let expectedRendered_rect_C: CGRect = CGRect(x: -124, y: 0, width: 568, height: 568)
        
        let rendered_rect_C: CGRect = backgroundImageRenderer.getBackgroundImageRectForRenderingInContainer(
            container: container,
            backgroundImageSizePixels: rect_C.size,
            scale: scale,
            horizontal: horizontal,
            vertical: vertical,
            languageDirection: languageDirection
        )
        
        assertFailureIfExpectedRectIsNotEqualToRenderedRect(renderedRect: rendered_rect_C, expectedRect: expectedRendered_rect_C)
        
        // ** rect_D
        
        let rect_D: CGRect = CGRect(x: 0, y: 0, width: 55, height: 1400)
        
        let expectedRendered_rect_D: CGRect = CGRect(x:0, y: -3788, width: 320, height: 8145)
        
        let rendered_rect_D: CGRect = backgroundImageRenderer.getBackgroundImageRectForRenderingInContainer(
            container: container,
            backgroundImageSizePixels: rect_D.size,
            scale: scale,
            horizontal: horizontal,
            vertical: vertical,
            languageDirection: languageDirection
        )
        
        assertFailureIfExpectedRectIsNotEqualToRenderedRect(renderedRect: rendered_rect_D, expectedRect: expectedRendered_rect_D)
        
        // ** rect_E
        
        let rect_E: CGRect = CGRect(x: 0, y: 0, width: 1800, height: 200)
        
        let expectedRendered_rect_E: CGRect = CGRect(x:-2396, y: 0, width: 5112, height: 568)
        
        let rendered_rect_E: CGRect = backgroundImageRenderer.getBackgroundImageRectForRenderingInContainer(
            container: container,
            backgroundImageSizePixels: rect_E.size,
            scale: scale,
            horizontal: horizontal,
            vertical: vertical,
            languageDirection: languageDirection
        )
        
        assertFailureIfExpectedRectIsNotEqualToRenderedRect(renderedRect: rendered_rect_E, expectedRect: expectedRendered_rect_E)
    }
    
    func testIphone11BackgroundImageWithAlignBottomAndFillHorizontally() {
        
        let backgroundImageRenderer: MobileContentBackgroundImageRenderer = MobileContentBackgroundImageRenderer()
        
        let scale: ImageScaleType = .fillX
        let horizontal: Gravity.Horizontal = .center
        let vertical: Gravity.Vertical = .bottom
        let languageDirection: LanguageDirection = .leftToRight
        
        let container: CGRect = CGRect(x: 0, y: 0, width: 414, height: 896)
        
        // ** rect_A
        
        let rect_A: CGRect = CGRect(x: 0, y: 0, width: 1080, height: 1920)
        
        let expectedRendered_rect_A: CGRect = CGRect(x: 0, y: 160, width: 414, height: 736)
        
        let rendered_rect_A: CGRect = backgroundImageRenderer.getBackgroundImageRectForRenderingInContainer(
            container: container,
            backgroundImageSizePixels: rect_A.size,
            scale: scale,
            horizontal: horizontal,
            vertical: vertical,
            languageDirection: languageDirection
        )
        
        assertFailureIfExpectedRectIsNotEqualToRenderedRect(renderedRect: rendered_rect_A, expectedRect: expectedRendered_rect_A)
    }
}
