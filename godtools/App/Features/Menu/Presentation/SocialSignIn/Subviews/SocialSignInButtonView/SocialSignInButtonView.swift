//
//  SocialSignInButtonView.swift
//  godtools
//
//  Created by Rachael Skeath on 4/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct SocialSignInButtonView: View {
    
    private let height: CGFloat = 43
    private let cornerRadius: CGFloat = 6
    private let tappedClosure: (() -> Void)
    
    @ObservedObject private var viewModel: SocialSignInButtonViewModel
    
    init(viewModel: SocialSignInButtonViewModel, tappedClosure: @escaping (() -> Void)) {
        
        self.viewModel = viewModel
        self.tappedClosure = tappedClosure
    }
    
    var body: some View {
        
        ZStack(alignment: .center) {
                     
            Button {
                
                print("button tap")
                
                tappedClosure()
                
            } label: {
                
                ZStack(alignment: .center) {
                
                    Rectangle()
                        .fill(.clear)
                        .frame(height: height)
                        .cornerRadius(cornerRadius)
                        .ignoresSafeArea()
                    
                    HStack(spacing: 12) {
                        
                        Image(viewModel.iconName)
                            .frame(width: viewModel.iconSize.width, height: viewModel.iconSize.height)
                        
                        Text(viewModel.buttonText)
                            .font(viewModel.font)
                            .foregroundColor(viewModel.fontColor)
                    }
                }
            }
            .frame(height: height)
            .background(viewModel.backgroundColor)
            .cornerRadius(cornerRadius)
        }
    }
}
