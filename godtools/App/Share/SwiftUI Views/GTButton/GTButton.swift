//
//  GTButton.swift
//  godtools
//
//  Created by Levi Eggert on 6/18/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import SwiftUI

struct GTButton: View {
    
    enum Style {
        case blue
        case white
    }
    
    private let style: Style
    private let title: String
    private let color: Color?
    private let font: Font
    private let width: CGFloat?
    private let height: CGFloat?
    private let titleHorizontalPadding: CGFloat?
    private let titleVerticalPadding: CGFloat?
    private let cornerRadius: CGFloat
    private let accessibility: AccessibilityStrings.Button?
    private let tappedClosure: (() -> Void)?
    private let onTextWidthChanged: ((_ width: CGFloat) -> Void)?
    
    private var titleColor: Color {
        switch style {
        case .blue:
            return .white
        case .white:
            return ColorPalette.gtBlue.color
        }
    }
    
    init(
        style: Style,
        title: String,
        color: Color? = nil,
        font: Font? = nil,
        fontSize: CGFloat? = nil,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        titleHorizontalPadding: CGFloat? = nil,
        titleVerticalPadding: CGFloat? = nil,
        cornerRadius: CGFloat = 6,
        accessibility: AccessibilityStrings.Button? = nil,
        tapped: (() -> Void)? = nil,
        onTextWidthChanged: ((_ width: CGFloat) -> Void)? = nil
    ) {
        
        self.style = style
        self.title = title
        self.color = color
        self.width = width
        self.height = height
        self.titleHorizontalPadding = titleHorizontalPadding
        self.titleVerticalPadding = titleVerticalPadding
        self.cornerRadius = cornerRadius
        self.accessibility = accessibility
        self.tappedClosure = tapped
        self.onTextWidthChanged = onTextWidthChanged
        
        if let font = font {
            self.font = font
        }
        else if let fontSize = fontSize {
            self.font = Self.getDefaultFont(fontSize: fontSize)
        }
        else {
            self.font = Self.getDefaultFont(fontSize: 12)
        }
    }
    
    private static func getDefaultFont(fontSize: CGFloat) -> Font {
        return FontLibrary.sfProTextRegular.font(size: fontSize)
    }
    
    var body: some View {
        
        CustomButton(
            attributes: getAttributes(style: style),
            accessibilityId: accessibility?.id,
            highlightContent: {
                
                getButtonTitle()
            },
            nonHighlightContent: {
                
            },
            tappedClosure: tappedClosure
        )
    }
    
    @ViewBuilder private func getButtonTitle() -> some View {
        
        Text(title)
            .font(font)
            .foregroundColor(titleColor)
            .optionalHorizontalPoadding(titleHorizontalPadding)
            .optionalVerticalPoadding(titleVerticalPadding)
            .background(ViewGeometry())
            .onPreferenceChange(ViewSizePreferenceKey.self) { size in
                onTextWidthChanged?(size.width)
            }
    }
    
    private func getAttributes(style: Style) -> CustomButtonAttributes {
        
        let buttonColor: Color
        let borderColor: Color
        let borderWidth: CGFloat
        
        switch style {
        case .blue:
            buttonColor = ColorPalette.gtBlue.color
            borderColor = .clear
            borderWidth = 0
            
        case .white:
            buttonColor = .white
            borderColor = ColorPalette.gtBlue.color
            borderWidth = 1
        }
        
        return CustomButtonAttributes(
            width: width,
            height: height,
            color: color ?? buttonColor,
            cornerRadius: cornerRadius,
            borderColor: borderColor,
            borderWidth: borderWidth
        )
    }
}
