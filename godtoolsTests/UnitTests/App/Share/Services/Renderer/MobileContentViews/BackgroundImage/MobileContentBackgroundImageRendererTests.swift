//
//  MobileContentBackgroundImageRendererTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 3/4/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import Testing
import GodToolsShared
@testable import godtools

struct BackgroundImageRenderArgument: Sendable {

    let backgroundImageSizePixels: CGSize
    let expectedRect: CGRect
}

struct MobileContentBackgroundImageRendererTests {

    private static let iphoneSEContainer: CGRect = CGRect(x: 0, y: 0, width: 320, height: 568)
    private static let iphone11Container: CGRect = CGRect(x: 0, y: 0, width: 414, height: 896)

    private let backgroundImageRenderer: MobileContentBackgroundImageRenderer = MobileContentBackgroundImageRenderer()

    @Test(
        """
        Given: A background image is rendered in a container.
        When: The image is scaled to fit and aligned to the center.
        Then: The rendered rect should fit within the container and be centered.
        """,
        arguments: [
            BackgroundImageRenderArgument(
                backgroundImageSizePixels: CGSize(width: 1242, height: 2688),
                expectedRect: CGRect(x: 28, y: 0, width: 262, height: 568)
            ),
            BackgroundImageRenderArgument(
                backgroundImageSizePixels: CGSize(width: 2688, height: 1242),
                expectedRect: CGRect(x: 0, y: 210, width: 320, height: 147)
            ),
            BackgroundImageRenderArgument(
                backgroundImageSizePixels: CGSize(width: 120, height: 120),
                expectedRect: CGRect(x: 0, y: 124, width: 320, height: 320)
            ),
            BackgroundImageRenderArgument(
                backgroundImageSizePixels: CGSize(width: 55, height: 1400),
                expectedRect: CGRect(x: 148, y: 0, width: 22, height: 568)
            ),
            BackgroundImageRenderArgument(
                backgroundImageSizePixels: CGSize(width: 1800, height: 200),
                expectedRect: CGRect(x: 0, y: 266, width: 320, height: 35)
            )
        ]
    )
    func rectIsPositionedCorrectlyInContainerWithScaleFitAndAlignCenter(argument: BackgroundImageRenderArgument) {

        let renderedRect: CGRect = backgroundImageRenderer.getBackgroundImageRectForRenderingInContainer(
            container: Self.iphoneSEContainer,
            backgroundImageSizePixels: argument.backgroundImageSizePixels,
            scale: .fit,
            horizontal: .center,
            vertical: .center,
            languageDirection: .leftToRight
        )

        #expect(renderedRect == argument.expectedRect)
    }

    @Test(
        """
        Given: A background image is rendered in a container.
        When: The image is scaled to fill and aligned to the center.
        Then: The rendered rect should fill the container and be centered.
        """,
        arguments: [
            BackgroundImageRenderArgument(
                backgroundImageSizePixels: CGSize(width: 1242, height: 2688),
                expectedRect: CGRect(x: 0, y: -62, width: 320, height: 692)
            ),
            BackgroundImageRenderArgument(
                backgroundImageSizePixels: CGSize(width: 2688, height: 1242),
                expectedRect: CGRect(x: -454, y: 0, width: 1229, height: 568)
            ),
            BackgroundImageRenderArgument(
                backgroundImageSizePixels: CGSize(width: 120, height: 120),
                expectedRect: CGRect(x: -124, y: 0, width: 568, height: 568)
            ),
            BackgroundImageRenderArgument(
                backgroundImageSizePixels: CGSize(width: 55, height: 1400),
                expectedRect: CGRect(x: 0, y: -3788, width: 320, height: 8145)
            ),
            BackgroundImageRenderArgument(
                backgroundImageSizePixels: CGSize(width: 1800, height: 200),
                expectedRect: CGRect(x: -2396, y: 0, width: 5112, height: 568)
            )
        ]
    )
    func rectIsPositionedCorrectlyInContainerWithScaleFillAndAlignCenter(argument: BackgroundImageRenderArgument) {

        let renderedRect: CGRect = backgroundImageRenderer.getBackgroundImageRectForRenderingInContainer(
            container: Self.iphoneSEContainer,
            backgroundImageSizePixels: argument.backgroundImageSizePixels,
            scale: .fill,
            horizontal: .center,
            vertical: .center,
            languageDirection: .leftToRight
        )

        #expect(renderedRect == argument.expectedRect)
    }

    @Test(
        """
        Given: A background image is rendered in an iPhone 11 sized container.
        When: The image is scaled to fill horizontally and aligned to the bottom.
        Then: The rendered rect should fill the container's width and be anchored to the bottom.
        """
    )
    func iphone11BackgroundImageWithAlignBottomAndFillHorizontally() {

        let expectedRect: CGRect = CGRect(x: 0, y: 160, width: 414, height: 736)

        let renderedRect: CGRect = backgroundImageRenderer.getBackgroundImageRectForRenderingInContainer(
            container: Self.iphone11Container,
            backgroundImageSizePixels: CGSize(width: 1080, height: 1920),
            scale: .fillX,
            horizontal: .center,
            vertical: .bottom,
            languageDirection: .leftToRight
        )

        #expect(renderedRect == expectedRect)
    }
}
