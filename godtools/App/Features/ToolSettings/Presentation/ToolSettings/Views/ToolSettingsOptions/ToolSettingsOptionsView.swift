//
//  ToolSettingsOptionsView.swift
//  ToolSettings
//
//  Created by Levi Eggert on 5/10/22.
//

import SwiftUI

struct ToolSettingsOptionsView: View {
            
    @ObservedObject var viewModel: ToolSettingsViewModel
    
    let leadingInset: CGFloat
    let trailingInset: CGFloat
    
    var body: some View {
        
        VStack (alignment: .leading, spacing: 0) {
            ScrollView (.horizontal, showsIndicators: false) {
                HStack {
                    
                    ToolSettingsOptionsItemView(
                        backgroundType: .color(color: Color(.sRGB, red: 59 / 256, green: 164 / 256, blue: 219 / 256, opacity: 1)),
                        iconImage: Image(ImageCatalog.toolSettingsOptionShareLink.name),
                        title: viewModel.shareLinkTitle,
                        titleColorStyle: .darkBackground
                    )
                    .onTapGesture {
                        viewModel.shareLinkTapped()
                    }
                    
                    ToolSettingsOptionsItemView(
                        backgroundType: .color(color: Color(.sRGB, red: 245 / 256, green: 245 / 256, blue: 245 / 256, opacity: 1)),
                        iconImage: Image(ImageCatalog.toolSettingsOptionScreenShare.name),
                        title: viewModel.screenShareTitle,
                        titleColorStyle: .lightBackground
                    )
                    .onTapGesture {
                        viewModel.screenShareTapped()
                    }
                    
                    ToolSettingsOptionsItemView(
                        backgroundType: .image(image: Image(ImageCatalog.toolSettingsOptionTrainingTipsBackground.name)),
                        iconImage: viewModel.trainingTipsIcon,
                        title: viewModel.trainingTipsTitle,
                        titleColorStyle: .lightBackground
                    )
                    .onTapGesture {
                        viewModel.trainingTipsTapped()
                    }
                }
                .padding(EdgeInsets(top: 0, leading: leadingInset, bottom: 0, trailing: trailingInset))
            }
        }
    }
}
