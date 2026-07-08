//
//  EqualWidthHStack.swift
//  godtools
//
//  Created by Rachael Skeath on 1/6/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import SwiftUI

struct EqualWidthHStack: Layout {
    
    private let spacing: CGFloat
    private let maxContainerWidth: CGFloat?
    
    init(spacing: CGFloat = 0, maxContainerWidth: CGFloat? = nil) {
        
        self.spacing = spacing
        self.maxContainerWidth = maxContainerWidth
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {

        guard !subviews.isEmpty else {
            return .zero
        }

        let maxWidth = getMaxWidth(subviews: subviews)
        let height = subviews.first?.sizeThatFits(.unspecified).height ?? 0
        
        let totalWidth = maxWidth * CGFloat(subviews.count) + spacing * CGFloat(subviews.count - 1)

        return CGSize(width: totalWidth, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {

        guard !subviews.isEmpty else {
            return
        }

        let maxWidth = getMaxWidth(subviews: subviews)

        var x = bounds.minX
        
        for subview in subviews {
            subview.place(at: CGPoint(x: x, y: bounds.minY), proposal: ProposedViewSize(width: maxWidth, height: nil))
            x += maxWidth + spacing
        }
    }
    
    private func getMaxWidth(subviews: Subviews) -> CGFloat {
        
        let maxWidth = subviews.map { $0.sizeThatFits(.unspecified).width }.max() ?? 0
        
        if let maxContainerWidth = getMaxAllowedWidthForContainer(subviews: subviews), maxWidth > maxContainerWidth {
            return maxContainerWidth
        }
        
        return maxWidth
    }
    
    private func getMaxAllowedWidthForContainer(subviews: Subviews) -> CGFloat? {
        
        guard let maxContainerWidth = self.maxContainerWidth, maxContainerWidth > 0 else {
            return nil
        }
        
        return maxContainerWidth / CGFloat(subviews.count)
    }
}
