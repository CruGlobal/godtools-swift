//
//  BackgroundImageModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/15/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

protocol BackgroundImageModelType {
    
    var backgroundImage: String? { get }
    var backgroundImageAlignment: MobileContentImageAlignmentType { get }
    var backgroundImageScale: ImageScaleType { get }
}

extension BackgroundImageModelType {
    
    var backgroundImageExists: Bool {
        if let backgroundImage = self.backgroundImage {
            return !backgroundImage.isEmpty
        }
        return false
    }
    
    func getImageAlignment(alignments: [MobileContentBackgroundImageAlignment]) -> MobileContentImageAlignmentType {
        
        var isCenter: Bool = false
        var isCenterX: Bool = false
        var isCenterY: Bool = false
        var isStart: Bool = false
        var isEnd: Bool = false
        var isTop: Bool = false
        var isBottom: Bool = false
        
        if alignments.isEmpty {
            
            isStart = true
            isTop = true
        }
        else if alignments.count == 1, let singleAlignment = alignments.first {
            
            switch singleAlignment {
            case .start:
                isStart = true
            case .end:
                isEnd = true
            case .top:
                isTop = true
            case .bottom:
                isBottom = true
            case .center:
                isCenter = true
            }
        }
        else {
            
            let containsCenterAlign: Bool = alignments.contains(.center)
            var containsAllCenterAlignments: Bool = true
            var didPositionHorizontally: Bool = false
            var didPositionVertically: Bool = false
                        
            for align in alignments {
                
                if align != .center {
                    containsAllCenterAlignments = false
                }
                
                if (align == .start || align == .end) && !didPositionHorizontally {
                    
                    didPositionHorizontally = true
                    
                    if align == .start {
                        isStart = true
                    }
                    else if align == .end {
                        isEnd = true
                    }
                }
                else if (align == .top || align == .bottom) && !didPositionVertically {
                    
                    didPositionVertically = true
                    
                    if align == .top {
                        isTop = true
                    }
                    else if align == .bottom {
                        isBottom = true
                    }
                }
            }
            
            if containsAllCenterAlignments {
                isCenter = true
            }
            else if didPositionHorizontally && containsCenterAlign && !didPositionVertically {
                isCenterY = true
            }
            else if didPositionHorizontally && containsCenterAlign && !didPositionHorizontally {
                isCenterX = true
            }
        }
        
        return MobileContentImageAlignment(
            isCenter: isCenter,
            isCenterX: isCenterX,
            isCenterY: isCenterY,
            isStart: isStart,
            isEnd: isEnd,
            isTop: isTop,
            isBottom: isBottom
        )
    }
}
