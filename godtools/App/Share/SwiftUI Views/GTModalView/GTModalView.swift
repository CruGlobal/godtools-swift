//
//  GTModalView.swift
//  godtools
//
//  Created by Rachael Skeath on 7/3/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import SwiftUI

struct GTModalView<Content: View>: View {
    
    private let content: Content
    private let overlayTappedClosure: (() -> Void)?
    
    private let backgroundColor: Color = Color.white
    private let backgroundCornerRadius: CGFloat = 12
    private let backgroundHorizontalPadding: CGFloat = 10
    
    @State private var isVisible: Bool = false
    
    init(@ViewBuilder content: () -> Content, overlayTappedClosure: (() -> Void)? = nil) {
        
        self.content = content()
        self.overlayTappedClosure = overlayTappedClosure
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            FullScreenOverlayView(tappedClosure: {
                
                setIsVisible(isVisible: false)
                
                overlayTappedClosure?()
            })
            .opacity(isVisible ? 1 : 0)
            
            ZStack(alignment: .bottom) {
                
                Color.clear
                
                ZStack(alignment: .top) {
                                              
                    VStack(alignment: .leading, spacing: 0) {
                                 
                       content
                          
                    }
                    .background(
                        RoundedRectangle(cornerRadius: backgroundCornerRadius)
                            .overlay(
                                RoundedRectangle(cornerRadius: backgroundCornerRadius)
                                    .foregroundStyle(backgroundColor)
                            )
                            .padding(.leading, backgroundHorizontalPadding)
                            .padding(.trailing, backgroundHorizontalPadding)
                    )
                }
                .offset(y: !isVisible ? geometry.size.height * 0.75 : 0)
                
            }
        }
        .onAppear {
            setIsVisible(isVisible: true)
        }
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
    }
    
    private func setIsVisible(isVisible: Bool) {
        withAnimation {
            self.isVisible = isVisible
        }
    }
}
