//
//  ToolSettingsShareableItemView.swift
//  ToolSettings
//
//  Created by Levi Eggert on 5/10/22.
//

import SwiftUI

struct ToolSettingsShareableItemView: View {
    
    private let itemSize: CGSize = CGSize(width: 112, height: 112)
    
    @ObservedObject var viewModel: ToolSettingsShareableItemViewModel
    
    var body: some View {
        
        GeometryReader { geometry in
            
            viewModel.image
                .resizable()
                .frame(width: itemSize.width, height: itemSize.height)
                .aspectRatio(contentMode: .fit)
            
            VStack(alignment: .center, spacing: 0) {
                Spacer()
                Text(viewModel.title)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0))
        }
        .frame(width: itemSize.width, height: itemSize.height)
        .background(ColorPalette.gtLightestGrey.color)
    }
}
