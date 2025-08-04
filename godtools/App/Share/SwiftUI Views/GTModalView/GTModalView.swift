//
//  GTModalView.swift
//  godtools
//
//  Created by Rachael Skeath on 7/3/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import SwiftUI

struct GTModalView<Content: View>: View {
    
    private let content: (_ geometry: GeometryProxy) -> Content
    private let overlayTappedClosure: (() -> Void)?
    private let backgroundColor: Color = Color.white
    private let backgroundCornerRadius: CGFloat = 12
    private let backgroundHorizontalPadding: CGFloat = 10
    private let contentAnimationDuration: TimeInterval = 0.3
    
    @State private var overlayOpacity: CGFloat = 0
    @State private var contentBottomOffsetY: CGFloat = 1000
    @State private var contentHeight: CGFloat = 100
    
    @Binding private var isHidden: Bool
    
    init(@ViewBuilder content: @escaping (_ geometry: GeometryProxy) -> Content, isHidden: Binding<Bool>, overlayTappedClosure: (() -> Void)?) {
        
        self.content = content
        self._isHidden = isHidden
        self.overlayTappedClosure = overlayTappedClosure
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            FullScreenOverlayView(tappedClosure: {
                
                isHidden = true
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
                                        
                                        let currentContentHeight: CGFloat = self.contentHeight
                                        let newContentHeight: CGFloat = contentGeometry.size.height
                                        
                                        if currentContentHeight != newContentHeight {
                                            
                                            contentHeight = contentGeometry.size.height
                                            
                                            if isHidden {
                                                contentBottomOffsetY = contentHeight
                                            }
                                        }
                                    }
                                    return Color.clear // NOTE: If this errors it could be because of a syntax error in GTModalView.swift. ~Levi
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
        .onChange(of: $isHidden.wrappedValue, perform: { (isHiddenValue: Bool) in
            
            if isHiddenValue {
                overlayOpacity = 0
                contentBottomOffsetY = contentHeight
            }
            else {
                overlayOpacity = 1
                contentBottomOffsetY = 0 // Set to 0 since the content uses a ZStack with alignment bottom.  This will place the content bottom at the bottom of the screen. ~Levi
            }
        })
        .onAppear {
            isHidden = false
        }
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
    }
}
