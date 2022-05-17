//
//  LanguagesListItemView.swift
//  godtools
//
//  Created by Levi Eggert on 5/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct LanguagesListItemView: View {
    
    @ObservedObject var viewModel: BaseLanguagesListItemViewModel
    
    var body: some View {
        VStack {
            
        }
    }
}

struct LanguagesListItemView_Preview: PreviewProvider {
    static var previews: some View {
        LanguagesListItemView(viewModel: BaseLanguagesListItemViewModel())
    }
}
