//
//  SegmentControl.swift
//  godtools
//
//  Created by Levi Eggert on 6/11/22.
//

import SwiftUI

struct SegmentControl: View {
    
    private let segmentSpacing: CGFloat = 30
    
    @Binding var selectedIndex: Int?
    
    let segments: [String]
    let segmentTappedClosure: ((_ index: Int) -> Void)
    
    var body: some View {
        
        HStack(alignment: .top, spacing: segmentSpacing) {
            
            ForEach((0 ..< segments.count), id: \.self) { index in
                
                Segment(text: segments[index], index: index, selectedIndex: $selectedIndex, tappedClosure: { (index: Int) in
                    segmentTappedClosure(index)
                })
            }
        }
    }
}
