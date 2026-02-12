//
//  AttributedString+Highlight.swift
//  godtools
//
//  Created by Rachael Skeath on 2/12/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import SwiftUI

extension AttributedString {

    static func withHighlightedText(fullText: String, highlightText: String, highlightColor: Color) -> AttributedString {

        var attributedString = AttributedString(fullText)

        guard let range = attributedString.range(of: highlightText) else {
            return attributedString
        }

        attributedString[range].foregroundColor = highlightColor

        return attributedString
    }
}
