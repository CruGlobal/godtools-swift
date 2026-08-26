//
//  AppToolbarItem.swift
//  godtools
//
//  Created by Levi Eggert on 8/19/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import SwiftUI

struct AppToolbarItem: ToolbarContent {
    
    private static let minSize: CGFloat = 40
    
    enum ViewType: Sendable {
        case image(value: Image)
        case imageName(value: String)
        case text(value: String)
    }
    
    private let placement: ToolbarItemPlacement
    private let viewType: ViewType
    private let color: Color?
    private let accessibilityId: String?
    private let tappedClosure: (() -> Void)?
    
    init(
        placement: ToolbarItemPlacement,
        viewType: ViewType,
        color: Color?,
        accessibilityId: String?,
        tappedClosure: (() -> Void)?
    ) {
        
        self.placement = placement
        self.viewType = viewType
        self.color = color
        self.accessibilityId = accessibilityId
        self.tappedClosure = tappedClosure
    }
    
    var body: some ToolbarContent {
        
        ToolbarItem(placement: placement) {
            
            Button(action: {
                
                tappedClosure?()
            }) {
                
                switch viewType {
                
                case .image(let value):
                    renderImage(image: value)
                
                case .imageName(let value):
                    renderImage(image: Image(value))
                
                case .text(let value):
                    Text(value)
                        .foregroundColor(color)
                }
            }
            .accessibilityIdentifier(accessibilityId ?? "")
            .buttonStyle(.borderless)
        }
        .ifAvailableSharedBackgroundVisibility(.hidden)
    }
    
    @ViewBuilder private func renderImage(image: Image) -> some View {
        
        image
            .renderingMode(.template)
            .foregroundColor(color)
            .frame(minWidth: Self.minSize, minHeight: Self.minSize)
    }
}

extension AppToolbarItem {
    static var leadingPlacement: ToolbarItemPlacement {
        
        if #available(iOS 17.0, *) {
            return .topBarLeading
        }
        
        return .navigationBarLeading
    }
    
    static var trailingPlacement: ToolbarItemPlacement {
        
        if #available(iOS 17.0, *) {
            return .topBarTrailing
        }
        
        return .navigationBarTrailing
    }
}
