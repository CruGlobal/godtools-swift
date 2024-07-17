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
    
    init() {
        
    }
    
    func getBackgroundImageRectForRenderingInContainer(container: CGRect, backgroundImageSizePixels: CGSize, scale: ImageScaleType, horizontal: Gravity.Horizontal, vertical: Gravity.Vertical, languageDirection: LanguageDirectionDomainModel) -> CGRect {
        
        let scaledRect: CGRect = scaleRectToContainer(
            container: container,
            rect: CGRect(x: 0, y: 0, width: backgroundImageSizePixels.width, height: backgroundImageSizePixels.height),
            scale: scale
        )
        
        let scaledAndPositioned: CGRect = positionRectInContainer(
            container: container,
            rect: scaledRect,
            horizontal: horizontal,
            vertical: vertical,
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
    
    private func positionRectInContainer(container: CGRect, rect: CGRect, horizontal: Gravity.Horizontal, vertical: Gravity.Vertical, languageDirection: LanguageDirectionDomainModel) -> CGRect {
        
        var positionedRect: CGRect = rect
        
        switch horizontal {
        
        case .start:
            positionedRect = positionRectInContainer(container: container, rect: positionedRect, align: .start, languageDirection: languageDirection)
        
        case .end:
            positionedRect = positionRectInContainer(container: container, rect: positionedRect, align: .end, languageDirection: languageDirection)
       
        case .center:
            positionedRect = centerRectHorizontallyInContainer(container: container, rect: positionedRect)
            
        default:
            positionedRect = centerRectHorizontallyInContainer(container: container, rect: positionedRect)
        }
        
        switch vertical {
        
        case .top:
            positionedRect = positionRectInContainer(container: container, rect: positionedRect, align: .top, languageDirection: languageDirection)
            
        case .bottom:
            positionedRect = positionRectInContainer(container: container, rect: positionedRect, align: .bottom, languageDirection: languageDirection)
            
        case .center:
            positionedRect = centerRectVerticallyInContainer(container: container, rect: positionedRect)
            
        default:
            positionedRect = centerRectVerticallyInContainer(container: container, rect: positionedRect)
        }
        
        return positionedRect
    }
}
