//
//  ToolSettingsView.swift
//  godtools
//
//  Created by Levi Eggert on 5/10/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolSettingsView: View {
    
    private static let backgroundColor: Color = Color.white
    private static let backgroundCornerRadius: CGFloat = 12
    
    static let backgroundHorizontalPadding: CGFloat = 10
    
    private let contentInsets: EdgeInsets = EdgeInsets(
        top: 20,
        leading: 15 + Self.backgroundHorizontalPadding,
        bottom: 15,
        trailing: 15 + Self.backgroundHorizontalPadding
    )
    private let separatorLineSpacing: CGFloat = 25
    private let overlayTappedClosure: (() -> Void)?
    
    @ObservedObject private var viewModel: ToolSettingsViewModel
    
    @State private var contentSize: CGSize = CGSize(width: 100, height: 100)
    @State private var isVisible: Bool = false
    
    init(viewModel: ToolSettingsViewModel, overlayTappedClosure: (() -> Void)? = nil) {
        
        self.viewModel = viewModel
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
                                 
                        ToolSettingsTopBarView(
                            title: viewModel.title,
                            leadingInset: contentInsets.leading,
                            trailingInset: contentInsets.trailing,
                            closeTapped: {
                                setIsVisible(isVisible: false)
                                viewModel.closeTapped()
                            }
                        )
                        .padding([.top], contentInsets.top)
                        .padding([.bottom], 10)
                                            
                        ScrollView(.vertical, showsIndicators: true) {
                            VStack(spacing: 0) {
                                
                                if viewModel.hidesToolOptions == false {
                                    
                                    ToolSettingsOptionsView(
                                        viewModel: viewModel,
                                        leadingInset: contentInsets.leading,
                                        trailingInset: contentInsets.trailing
                                    )
                                    
                                    FixedVerticalSpacer(height: separatorLineSpacing)
                                }
               
                                ToolSettingsSeparatorView(
                                    separatorSpacing: 0,
                                    separatorLeadingInset: contentInsets.leading,
                                    separatorTrailingInset: contentInsets.trailing
                                )
                                
                                FixedVerticalSpacer(height: separatorLineSpacing)
                                
                                ToolSettingsChooseLanguageView(
                                    viewModel: viewModel,
                                    geometryProxy: geometry,
                                    leadingInset: contentInsets.leading,
                                    trailingInset: contentInsets.trailing
                                )
                                
                                if viewModel.shareables.count > 0 {
                                    
                                    ToolSettingsSeparatorView(
                                        separatorSpacing: separatorLineSpacing,
                                        separatorLeadingInset: contentInsets.leading,
                                        separatorTrailingInset: contentInsets.trailing
                                    )
                                    
                                    ToolSettingsShareablesView(
                                        viewModel: viewModel,
                                        leadingInset: contentInsets.leading,
                                        trailingInset: contentInsets.trailing
                                    )
                                }
                                
                                Rectangle()
                                    .frame(width: geometry.size.width, height: contentInsets.bottom)
                                    .foregroundColor(.clear)
                            }//end VStack
                            .background(
                                GeometryReader { geo -> Color in
                                    DispatchQueue.main.async {
                                        contentSize = geo.size
                                    }
                                    return Color.clear
                                }
                            )
                        }//end ScrollView
                        .frame(
                            width: geometry.size.width - (Self.backgroundHorizontalPadding * 2),
                            height: contentSize.height
                        )
                        .clipped()
                        .padding([.leading], Self.backgroundHorizontalPadding)
                    }//end VStack
                    .background(
                        RoundedRectangle(cornerRadius: Self.backgroundCornerRadius)
                            .overlay(
                                RoundedRectangle(cornerRadius: Self.backgroundCornerRadius)
                                    .foregroundStyle(Self.backgroundColor)
                            )
                            .padding(.leading, Self.backgroundHorizontalPadding)
                            .padding(.trailing, Self.backgroundHorizontalPadding)
                    )
                }//end ZStack top content
                .offset(y: !isVisible ? geometry.size.height * 0.75 : 0)
                
            }//end ZStack bottom
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
