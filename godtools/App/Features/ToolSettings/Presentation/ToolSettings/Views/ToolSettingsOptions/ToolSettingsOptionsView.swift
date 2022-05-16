//
//  ToolSettingsOptionsView.swift
//  ToolSettings
//
//  Created by Levi Eggert on 5/10/22.
//

import SwiftUI

struct ToolSettingsOptionsView: View {
            
    @ObservedObject var viewModel: BaseToolSettingsOptionsViewModel
    
    let leadingInset: CGFloat
    let trailingInset: CGFloat
    
    var body: some View {
        
        VStack (alignment: .leading, spacing: 0) {
            ScrollView (.horizontal, showsIndicators: false) {
                HStack {
                    
                    ToolSettingsOptionsItemView(
                        backgroundType: .color(color: Color(.sRGB, red: 59 / 256, green: 164 / 256, blue: 219 / 256, opacity: 1)),
                        iconImage: Image(ImageCatalog.toolSettingsOptionShareLink.name),
                        title: "Share link",
                        titleColorStyle: .darkBackground
                    )
                    .onTapGesture {
                        viewModel.shareLinkTapped()
                    }
                    
                    ToolSettingsOptionsItemView(
                        backgroundType: .color(color: Color(.sRGB, red: 245 / 256, green: 245 / 256, blue: 245 / 256, opacity: 1)),
                        iconImage: Image(ImageCatalog.toolSettingsOptionScreenShare.name),
                        title: "Screen share",
                        titleColorStyle: .lightBackground
                    )
                    .onTapGesture {
                        viewModel.screenShareTapped()
                    }
                    
                    ToolSettingsOptionsItemView(
                        backgroundType: .image(image: Image(ImageCatalog.toolSettingsOptionTrainingTipsBackground.name)),
                        iconImage: Image(ImageCatalog.toolSettingsOptionTrainingTips.name),
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

struct ToolSettingsOptionsView_Preview: PreviewProvider {
    static var previews: some View {
        let viewModel = BaseToolSettingsOptionsViewModel()
        ToolSettingsOptionsView(viewModel: viewModel, leadingInset: 20, trailingInset: 20)
    }
}
