//
//  KeyboardObserverType.swift
//  godtools
//
//  Created by Levi Eggert on 11/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol KeyboardObserverType {
    
    var keyboardStateDidChangeSignal: SignalValue<KeyboardStateChange> { get }
    var keyboardHeightDidChangeSignal: SignalValue<Double> { get }
    var keyboardState: KeyboardState { get }
    var keyboardHeight: Double { get }
    var keyboardAnimationDuration: Double { get }
    var keyboardIsUp: Bool { get }
    var isObservingKeyboardChanges: Bool { get }
    
    func startObservingKeyboardChanges()
    func stopObservingKeyboardChanges()
}
