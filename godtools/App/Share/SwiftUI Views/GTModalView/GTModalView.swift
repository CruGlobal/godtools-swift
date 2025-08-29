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
    private let backgroundHorizontalPadding: CGFloat
    private let strokeColor: Color
    private let strokeLineWidth: CGFloat
    private let contentAnimationDuration: TimeInterval = 0.3
    // NOTE: I noticed the content height would frequently change between what appeared to be the correct calculated height and then a smaller height. This flag will only ever set the contentHeight to the maximum calculated height ignoring the smaller calculated height. ~Levi
    private let shouldLockContentHeightToMaxCalculatedHeight: Bool = true
    
    @State private var overlayOpacity: CGFloat = 0
    @State private var contentBottomOffsetY: CGFloat = 1000
    @State private var contentHeight: CGFloat = 0
    
    @Binding private var isHidden: Bool
    
    init(@ViewBuilder content: @escaping (_ geometry: GeometryProxy) -> Content, isHidden: Binding<Bool>, overlayTappedClosure: (() -> Void)?, backgroundHorizontalPadding: CGFloat = 10, strokeColor: Color = Color.clear, strokeLineWidth: CGFloat = 0) {
        
        self.content = content
        self._isHidden = isHidden
        self.overlayTappedClosure = overlayTappedClosure
        self.backgroundHorizontalPadding = backgroundHorizontalPadding
        self.strokeColor = strokeColor
        self.strokeLineWidth = strokeLineWidth
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
                                        let minimumHeight: CGFloat = floor(geometry.size.height * 0.33)
                                        let maximumHeight: CGFloat = geometry.size.height
                                        
                                        let clampedContentHeight: CGFloat
                                        
                                        if shouldLockContentHeightToMaxCalculatedHeight && newContentHeight < currentContentHeight {
                                            clampedContentHeight = currentContentHeight
                                        }
                                        else if newContentHeight < minimumHeight {
                                            clampedContentHeight = minimumHeight
                                        }
                                        else if newContentHeight > maximumHeight {
                                            clampedContentHeight = maximumHeight
                                        }
                                        else {
                                            clampedContentHeight = newContentHeight
                                        }
                                        
                                        let contentHeightDidChange: Bool = currentContentHeight != clampedContentHeight
                                        
                                        if contentHeightDidChange {
                                            
                                            contentHeight = clampedContentHeight
                                                                                        
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
                            .stroke(strokeColor, lineWidth: strokeLineWidth)
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
