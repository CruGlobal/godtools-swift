//
//  DeleteAccountView.swift
//  godtools
//
//  Created by Levi Eggert on 7/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct DeleteAccountView: View {
    
    private let contentInsets: EdgeInsets = EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30)
    
    @ObservedObject var viewModel: DeleteAccountViewModel
    
    var body: some View {
        
        GeometryReader { geometry in
            
            VStack{
                
                TextWithLinks(
                    text: viewModel.deleteOktaAccountInstructions,
                    textColor: ColorPalette.gtGrey.uiColor,
                    font: FontLibrary.sfProTextRegular.uiFont(size: 18),
                    lineSpacing: 2,
                    width: geometry.size.width,
                    didInteractWithUrlClosure: { (url: URL) in
                        
                        print("did interact with url: \(url.absoluteString)")
                    }
                )
            }
        }
    }
}

struct DeleteAccountView_Preview: PreviewProvider {
    
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let viewModel = DeleteAccountViewModel(
            flowDelegate: MockFlowDelegate(),
            localizationServices: appDiContainer.localizationServices
        )
        
        return DeleteAccountView(viewModel: viewModel)
    }
}
