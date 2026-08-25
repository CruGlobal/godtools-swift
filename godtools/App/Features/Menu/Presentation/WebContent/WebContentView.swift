//
//  WebContentView.swift
//  godtools
//
//  Created by Levi Eggert on 4/7/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import SwiftUI

struct WebContentView: View {
    
    private let screenAccessibility: AccessibilityStrings.Screen?
    
    @ObservedObject private var viewModel: WebContentViewModel
    
    init(viewModel: WebContentViewModel, screenAccessibility: AccessibilityStrings.Screen?) {
        
        self.viewModel = viewModel
        self.screenAccessibility = screenAccessibility
    }
    
    var body: some View {
        GeometryReader { geometry in
            
            if let screenAccessibility = screenAccessibility {
                AccessibilityScreenElementView(screenAccessibility: screenAccessibility)
            }
            
            if let url = viewModel.url {
                
                CenteredCircularProgressView(progressColor: .black)
                
                ReloadableWebView(
                    requestUrl: url,
                    fallbackFileUrl: nil,
                    completion: nil
                )
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .navBar(
            title: viewModel.navTitle,
            backTapped: {
                viewModel.backTapped()
            }
        )
        .background(Color.white)
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
        .onAppear {
            viewModel.pageViewed()
        }
    }
}
