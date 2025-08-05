//
//  ToolSettingsOptionsView.swift
//  godtools
//
//  Created by Levi Eggert on 5/10/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolSettingsOptionsView: View {
            
    @ObservedObject private var viewModel: ToolSettingsViewModel
        
    init(viewModel: ToolSettingsViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    
                    ForEach(viewModel.toolOptions) { toolOption in
                        
                        switch toolOption {
                        
                        case .shareLink:
                            ToolSettingsOptionView(
                                viewBackground: .color(color: Color(.sRGB, red: 59 / 256, green: 164 / 256, blue: 219 / 256, opacity: 1)),
                                title: viewModel.shareLinkTitle,
                                titleColorStyle: .darkBackground,
                                iconImage: ImageCatalog.toolSettingsOptionShareLink.image,
                                accessibility: .shareLink,
                                tappedClosure: {
                                    viewModel.shareLinkTapped()
                                }
                            )
                            
                        case .shareScreen:
                            ToolSettingsOptionView(
                                viewBackground: .color(color: Color(.sRGB, red: 245 / 256, green: 245 / 256, blue: 245 / 256, opacity: 1)),
                                title: viewModel.screenShareTitle,
                                titleColorStyle: .lightBackground,
                                iconImage: ImageCatalog.toolSettingsOptionScreenShare.image,
                                accessibility: .shareScreen,
                                tappedClosure: {
                                    viewModel.screenShareTapped()
                                }
                            )
                            
                        case .trainingTips:
                            ToolSettingsOptionView(
                                viewBackground: .image(image: ImageCatalog.toolSettingsOptionTrainingTipsBackground.image),
                                title: viewModel.trainingTipsTitle,
                                titleColorStyle: .lightBackground,
                                iconImage: viewModel.trainingTipsIcon,
                                accessibility: .trainingTips,
                                tappedClosure: {
                                    viewModel.trainingTipsTapped()
                                }
                            )
                        }
                    }
                }
            }
        }
    }
}
