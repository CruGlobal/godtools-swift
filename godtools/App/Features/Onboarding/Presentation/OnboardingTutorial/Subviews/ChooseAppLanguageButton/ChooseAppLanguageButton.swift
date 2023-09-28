//
//  ChooseAppLanguageButton.swift
//  godtools
//
//  Created by Levi Eggert on 9/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct ChooseAppLanguageButton: View {

    private let contentHorizontalInsets: CGFloat = 18
    private let backgroundColor: Color = Color.red
    private let cornerRadius: CGFloat = 25
    private let width: CGFloat = 175
    private let height: CGFloat = 50
    private let title: String
    private let titleColor: Color = Color.black
    private let titleFont: Font = Font.system(size: 17)
    private let tappedClosure: (() -> Void)?
    
    init(title: String, tappedClosure: (() -> Void)?) {
        
        self.title = title
        self.tappedClosure = tappedClosure
    }
    
    var body: some View {
        
        ZStack(alignment: .center) {
            
            HStack(alignment: .center) {
                
                Spacer()
                
                Button(action: {
                    tappedClosure?()
                }) {
                    
                    HStack(alignment: .center, spacing: 0) {
                        
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: contentHorizontalInsets, height: 1)
                        
                        Rectangle()
                            .frame(width: 20, height: 20)
                        
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: 11, height: 1)
                        
                        Text(title)
                            .font(titleFont)
                            .foregroundColor(titleColor)
                        
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: contentHorizontalInsets, height: 1)
                    }
                }
                .frame(minWidth: 175)
                .frame(height: height, alignment: .center)
                .background(backgroundColor)
                .cornerRadius(cornerRadius)
                
                Spacer()
            }
        }
    }
}

struct ChooseAppLanguageButton_Preview: PreviewProvider {
    
    static var previews: some View {
        
        ChooseAppLanguageButton(title: "Choose App Language", tappedClosure: nil)
    }
}
