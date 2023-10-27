//
//  LessonEvaluationView.swift
//  godtools
//
//  Created by Levi Eggert on 10/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct LessonEvaluationView: View {
    
    private let viewInsets: EdgeInsets = EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
    private let contentInsets: EdgeInsets = EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30)
    private let closeButtonSize: CGFloat = 44
    private let closeButtonTop: CGFloat = 5
    
    @ObservedObject private var viewModel: LessonEvaluationViewModel
        
    init(viewModel: LessonEvaluationViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        GeometryReader { geometry in
         
            VStack(alignment: .center, spacing: 0) {
                
                Spacer()
                
                VStack(alignment: .center, spacing: 0) {
                    
                    HStack(alignment: .top, spacing: 0) {
                        Spacer()
                        
                        CloseButton(
                            buttonSize: closeButtonSize,
                            tapped: {
                                viewModel.closeTapped()
                        })
                        .padding([.top], closeButtonTop)
                        .padding([.trailing], 5)
                    }

                    Text(viewModel.title)
                        .font(FontLibrary.sfProTextSemibold.font(size: 22))
                        .foregroundColor(ColorPalette.gtGrey.color)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.top], 30 - closeButtonSize - closeButtonTop)
                        .padding([.leading], contentInsets.leading)
                        
                    Text(viewModel.wasThisHelpful)
                        .font(FontLibrary.sfProTextRegular.font(size: 18))
                        .foregroundColor(ColorPalette.gtGrey.color)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.top], 20)
                        .padding([.leading], contentInsets.leading)
                    
                    HStack(alignment: .center, spacing: 10) {
                        
                        EvaluationOptionButton(
                            title: viewModel.yesButtonTitle,
                            isSelected: $viewModel.yesIsSelected,
                            action: {
                                
                                viewModel.yesTapped()
                            }
                        )
                        
                        EvaluationOptionButton(
                            title: viewModel.noButtonTitle,
                            isSelected: $viewModel.noIsSelected,
                            action: {
                                
                                viewModel.noTapped()
                            }
                        )
                    }
                    .padding([.top], 14)
                    
                    Text(viewModel.shareFaithReadiness)
                        .font(FontLibrary.sfProTextRegular.font(size: 18))
                        .foregroundColor(ColorPalette.gtGrey.color)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.top], 30)
                        .padding([.leading], contentInsets.leading)
                    
                    ScaleValueSliderView(
                        viewWidth: geometry.size.width - viewInsets.leading - viewInsets.trailing,
                        tintColor: ColorPalette.gtBlue.color,
                        minScaleValue: viewModel.readyToShareFaithMinimumScaleValue,
                        maxScaleValue: viewModel.readyToShareFaithMaximumScaleValue,
                        scale: $viewModel.readyToShareFaithScale
                    )
                    .padding([.top], 14)
                    
                    GTBlueButton(
                        title: viewModel.sendFeedbackButtonTitle,
                        fontSize: 18,
                        width: 248,
                        height: 50,
                        cornerRadius: 24,
                        action: {
                            viewModel.sendFeedbackTapped()
                        }
                    )
                    .padding([.top, .bottom], 30)
                }
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.25), radius: 4, y: 2)
                .padding(EdgeInsets(top: 0, leading: viewInsets.leading, bottom: 0, trailing: viewInsets.trailing))
                
                Spacer()
            }
        }
        .background(Color.clear)
    }
}
