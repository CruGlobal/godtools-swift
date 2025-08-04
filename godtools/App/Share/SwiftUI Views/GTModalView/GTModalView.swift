//
//  GTModalView.swift
//  godtools
//
//  Created by Rachael Skeath on 7/3/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import SwiftUI
import UIKit

struct GTModalView<Content: View>: View {
    
    private let content: (_ geometry: GeometryProxy) -> Content
    private let overlayTappedClosure: (() -> Void)?
    private let backgroundColor: Color = Color.white
    private let backgroundCornerRadius: CGFloat = 12
    private let backgroundHorizontalPadding: CGFloat = 10
    private let contentAnimationDuration: TimeInterval = 0.4
    
    @State private var overlayOpacity: CGFloat = 0
    @State private var contentBottomOffsetY: CGFloat = UIScreen.main.bounds.size.height
    @State private var contentHeight: CGFloat = 100
    
    init(@ViewBuilder content: @escaping (_ geometry: GeometryProxy) -> Content, overlayTappedClosure: (() -> Void)?) {
        
        self.content = content
        self.overlayTappedClosure = overlayTappedClosure
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            FullScreenOverlayView(tappedClosure: {
                
                setContentHidden()
                overlayTappedClosure?()
            })
            .opacity(overlayOpacity)
            .animation(.easeOut(duration: contentAnimationDuration), value: overlayOpacity)
            
            ZStack(alignment: .bottom) {
                
                Color.clear
                
                ZStack(alignment: .top) {
                                              
                    VStack(alignment: .leading, spacing: 0) {
                                 
                       content(geometry)
                            .background(
                                GeometryReader { contentGeometry -> Color in
                                    DispatchQueue.main.async {
                                        
                                        contentHeight = contentGeometry.size.height
                                        
                                        if isHidden {
                                            contentBottomOffsetY = contentHeight
                                        }
                                    }
                                    return Color.clear
                                }
                            )
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
                .offset(y: contentBottomOffsetY)
                .animation(.easeOut(duration: contentAnimationDuration), value: contentBottomOffsetY)
            }
        }
        .onAppear {
            setContentVisible()
        }
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
    }
    
    private var isHidden: Bool {
        return overlayOpacity == 0
    }
    
    private func setContentVisible() {
        overlayOpacity = 1
        contentBottomOffsetY = 0 // Set to 0 since the content uses a ZStack with alignment bottom.  This will place the content bottom at the bottom of the screen. ~Levi
    }
    
    private func setContentHidden() {
        overlayOpacity = 0
        contentBottomOffsetY = contentHeight
    }
}
