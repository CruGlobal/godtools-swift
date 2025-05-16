//
//  FullScreenOverlayView.swift
//  godtools
//
//  Created by Levi Eggert on 5/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import SwiftUI

struct FullScreenOverlayView: View {
    
    private let color: Color
    private let tappedClosure: (() -> Void)?
    
    init(color: Color? = nil, tappedClosure: (() -> Void)? = nil) {
        
        self.color = color ?? Color.black.opacity(0.4)
        self.tappedClosure = tappedClosure
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            let overlaySize: CGSize = geometry.size
            
            Button(action: {
                
                tappedClosure?()
            }) {
                
                ZStack(alignment: .leading) {
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: overlaySize.width, height: overlaySize.height)
                }
            }
            .frame(width: overlaySize.width, height: overlaySize.height)
            
            
        }
        .ignoresSafeArea()
    }
}
