//
//  MobileContentBackgroundImageRenderer.swift
//  godtools
//
//  Created by Levi Eggert on 3/4/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentBackgroundImageRenderer {
    
    required init() {
        
    }
    
    func getBackgroundImageRectForRenderingInContainer(container: CGRect, backgroundImageSizePixels: CGSize, backgroundImageNode: BackgroundImageNodeType) -> CGRect? {
        
        guard let scale = MobileContentBackgroundImageScaleType(rawValue: backgroundImageNode.backgroundImageScaleType) else {
            return nil
        }
        
        let alignments: [MobileContentBackgroundImageAlignType] = backgroundImageNode.backgroundImageAlign.compactMap({MobileContentBackgroundImageAlignType(rawValue: $0)})
        
        let scaledRect: CGRect = scaleRectToContainer(
            container: container,
            rect: CGRect(x: 0, y: 0, width: backgroundImageSizePixels.width, height: backgroundImageSizePixels.height),
            scale: scale
        )
        
        let scaledAndPositioned: CGRect = positionRectInContainer(
            container: container,
            rect: scaledRect,
            alignments: alignments
        )
        
        return scaledAndPositioned
    }
    
    // MARK: - Scale
    
    func scaleRectToContainer(container: CGRect, rect: CGRect, scale: MobileContentBackgroundImageScaleType) -> CGRect {
        
        switch scale {
        
        case .fit:
            return scaleRectToFitContainer(container: container, rect: rect)
        
        case .fill:
            return scaleRectToFillContainer(container: container, rect: rect)
        
        case .fillHorizontally:
            return scaleRectToHorizontallyFitContainer(container: container, rect: rect)
        
        case .fillVertically:
            return scaleRectToVerticallyFitContainer(container: container, rect: rect)
        }
    }
    
    private func scaleRectToFitContainer(container: CGRect, rect: CGRect) -> CGRect {
        
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
    
    private func scaleRectToFillContainer(container: CGRect, rect: CGRect) -> CGRect {
        
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
    
    private func scaleRectToHorizontallyFitContainer(container: CGRect, rect: CGRect) -> CGRect {
        
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
    
    private func scaleRectToVerticallyFitContainer(container: CGRect, rect: CGRect) -> CGRect {
        
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
    
    // MARK: - Position
    
    func positionRectInContainer(container: CGRect, rect: CGRect, alignments: [MobileContentBackgroundImageAlignType]) -> CGRect {
        
        guard let firstAlignment: MobileContentBackgroundImageAlignType = alignments.first else {
            return rect
        }
                
        if alignments.count == 1 {
            return positionRectInContainer(container: container, rect: rect, align: firstAlignment)
        }
        
        let containsCenterAlign: Bool = alignments.contains(.center)
        var containsAllCenterAlignments: Bool = true
        var didPositionHorizontally: Bool = false
        var didPositionVertically: Bool = false
        
        var positionedRect: CGRect = rect
        
        for align in alignments {
            
            if align != .center {
                containsAllCenterAlignments = false
            }
            
            if (align == .start || align == .end) && !didPositionHorizontally {
                
                didPositionHorizontally = true
                
                positionedRect = positionRectInContainer(container: container, rect: positionedRect, align: align)
            }
            else if (align == .top || align == .bottom) && !didPositionVertically {
                
                didPositionVertically = true
                
                positionedRect = positionRectInContainer(container: container, rect: positionedRect, align: align)
            }
        }
        
        if containsAllCenterAlignments {
            
            return centerRectInContainer(container: container, rect: rect)
        }
        else if didPositionHorizontally && containsCenterAlign && !didPositionVertically {
            
            positionedRect = centerRectVerticallyInContainer(container: container, rect: positionedRect)
        }
        else if didPositionHorizontally && containsCenterAlign && !didPositionHorizontally {
            
            positionedRect = centerRectHorizontallyInContainer(container: container, rect: rect)
        }
        
        return positionedRect
    }
    
    private func positionRectInContainer(container: CGRect, rect: CGRect, align: MobileContentBackgroundImageAlignType) -> CGRect {
        
        switch align {
            
        case .start:
            return positionRectToStartOfContainer(container: container, rect: rect)
            
        case .end:
            return positionRectToEndOfContainer(container: container, rect: rect)
            
        case .top:
            return positionRectToTopOfContainer(container: container, rect: rect)
            
        case .bottom:
            return positionRectToBottomOfContainer(container: container, rect: rect)
            
        case .center:
            return centerRectInContainer(container: container, rect: rect)
        }
    }
    
    private func positionRectToStartOfContainer(container: CGRect, rect: CGRect) -> CGRect {
        
        let xPosition: CGFloat = 0
        
        return CGRect(
            x: xPosition,
            y: rect.origin.y,
            width: rect.size.width,
            height: rect.size.height
        )
    }
    
    private func positionRectToEndOfContainer(container: CGRect, rect: CGRect) -> CGRect {
        
        let xPosition: CGFloat = container.size.width - rect.size.width
        
        return CGRect(
            x: xPosition,
            y: rect.origin.y,
            width: rect.size.width,
            height: rect.size.height
        )
    }
    
    private func positionRectToTopOfContainer(container: CGRect, rect: CGRect) -> CGRect {
        
        let yPosition: CGFloat = 0
        
        return CGRect(
            x: rect.origin.x,
            y: yPosition,
            width: rect.size.width,
            height: rect.size.height
        )
    }
    
    private func positionRectToBottomOfContainer(container: CGRect, rect: CGRect) -> CGRect {
        
        let yPosition: CGFloat = container.size.height - rect.size.height
        
        return CGRect(
            x: rect.origin.x,
            y: yPosition,
            width: rect.size.width,
            height: rect.size.height
        )
    }
    
    private func centerRectInContainer(container: CGRect, rect: CGRect) -> CGRect {
        
        return CGRect(
            x: centerRectHorizontallyInContainer(container: container, rect: rect).origin.x,
            y: centerRectVerticallyInContainer(container: container, rect: rect).origin.y,
            width: rect.size.width,
            height: rect.size.height
        )
    }
    
    private func centerRectHorizontallyInContainer(container: CGRect, rect: CGRect) -> CGRect {
        
        let xPosition: CGFloat = (container.size.width / 2) - (rect.size.width / 2)
        
        return CGRect(
            x: xPosition,
            y: rect.origin.y,
            width: rect.size.width,
            height: rect.size.height
        )
    }
    
    private func centerRectVerticallyInContainer(container: CGRect, rect: CGRect) -> CGRect {
        
        let yPosition: CGFloat = (container.size.height / 2) - (rect.size.height / 2)
        
        return CGRect(
            x: rect.origin.x,
            y: yPosition,
            width: rect.size.width,
            height: rect.size.height
        )
    }
}
