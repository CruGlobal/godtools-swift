//
//  DeleteAccountView.swift
//  godtools
//
//  Created by Levi Eggert on 7/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct DeleteAccountView: View {
    
    @ObservedObject var viewModel: DeleteAccountViewModel
    
    var body: some View {
        
        VStack{
            
        }
    }
}

struct DeleteAccountView_Preview: PreviewProvider {
    
    static var previews: some View {
        
        let viewModel = DeleteAccountViewModel()
        
        return DeleteAccountView(viewModel: viewModel)
    }
}
