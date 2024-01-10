//
//  NavBarSelectorView.swift
//  godtools
//
//  Created by Levi Eggert on 1/31/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import Combine

class NavBarSelectorView: UIView {
    
    private let stackView: UIStackView = UIStackView()
    private let selectorButtonTitles: [String]
    private let layoutDirection: UISemanticContentAttribute
    private let borderColor: UIColor
    private let titleFont: UIFont?
    private let highlightSelectorPublisher: AnyPublisher<Int, Never>
    
    private var selectedColor: UIColor
    private var deselectedColor: UIColor
    private var selectedTitleColor: UIColor?
    private var deselectedTitleColor: UIColor?
    private var selectorButtons: [UIButton] = Array()
    private var highlightedIndex: Int = 0
    private var selectorTappedClosure: ((_ index: Int) -> Void)
    private var cancellables: Set<AnyCancellable> = Set()
            
    init(selectorButtonTitles: [String], layoutDirection: UISemanticContentAttribute, borderColor: UIColor = .white, selectedColor: UIColor = .darkGray, deselectedColor: UIColor = .lightGray, selectedTitleColor: UIColor? = nil, deselectedTitleColor: UIColor? = nil, titleFont: UIFont? = nil, selectorTappedClosure: @escaping ((_ index: Int) -> Void), highlightSelectorPublisher: AnyPublisher<Int, Never>) {
                
        self.selectorButtonTitles = selectorButtonTitles
        self.layoutDirection = layoutDirection
        self.borderColor = borderColor
        self.selectedColor = selectedColor
        self.deselectedColor = deselectedColor
        self.selectedTitleColor = selectedTitleColor
        self.deselectedTitleColor = deselectedTitleColor
        self.titleFont = titleFont
        self.selectorTappedClosure = selectorTappedClosure
        self.highlightSelectorPublisher = highlightSelectorPublisher
        
        let buttonWidth: CGFloat = 88
        let width: CGFloat = CGFloat(selectorButtonTitles.count) * buttonWidth
                
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: 32))
        
        setupLayout()
        
        reloadSelectorButtons(selectorButtonTitles: selectorButtonTitles)
        
        relayoutForBoundsChange()
        
        highlightSelector(highlightIndex: convertIndexForLayoutDirection(index: 0))
        
        highlightSelectorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (index: Int) in
                
                guard let index = self?.convertIndexForLayoutDirection(index: index) else {
                    return
                }
                
                self?.highlightSelector(highlightIndex: index)
            }
            .store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
        // layer
        layer.cornerRadius = 5
        clipsToBounds = true
        setBorderColor(color: borderColor)
        layer.borderWidth = 1
                
        // stackView
        addSubview(stackView)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        relayoutForBoundsChange()
    }
    
    private func convertIndexForLayoutDirection(index: Int) -> Int {
        
        let length: Int = selectorButtonTitles.count
        
        guard index >= 0 && index < length else {
            return index
        }
        
        if layoutDirection == .forceRightToLeft {
            
            return (length - 1) - index
        }
        else {
            
            return index
        }
    }
    
    var selectedIndex: Int {
        return convertIndexForLayoutDirection(index: highlightedIndex)
    }
    
    func setSelectedColor(selectedColor: UIColor, deselectedColor: UIColor) {
        
        self.selectedColor = selectedColor
        self.deselectedColor = deselectedColor
        
        reloadSelectorButtons(selectorButtonTitles: selectorButtonTitles)
    }
    
    func setSelectedTitleColor(selectedTitleColor: UIColor, deselectedTitleColor: UIColor) {
        
        self.selectedTitleColor = selectedTitleColor
        self.deselectedTitleColor = deselectedTitleColor
        
        reloadSelectorButtons(selectorButtonTitles: selectorButtonTitles)
    }
    
    func setBorderColor(color: UIColor) {
        layer.borderColor = color.cgColor
    }
    
    private func relayoutForBoundsChange() {
        
        stackView.frame = bounds
    }
    
    private func removeSelectorButtons() {
        
        selectorButtons.removeAll()
        
        for subview in stackView.arrangedSubviews {
            subview.removeFromSuperview()
        }
    }
    
    private func reloadSelectorButtons(selectorButtonTitles: [String]) {
        
        removeSelectorButtons()
        
        let buttonTitles: [String]
        
        if layoutDirection == .forceRightToLeft {
            buttonTitles = selectorButtonTitles.reversed()
        }
        else {
            buttonTitles = selectorButtonTitles
        }
        
        for title in buttonTitles {
                        
            let button: UIButton = UIButton(type: .custom)
            
            button.setTitle(title, for: .normal)
            
            stackView.addArrangedSubview(button)
            
            selectorButtons.append(button)
            
            button.addTarget(
                self,
                action: #selector(selectorButtonTapped(button:)),
                for: .touchUpInside
            )
        }
        
        highlightSelector(highlightIndex: highlightedIndex)
    }
    
    private func highlightSelector(highlightIndex: Int) {
        
        for index in 0 ..< selectorButtons.count {
            
            let button: UIButton = selectorButtons[index]
            let isSelected: Bool = highlightIndex == index
            
            let buttonColor: UIColor = isSelected ? selectedColor : deselectedColor
            let titleColor: UIColor
            
            if isSelected {
                titleColor = selectedTitleColor ?? deselectedColor
            }
            else {
                titleColor = deselectedTitleColor ?? selectedColor
            }
            
            button.backgroundColor = buttonColor
            button.setTitleColor(titleColor, for: .normal)
            button.titleLabel?.font = titleFont
            button.titleLabel?.lineBreakMode = .byTruncatingTail
        }
    }
    
    @objc private func selectorButtonTapped(button: UIButton) {
        
        guard let tappedButtonIndex = selectorButtons.firstIndex(of: button) else {
            return
        }
        
        self.highlightedIndex = tappedButtonIndex
        
        highlightSelector(highlightIndex: tappedButtonIndex)
        
        let indexForLayoutDirection = convertIndexForLayoutDirection(index: tappedButtonIndex)
                
        selectorTappedClosure(indexForLayoutDirection)
    }
}
