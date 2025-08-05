//
//  ToolSettingsView.swift
//  godtools
//
//  Created by Levi Eggert on 5/10/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolSettingsView: View {
        
    static let backgroundHorizontalPadding: CGFloat = 10
    
    private let contentInsets: EdgeInsets = EdgeInsets(
        top: 20,
        leading: 15 + Self.backgroundHorizontalPadding,
        bottom: 15,
        trailing: 15 + Self.backgroundHorizontalPadding
    )
    private let separatorLineSpacing: CGFloat = 25
    
    @ObservedObject private var viewModel: ToolSettingsViewModel
    
    @State private var modalIsHidden: Bool = true
    @State private var scrollContentHeight: CGFloat = 100
    
    init(viewModel: ToolSettingsViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        GTModalView(content: { geometry in
            
            VStack(alignment: .leading, spacing: 0) {
                         
                ToolSettingsTopBarView(
                    title: viewModel.title,
                    closeTapped: {
                        modalIsHidden = true
                        viewModel.closeTapped()
                    }
                )
                .padding([.top], contentInsets.top)
                .padding([.leading], contentInsets.leading)
                .padding([.trailing], contentInsets.trailing)
                .padding([.bottom], 10)
                                    
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 0) {
                        
                        if !viewModel.toolOptions.isEmpty {
                            
                            ToolSettingsOptionsView(
                                viewModel: viewModel
                            )
                            .padding([.leading], contentInsets.leading)
                            .padding([.trailing], contentInsets.trailing)
                        }
       
                        ToolSettingsSeparatorView(
                            separatorSpacing: 0
                        )
                        .padding([.top], separatorLineSpacing)
                        .padding([.leading], contentInsets.leading)
                        .padding([.trailing], contentInsets.trailing)
                                                        
                        ToolSettingsChooseLanguageView(
                            viewModel: viewModel
                        )
                        .padding([.top], separatorLineSpacing)
                        .padding([.leading], contentInsets.leading)
                        .padding([.trailing], contentInsets.trailing)
                        
                        if viewModel.shareables.count > 0 {
                            
                            ToolSettingsSeparatorView(
                                separatorSpacing: separatorLineSpacing
                            )
                            .padding([.leading], contentInsets.leading)
                            .padding([.trailing], contentInsets.trailing)
                            
                            ToolSettingsShareablesView(
                                viewModel: viewModel
                            )
                            .padding([.leading], contentInsets.leading)
                            .padding([.trailing], contentInsets.trailing)
                        }
                        
                        Rectangle()
                            .frame(width: geometry.size.width, height: contentInsets.bottom)
                            .foregroundColor(.clear)
                    }//end VStack
                    .background(
                        GeometryReader { scrollContentGeometry -> Color in
                            DispatchQueue.main.async {
                                scrollContentHeight = scrollContentGeometry.size.height
                            }
                            return Color.clear
                        }
                    )
                }//end ScrollView
                .clipped()
                .frame(maxHeight: scrollContentHeight)
            }//end VStack
        }, isHidden: $modalIsHidden, overlayTappedClosure: {
            
            viewModel.closeTapped()
        })
    }
}

extension ToolSettingsView {
    
    func setModalIsHidden(isHidden: Bool) {
    
        self.modalIsHidden = isHidden
    }
}
