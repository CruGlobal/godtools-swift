//
//  ToolSettingsView.swift
//  godtools
//
//  Created by Levi Eggert on 5/10/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolSettingsView: View {
    
    private let contentInsets: EdgeInsets = EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20)
    private let separatorLineSpacing: CGFloat = 25
    private let bottomSpace: CGFloat = 15
    
    @ObservedObject private var viewModel: ToolSettingsViewModel
    
    init(viewModel: ToolSettingsViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        GeometryReader { geometry in
            
            VStack(spacing: 0) {
                
                ToolSettingsTopBarView(
                    viewModel: viewModel,
                    leadingInset: contentInsets.leading,
                    trailingInset: contentInsets.trailing
                )
                
                FixedVerticalSpacer(height: 10)
                
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 0) {
                        
                        if viewModel.hidesAllIconButtons == false {
                            
                            ToolSettingsOptionsView(
                                viewModel: viewModel,
                                leadingInset: contentInsets.leading,
                                trailingInset: contentInsets.trailing
                            )
                            
                            FixedVerticalSpacer(height: separatorLineSpacing)
                        }
       
                        ToolSettingsSeparatorView(
                            separatorSpacing: 0,
                            separatorLeadingInset: contentInsets.leading,
                            separatorTrailingInset: contentInsets.trailing
                        )
                        
                        FixedVerticalSpacer(height: separatorLineSpacing)
                        
                        ToolSettingsChooseLanguageView(
                            viewModel: viewModel,
                            geometryProxy: geometry,
                            leadingInset: contentInsets.leading,
                            trailingInset: contentInsets.trailing
                        )
                        
                        if viewModel.shareables.count > 0 {
                            
                            ToolSettingsSeparatorView(
                                separatorSpacing: separatorLineSpacing,
                                separatorLeadingInset: contentInsets.leading,
                                separatorTrailingInset: contentInsets.trailing
                            )
                            
                            ToolSettingsShareablesView(
                                viewModel: viewModel,
                                leadingInset: contentInsets.leading,
                                trailingInset: contentInsets.trailing
                            )
                        }
                        
                        Rectangle()
                            .frame(width: geometry.size.width, height: bottomSpace)
                            .foregroundColor(.clear)
                    }
                }
            }
        }
        .padding(EdgeInsets(top: contentInsets.top, leading: 0, bottom: 0, trailing: 0))
        .background(Color.white)
        .cornerRadius(12)
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
    }
}
