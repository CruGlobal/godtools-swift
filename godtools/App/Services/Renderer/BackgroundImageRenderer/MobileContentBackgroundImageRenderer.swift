//
//  MobileContentBackgroundImageRenderer.swift
//  godtools
//
//  Created by Levi Eggert on 3/4/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentBackgroundImageRenderer: MobileContentBackgroundImageRendererType {
    
    required init() {
        
    }
    
    func getBackgroundImageRectForRenderingInContainer(container: CGRect, backgroundImageSizePixels: CGSize, scale: ImageScaleType, alignment: Gravity, languageDirection: LanguageDirection) -> CGRect {
        
        let scaledRect: CGRect = scaleRectToContainer(
            container: container,
            rect: CGRect(x: 0, y: 0, width: backgroundImageSizePixels.width, height: backgroundImageSizePixels.height),
            scale: scale
        )
        
        let scaledAndPositioned: CGRect = positionRectInContainer(
            container: container,
            rect: scaledRect,
            alignment: alignment,
            languageDirection: languageDirection
        )
        
        return floorRect(rect: scaledAndPositioned)
    }
        
    private func scaleRectToContainer(container: CGRect, rect: CGRect, scale: ImageScaleType) -> CGRect {
        
        switch scale {
        
        case .fit:
            return scaleRectToFitContainer(container: container, rect: rect)
        
        case .fill:
            return scaleRectToFillContainer(container: container, rect: rect)
                    
        case .fillX:
            return scaleRectToHorizontallyFitContainer(container: container, rect: rect)
        
        case .fillY:
            return scaleRectToVerticallyFitContainer(container: container, rect: rect)
            
        default:
            return scaleRectToFitContainer(container: container, rect: rect)
        }
    }
    
    private func positionRectInContainer(container: CGRect, rect: CGRect, alignment: Gravity, languageDirection: LanguageDirection) -> CGRect {
        
        var positionedRect: CGRect = rect
        
        if alignment.isStart {
            positionedRect = positionRectInContainer(container: container, rect: positionedRect, align: .start, languageDirection: languageDirection)
        }
        else if alignment.isEnd {
            positionedRect = positionRectInContainer(container: container, rect: positionedRect, align: .end, languageDirection: languageDirection)
        }
        else if alignment.isCenterX {
            positionedRect = centerRectHorizontallyInContainer(container: container, rect: positionedRect)
        }
        
        if alignment.isTop {
            positionedRect = positionRectInContainer(container: container, rect: positionedRect, align: .top, languageDirection: languageDirection)
        }
        else if alignment.isBottom {
            positionedRect = positionRectInContainer(container: container, rect: positionedRect, align: .bottom, languageDirection: languageDirection)
        }
        else if alignment.isCenterY {
            positionedRect = centerRectVerticallyInContainer(container: container, rect: positionedRect)
        }
        
        if alignment.isCenter {
            positionedRect = centerRectInContainer(container: container, rect: positionedRect)
        }
        
        return positionedRect
    }
}
