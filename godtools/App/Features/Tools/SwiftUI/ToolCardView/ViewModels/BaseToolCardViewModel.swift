//
//  BaseToolCardViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 5/4/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

class BaseToolCardViewModel: NSObject, ObservableObject {
    
    // MARK: - Published
    
    @Published var bannerImage: Image?
    @Published var isFavorited = false
    @Published var title: String = ""
    @Published var category: String = ""
    @Published var parallelLanguageName: String = ""
    @Published var layoutDirection: LayoutDirection = .leftToRight

    // MARK: - Public Methods
    
    func favoritedButtonTapped() {}
    
}
