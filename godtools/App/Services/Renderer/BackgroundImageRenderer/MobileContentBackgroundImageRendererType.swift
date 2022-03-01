//
//  MobileContentBackgroundImageRendererType.swift
//  godtools
//
//  Created by Levi Eggert on 8/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

protocol MobileContentBackgroundImageRendererType {
    
    func getBackgroundImageRectForRenderingInContainer(container: CGRect, backgroundImageSizePixels: CGSize, scale: ImageScaleType, horizontal: Gravity.Horizontal, vertical: Gravity.Vertical, languageDirection: LanguageDirection) -> CGRect
}

extension MobileContentBackgroundImageRendererType {
    
    // MARK: - Floor Rect
    
    func floorRect(rect: CGRect) -> CGRect {
        
        return CGRect(
            x: floorValue(value: rect.origin.x),
            y: floorValue(value: rect.origin.y),
            width: floorValue(value: rect.size.width),
            height: floorValue(value: rect.size.height)
        )
    }
    
    func floorValue(value: CGFloat) -> CGFloat {
        
        if value < 0 {
            return ceil(value)
        }
        
        return floor(value)
    }
    
    // MARK: - Scaling Rect
    
    func scaleRectToFitContainer(container: CGRect, rect: CGRect) -> CGRect {
        
        let scaleX: CGFloat = container.size.width / rect.size.width
        let scaleY: CGFloat = container.size.height / rect.size.height
        
        if scaleX < scaleY {
            return scaleRectToHorizontallyFitContainer(container: container, rect: rect)
        }
        else if scaleY < scaleX {
            return scaleRectToVerticallyFitContainer(container: container, rect: rect)
        }
        
        return container
    }
    
    func scaleRectToFillContainer(container: CGRect, rect: CGRect) -> CGRect {
        
        let scaleX: CGFloat = container.size.width / rect.size.width
        let scaleY: CGFloat = container.size.height / rect.size.height
        
        if scaleX > scaleY {
            return scaleRectToHorizontallyFitContainer(container: container, rect: rect)
        }
        else if scaleY > scaleX {
            return scaleRectToVerticallyFitContainer(container: container, rect: rect)
        }
        
        return container
    }
    
    func scaleRectToHorizontallyFitContainer(container: CGRect, rect: CGRect) -> CGRect {
        
        let scaledRect: CGRect
        
        let scaleX: CGFloat = container.size.width / rect.size.width
        
        scaledRect = CGRect(
            x: 0,
            y: 0,
            width: scaleX * rect.size.width,
            height: scaleX * rect.size.height
        )
        
        return scaledRect
    }
    
    func scaleRectToVerticallyFitContainer(container: CGRect, rect: CGRect) -> CGRect {
        
        let scaledRect: CGRect
        
        let scaleY: CGFloat = container.size.height / rect.size.height
        
        scaledRect = CGRect(
            x: 0,
            y: 0,
            width: scaleY * rect.size.width,
            height: scaleY * rect.size.height
        )
        
        return scaledRect
    }
    
    // MARK: - Positioning Rect
    
    func positionRectInContainer(container: CGRect, rect: CGRect, align: MobileContentBackgroundImageAlignment, languageDirection: LanguageDirection) -> CGRect {
        
        switch align {
            
        case .start:
            switch languageDirection {
            case .leftToRight:
                return positionRectToStartOfContainer(container: container, rect: rect)
            case .rightToLeft:
                return positionRectToEndOfContainer(container: container, rect: rect)
            }
        
        case .end:
            switch languageDirection {
            case .leftToRight:
                return positionRectToEndOfContainer(container: container, rect: rect)
            case .rightToLeft:
                return positionRectToStartOfContainer(container: container, rect: rect)
            }
            
        case .top:
            return positionRectToTopOfContainer(container: container, rect: rect)
            
        case .bottom:
            return positionRectToBottomOfContainer(container: container, rect: rect)
            
        case .center:
            return centerRectInContainer(container: container, rect: rect)
        }
    }
    
    func positionRectToStartOfContainer(container: CGRect, rect: CGRect) -> CGRect {
        
        let xPosition: CGFloat = 0
        
        return CGRect(
            x: xPosition,
            y: rect.origin.y,
            width: rect.size.width,
            height: rect.size.height
        )
    }
    
    func positionRectToEndOfContainer(container: CGRect, rect: CGRect) -> CGRect {
        
        let xPosition: CGFloat = container.size.width - rect.size.width
        
        return CGRect(
            x: xPosition,
            y: rect.origin.y,
            width: rect.size.width,
            height: rect.size.height
        )
    }
    
    func positionRectToTopOfContainer(container: CGRect, rect: CGRect) -> CGRect {
        
        let yPosition: CGFloat = 0
        
        return CGRect(
            x: rect.origin.x,
            y: yPosition,
            width: rect.size.width,
            height: rect.size.height
        )
    }
    
    func positionRectToBottomOfContainer(container: CGRect, rect: CGRect) -> CGRect {
        
        let yPosition: CGFloat = container.size.height - rect.size.height
        
        return CGRect(
            x: rect.origin.x,
            y: yPosition,
            width: rect.size.width,
            height: rect.size.height
        )
    }
    
    func centerRectInContainer(container: CGRect, rect: CGRect) -> CGRect {
        
        return CGRect(
            x: centerRectHorizontallyInContainer(container: container, rect: rect).origin.x,
            y: centerRectVerticallyInContainer(container: container, rect: rect).origin.y,
            width: rect.size.width,
            height: rect.size.height
        )
    }
    
    func centerRectHorizontallyInContainer(container: CGRect, rect: CGRect) -> CGRect {
        
        let xPosition: CGFloat = (container.size.width - rect.size.width) / 2
        
        return CGRect(
            x: xPosition,
            y: rect.origin.y,
            width: rect.size.width,
            height: rect.size.height
        )
    }
    
    func centerRectVerticallyInContainer(container: CGRect, rect: CGRect) -> CGRect {
        
        let yPosition: CGFloat = (container.size.height - rect.size.height) / 2
        
        return CGRect(
            x: rect.origin.x,
            y: yPosition,
            width: rect.size.width,
            height: rect.size.height
        )
    }
}
