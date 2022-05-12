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
    
    var body: some View {
        GeometryReader { geometry in
            
            VStack {
                
                ToolSettingsTopBarView(viewModel: viewModel.getTopBarViewModel(), leadingInset: contentInsets.leading, trailingInset: contentInsets.trailing)
                
                ScrollView(.vertical, showsIndicators: true) {
                    VStack {
                        
                        ToolSettingsOptionsView(
                            leadingInset: contentInsets.leading,
                            trailingInset: contentInsets.trailing
                        )
       
                        ToolSettingsSeparatorView(
                            separatorSpacing: separatorLineSpacing,
                            separatorLeadingInset: contentInsets.leading,
                            separatorTrailingInset: contentInsets.trailing
                        )
                        
                        ToolSettingsConfigureParallelLanguageView(
                            geometryProxy: geometry,
                            leadingInset: contentInsets.leading,
                            trailingInset: contentInsets.trailing
                        )
                        
                        ToolSettingsSeparatorView(
                            separatorSpacing: separatorLineSpacing,
                            separatorLeadingInset: contentInsets.leading,
                            separatorTrailingInset: contentInsets.trailing
                        )
                        
                        ToolSettingsRelatedContentView(
                            viewModel: ToolSettingsRelatedContentViewModel(),
                            leadingInset: contentInsets.leading,
                            trailingInset: contentInsets.trailing
                        )
                    }
                }
            }
        }
        .padding(EdgeInsets(top: contentInsets.top, leading: 0, bottom: 0, trailing: 0))
        .background(Color.white)
        .cornerRadius(12, corners: [.topLeft, .topRight])
    }
}

struct ToolSettingsView_Preview: PreviewProvider {
    
    static var previews: some View {
        
        ToolSettingsView(viewModel: BaseToolSettingsViewModel())
    }
}
