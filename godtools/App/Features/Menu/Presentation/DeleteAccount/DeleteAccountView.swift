//
//  DeleteAccountView.swift
//  godtools
//
//  Created by Levi Eggert on 7/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct DeleteAccountView: View {
    
    private let contentInsets: EdgeInsets = EdgeInsets(top: 40, leading: 30, bottom: 0, trailing: 30)
    private let backgroundColor: Color
    
    @ObservedObject private var viewModel: DeleteAccountViewModel
    
    init(viewModel: DeleteAccountViewModel, backgroundColor: Color) {
        
        self.viewModel = viewModel
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            VStack(alignment: .leading, spacing: 0) {
                
                FixedVerticalSpacer(height: contentInsets.top)
            }
        }
        .background(Color.white)
    }
}

struct DeleteAccountView_Preview: PreviewProvider {
    
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let viewModel = DeleteAccountViewModel(
            flowDelegate: MockFlowDelegate(),
            localizationServices: appDiContainer.localizationServices
        )
        
        return DeleteAccountView(viewModel: viewModel, backgroundColor: Color.white)
    }
}
