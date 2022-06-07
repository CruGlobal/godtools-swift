//
//  ActivityIndicator.swift
//  godtools
//
//  Created by Rachael Skeath on 4/15/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

// TODO: - GT-1533: In iOS 14+, we can use SwiftUI's `ProgressView` to get a built-in spinner and delete this one.
struct ActivityIndicator: UIViewRepresentable {
        
    let style: UIActivityIndicatorView.Style
    @Binding var isAnimating: Bool
    
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
