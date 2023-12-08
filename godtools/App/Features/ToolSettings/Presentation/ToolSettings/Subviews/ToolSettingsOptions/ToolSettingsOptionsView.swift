//
//  ToolSettingsOptionsView.swift
//  ToolSettings
//
//  Created by Levi Eggert on 5/10/22.
//

import SwiftUI

struct ToolSettingsOptionsView: View {
            
    @ObservedObject private var viewModel: ToolSettingsViewModel
    
    let leadingInset: CGFloat
    let trailingInset: CGFloat
    
    init(viewModel: ToolSettingsViewModel, leadingInset: CGFloat, trailingInset: CGFloat) {
        
        self.viewModel = viewModel
        self.leadingInset = leadingInset
        self.trailingInset = trailingInset
    }
    
    var body: some View {
        
        VStack (alignment: .leading, spacing: 0) {
            ScrollView (.horizontal, showsIndicators: false) {
                HStack {
                    
                    ToolSettingsOptionView(
                        viewBackground: .color(color: Color(.sRGB, red: 59 / 256, green: 164 / 256, blue: 219 / 256, opacity: 1)),
                        title: viewModel.shareLinkTitle,
                        titleColorStyle: .darkBackground,
                        iconImage: ImageCatalog.toolSettingsOptionShareLink.image,
                        tappedClosure: {
                            viewModel.shareLinkTapped()
                        }
                    )
                    
                    ToolSettingsOptionView(
                        viewBackground: .color(color: Color(.sRGB, red: 245 / 256, green: 245 / 256, blue: 245 / 256, opacity: 1)),
                        title: viewModel.screenShareTitle,
                        titleColorStyle: .lightBackground,
                        iconImage: ImageCatalog.toolSettingsOptionScreenShare.image,
                        tappedClosure: {
                            viewModel.screenShareTapped()
                        }
                    )
                    
                    if !viewModel.hidesToggleTrainingTipsButton {
                        
                        ToolSettingsOptionView(
                            viewBackground: .image(image: ImageCatalog.toolSettingsOptionTrainingTipsBackground.image),
                            title: viewModel.trainingTipsTitle,
                            titleColorStyle: .lightBackground,
                            iconImage: ImageCatalog.toolSettingsOptionTrainingTipsBackground.image,
                            tappedClosure: {
                                viewModel.trainingTipsTapped()
                            }
                        )
                    }
                }
                .padding(EdgeInsets(top: 0, leading: leadingInset, bottom: 0, trailing: trailingInset))
            }
        }
    }
}
