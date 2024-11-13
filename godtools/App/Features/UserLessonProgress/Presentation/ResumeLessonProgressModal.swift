//
//  ResumeLessonProgressModal.swift
//  godtools
//
//  Created by Rachael Skeath on 10/29/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import SwiftUI

struct ResumeLessonProgressModal: View {
    
    private let buttonHeight: CGFloat = 48
    private let startOverClosure: () -> Void
    private let continueClosure: () -> Void
    
    init(startOverClosure: @escaping () -> Void, continueClosure: @escaping () -> Void) {
        self.startOverClosure = startOverClosure
        self.continueClosure = continueClosure
    }
    
    var body: some View {

        ZStack {
            if #available(iOS 15.0, *) {
                Color.clear
                    .edgesIgnoringSafeArea(.all)
                    .background(.ultraThinMaterial)
            } else {
                VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                    .edgesIgnoringSafeArea(.all)
            }
            
            VStack {
                Text("Resume Progress")
                
                Text("Pickup where you left off?")
                
                HStack {
                    GTWhiteButton(title: "Start Over", width: 133, height: buttonHeight) {
                        startOverClosure()
                    }
                    GTBlueButton(title: "Continue", width: 133, height: buttonHeight) {
                        continueClosure()
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(6)
            .shadow(color: Color.black.opacity(0.25), radius: 3, y: 3)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(Color.clear, lineWidth: 2)
            )
        }

    }
}
