//
//  EqualWidthHStack.swift
//  godtools
//
//  Created by Rachael Skeath on 1/6/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import SwiftUI

@available(iOS 16.0, *)
struct EqualWidthHStack: Layout {
    
    var spacing: CGFloat = 0

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        
        guard !subviews.isEmpty else { return .zero }

        let maxWidth = subviews.map { $0.sizeThatFits(.unspecified).width }.max() ?? 0
        let maxHeight = subviews.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
        let totalWidth = maxWidth * CGFloat(subviews.count) + spacing * CGFloat(subviews.count - 1)

        return CGSize(width: totalWidth, height: maxHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        
        guard !subviews.isEmpty else { return }

        let maxWidth = subviews.map { $0.sizeThatFits(.unspecified).width }.max() ?? 0
        let maxHeight = subviews.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0

        var x = bounds.minX
        for subview in subviews {
            let proposal = ProposedViewSize(width: maxWidth, height: maxHeight)
            subview.place(at: CGPoint(x: x, y: bounds.minY), proposal: proposal)
            x += maxWidth + spacing
        }
    }
}
