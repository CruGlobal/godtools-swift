//
//  TextWithLinksView.swift
//  godtools
//
//  Created by Levi Eggert on 12/5/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

@available(iOS 15.0, *)
struct TextWithLinksView: View {
    
    private let markdownText: AttributedString
    private let textColor: Color
    private let font: Font
    private let lineSpacing: CGFloat
    private let textAlignment: TextAlignment
    private let handleUrlClosure: ((_ url: URL) -> Void)?
    
    init(stringContainingUrls: String, textColor: Color, font: Font, lineSpacing: CGFloat? = nil, textAlignment: TextAlignment? = nil, handleUrlClosure: ((_ url: URL) -> Void)? = nil) {
        
        switch stringContainingUrls.toUrlMarkdown() {
        case .success(let markdown):
            markdownText = markdown
        case .failure( _):
            markdownText = AttributedString(stringContainingUrls)
        }
        
        self.textColor = textColor
        self.font = font
        self.lineSpacing = lineSpacing ?? 2
        self.textAlignment = textAlignment ?? .leading
        self.handleUrlClosure = handleUrlClosure
    }
    
    var body: some View {
        
        Text(markdownText)
            .foregroundColor(textColor)
            .font(font)
            .lineSpacing(lineSpacing)
            .multilineTextAlignment(.leading)
            .environment(\.openURL, OpenURLAction { (url: URL) in
                
                if let handleUrlClosure = self.handleUrlClosure {
                    
                    handleUrlClosure(url)
                    
                    return .handled
                }
                
                return .systemAction
            })
    }
}
