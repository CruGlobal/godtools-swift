//
//  LanguagesListView.swift
//  godtools
//
//  Created by Levi Eggert on 5/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct LanguagesListView: View {
    
    @ObservedObject var viewModel: BaseLanguagesListViewModel
    
    var body: some View {
        List(viewModel.languages) { language in
            
            LanguagesListItemView(viewModel: viewModel.getLanguagesListItemViewModel(language: language))
        }
    }
}

struct LanguagesListView_Preview: PreviewProvider {
    static var previews: some View {
        
        let viewModel = BaseLanguagesListViewModel(languages: [])
        
        return LanguagesListView(viewModel: viewModel)
    }
}
