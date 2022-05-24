//
//  ToolSettingsView.swift
//  ToolSettings
//
//  Created by Levi Eggert on 5/10/22.
//

import SwiftUI

struct ToolSettingsView: View {
    
    @ObservedObject var viewModel: BaseToolSettingsViewModel
    
    private let contentInsets: EdgeInsets = EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20)
    private let separatorLineSpacing: CGFloat = 25
    private let primaryTextColor: Color = Color(.sRGB, red: 84 / 256, green: 84 / 256, blue: 84 / 256, opacity: 1)
    
    var body: some View {
        GeometryReader { geometry in
            
            VStack {
                
                ToolSettingsTopBarView(viewModel: viewModel.getTopBarViewModel(), leadingInset: contentInsets.leading, trailingInset: contentInsets.trailing)
                
                ScrollView(.vertical, showsIndicators: true) {
                    VStack {
                        
                        ToolSettingsOptionsView(
                            viewModel: viewModel.getOptionsViewModel(),
                            leadingInset: contentInsets.leading,
                            trailingInset: contentInsets.trailing
                        )
       
                        ToolSettingsSeparatorView(
                            separatorSpacing: separatorLineSpacing,
                            separatorLeadingInset: contentInsets.leading,
                            separatorTrailingInset: contentInsets.trailing
                        )
                        
                        ToolSettingsChooseLanguageView(
                            viewModel: viewModel.getChooseLanguageViewModel(),
                            geometryProxy: geometry,
                            leadingInset: contentInsets.leading,
                            trailingInset: contentInsets.trailing,
                            primaryTextColor: primaryTextColor
                        )
                        
                        ToolSettingsSeparatorView(
                            separatorSpacing: separatorLineSpacing,
                            separatorLeadingInset: contentInsets.leading,
                            separatorTrailingInset: contentInsets.trailing
                        )
                        
                        ToolSettingsShareablesView(
                            viewModel: viewModel.getShareablesViewModel(),
                            primaryTextColor: primaryTextColor,
                            leadingInset: contentInsets.leading,
                            trailingInset: contentInsets.trailing
                        )
                    }
                }
            }
        }
        .padding(EdgeInsets(top: contentInsets.top, leading: 0, bottom: 0, trailing: 0))
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct ToolSettingsView_Preview: PreviewProvider {
    
    static var previews: some View {
        
        ToolSettingsView(viewModel: BaseToolSettingsViewModel())
    }
}
