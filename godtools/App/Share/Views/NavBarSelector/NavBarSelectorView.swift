//
//  NavBarSelectorView.swift
//  godtools
//
//  Created by Levi Eggert on 1/31/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

protocol NavBarSelectorViewDelegate: AnyObject {
    
    func navBarSelectorTapped(navBarSelector: NavBarSelectorView, index: Int)
}

class NavBarSelectorView: UIView {
    
    private let stackView: UIStackView = UIStackView()
    private let selectorButtonTitles: [String]
    private let selectedColor: UIColor
    private let deselectedColor: UIColor
    
    private var selectorButtons: [UIButton] = Array()
    private var selectedIndex: Int = 0
    
    private weak var delegate: NavBarSelectorViewDelegate?
    
    required init(selectorButtonTitles: [String], selectedColor: UIColor, deselectedColor: UIColor, delegate: NavBarSelectorViewDelegate?) {
                
        self.selectorButtonTitles = selectorButtonTitles
        self.selectedColor = selectedColor
        self.deselectedColor = deselectedColor
        self.delegate = delegate
        
        let screenSize: CGSize = UIScreen.main.bounds.size
        let width: CGFloat = floor(screenSize.width * 0.53)
        
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: 32))
        
        setupLayout()
        
        reloadSelectorButtons(selectorButtonTitles: selectorButtonTitles)
        setSelectedIndex(selectedIndex: 0)
        
        relayoutForBoundsChange()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
        // layer
        layer.cornerRadius = 3
        clipsToBounds = true
        layer.borderColor = UIColor.white.cgColor
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
        
        for title in selectorButtonTitles {
                        
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
    }
    
    private func setSelectedIndex(selectedIndex: Int) {
        
        self.selectedIndex = selectedIndex
                
        for index in 0 ..< selectorButtons.count {
            
            let button: UIButton = selectorButtons[index]
            let isSelected: Bool = selectedIndex == index
            
            let buttonColor: UIColor = isSelected ? selectedColor : deselectedColor
            let titleColor: UIColor = isSelected ? deselectedColor : selectedColor
            
            button.backgroundColor = buttonColor
            button.setTitleColor(titleColor, for: .normal)
        }
    }
    
    @objc private func selectorButtonTapped(button: UIButton) {
        
        guard let selectedIndex = selectorButtons.firstIndex(of: button) else {
            return
        }
        
        setSelectedIndex(selectedIndex: selectedIndex)
        
        delegate?.navBarSelectorTapped(navBarSelector: self, index: selectedIndex)
    }
}
