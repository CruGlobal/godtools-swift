//
//  BackwardsCompatibleTextWithLinks.swift
//  godtools
//
//  Created by Levi Eggert on 12/5/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

@available(iOS, obsoleted: 15.0, message: "When supporting iOS 15 and up use TextWithLinksView.swift")
struct BackwardsCompatibleTextWithLinks: View {
    
    private let geometry: GeometryProxy
    private let text: String
    private let textColor: ColorPalette
    private let textFont: FontLibrary
    private let fontSize: CGFloat
    private let lineSpacing: CGFloat
    private let urlTappedClosure: ((_ url: URL) -> Void)
    
    init(geometry: GeometryProxy, text: String, textColor: ColorPalette, textFont: FontLibrary, fontSize: CGFloat, lineSpacing: CGFloat, urlTappedClosure: @escaping ((_ url: URL) -> Void)) {
        
        self.geometry = geometry
        self.text = text
        self.textColor = textColor
        self.textFont = textFont
        self.fontSize = fontSize
        self.lineSpacing = lineSpacing
        self.urlTappedClosure = urlTappedClosure
    }
    
    var body: some View {
        
        if #available(iOS 15.0, *) {
              
            TextWithLinksView(
                stringContainingUrls: text,
                textColor: textColor.color,
                font: textFont.font(size: fontSize),
                lineSpacing: lineSpacing,
                textAlignment: .leading,
                handleUrlClosure: { (url: URL) in
                    
                    urlTappedClosure(url)
                }
            )
        }
        else {
            
            TextWithLinks(
                text: text,
                textColor: textColor.uiColor,
                font: textFont.uiFont(size: fontSize),
                lineSpacing: lineSpacing,
                width: geometry.size.width - ToolDetailsView.sectionDescriptionTextInsets.leading - ToolDetailsView.sectionDescriptionTextInsets.trailing,
                adjustsFontForContentSizeCategory: true,
                didInteractWithUrlClosure: { (url: URL) in
                    
                    urlTappedClosure(url)
                    
                    return true
                }
            )
        }
    }
}
