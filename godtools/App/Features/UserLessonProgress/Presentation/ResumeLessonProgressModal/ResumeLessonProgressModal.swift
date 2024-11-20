//
//  ResumeLessonProgressModal.swift
//  godtools
//
//  Created by Rachael Skeath on 10/29/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import SwiftUI

struct ResumeLessonProgressModal: View {
    
    private let buttonHeight: CGFloat = 48
    private let modalInset: CGFloat = 28
    private let buttonInset: CGFloat = 20
    private let buttonSpace: CGFloat = 12

    @ObservedObject private var viewModel: ResumeLessonProgressModalViewModel
    
    init(viewModel: ResumeLessonProgressModalViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        GeometryReader { geometry in
            let totalSpaceAroundModal = modalInset * 2
            let modalWidth = geometry.size.width - totalSpaceAroundModal
            let totalSpaceAroundButtons = (buttonInset * 2) + buttonSpace
            let buttonWidth = (modalWidth - totalSpaceAroundButtons) / 2
            
            ZStack {
                if #available(iOS 15.0, *) {
                    Color.clear
                        .edgesIgnoringSafeArea(.all)
                        .background(.ultraThinMaterial)
                } else {
                    VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                        .edgesIgnoringSafeArea(.all)
                }
                
                VStack(spacing: 0) {
                    Text(viewModel.interfaceStringsDomainModel.title)
                        .font(FontLibrary.sfProTextRegular.font(size: 28))
                        .foregroundColor(ColorPalette.gtGrey.color)
                        .padding(.top, 30)
                        .padding(.bottom, 15)
                    
                    Text(viewModel.interfaceStringsDomainModel.subtitle)
                        .font(FontLibrary.sfProTextRegular.font(size: 16))
                        .foregroundColor(ColorPalette.gtGrey.color)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, buttonInset + 20)
                        .padding(.bottom, 35)
                    
                    HStack(spacing: buttonSpace) {
                        GTWhiteButton(title: viewModel.interfaceStringsDomainModel.startOverButtonText, fontSize: 15, width: buttonWidth, height: buttonHeight) {
                            viewModel.startOverButtonTapped()
                        }
                        GTBlueButton(title: viewModel.interfaceStringsDomainModel.continueButtonText, fontSize: 15, width: buttonWidth, height: buttonHeight) {
                            viewModel.continueButtonTapped()
                        }
                    }
                    .padding(.horizontal, buttonInset)
                    .padding(.bottom, 21)
                }
                .background(Color.white)
                .cornerRadius(6)
                .shadow(color: Color.black.opacity(0.25), radius: 3, y: 3)
                .frame(width: modalWidth)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(Color.clear, lineWidth: 2)
                )
            }
        }

    }
}
