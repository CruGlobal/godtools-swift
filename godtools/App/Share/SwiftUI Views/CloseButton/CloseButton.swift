//
//  CloseButton.swift
//  godtools
//
//  Created by Levi Eggert on 5/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct CloseButton: View {
    
    private let buttonSize: CGFloat
    private let tapped: (() -> Void)
    
    init(buttonSize: CGFloat = 44, tapped: @escaping (() -> Void)) {
        
        self.buttonSize = buttonSize
        self.tapped = tapped
    }
    
    var body: some View {
        Button {
            tapped()
        } label: {
            Image(ImageCatalog.navClose.name)
        }
        .frame(minWidth: buttonSize, minHeight: buttonSize)
    }
}
