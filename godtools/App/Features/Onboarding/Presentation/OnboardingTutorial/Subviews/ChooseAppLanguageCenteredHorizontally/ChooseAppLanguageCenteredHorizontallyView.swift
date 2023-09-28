//
//  ChooseAppLanguageCenteredHorizontallyView.swift
//  godtools
//
//  Created by Levi Eggert on 9/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct ChooseAppLanguageCenteredHorizontallyView: View {
    
    private let buttonTitle: String
    private let buttonTappedClosure: (() -> Void)?
    
    init(buttonTitle: String, buttonTappedClosure: (() -> Void)?) {
        
        self.buttonTitle = buttonTitle
        self.buttonTappedClosure = buttonTappedClosure
    }
    
    var body: some View {
        
        ZStack(alignment: .center) {
            
            HStack(alignment: .center) {
                
                Spacer()
                
                ChooseAppLanguageButton(title: buttonTitle) {
                    buttonTappedClosure?()
                }
                
                Spacer()
            }
        }
    }
}
