//
//  GTSegmentedControl.swift
//  godtools
//
//  Created by Levi Eggert on 1/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol GTSegmentedControlDelegate: class {
    func segmentedControl(segmentedControl: GTSegmentedControl, didSelect segment: GTSegment, at index: Int)
}

class GTSegmentedControl: UIView, NibBased {
    
    private static let selectedTitleColor: UIColor = UIColor(red: 0.353, green: 0.353, blue: 0.353, alpha: 1)
    private static let deselectedTitleColor: UIColor = UIColor(red: 0.745, green: 0.745, blue: 0.745, alpha: 1)
    private static let underlineWidthPercentageOfSegmentWidth: CGFloat = 0.56
    
    private(set) var segments: [GTSegment] = Array()
    
    weak var delegate: GTSegmentedControlDelegate?
    
    @IBOutlet weak private var segmentsCollectionView: UICollectionView!
    @IBOutlet weak private var underline: UIView!
    
    @IBOutlet weak private var underlineLeading: NSLayoutConstraint!
    @IBOutlet weak private var underlineWidth: NSLayoutConstraint!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        loadNib()
        
        underline.backgroundColor = UIColor(red: 0.231, green: 0.643, blue: 0.859, alpha: 1)
        
        segmentsCollectionView.register(
            UINib(nibName: GTSegmentCell.nibName, bundle: nil),
            forCellWithReuseIdentifier: GTSegmentCell.reuseIdentifier
        )
                
        segmentsCollectionView.delegate = self
        segmentsCollectionView.dataSource = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        underlineWidth.constant = underlineWidthValue
        repositionUnderlineToSelectedSegment(animated: false)
    }
    
    func configure(segments: [GTSegment], delegate: GTSegmentedControlDelegate?) {
        self.segments = segments
        self.delegate = delegate
        segmentsCollectionView.reloadData()
    }
    
    private var segmentWidth: CGFloat {
        return segments.count > 0 ? bounds.size.width / CGFloat(segments.count) : 50
    }
    
    private var segmentHeight: CGFloat {
        return bounds.size.height
    }
    
    private var underlineWidthValue: CGFloat {
        return segmentWidth * GTSegmentedControl.underlineWidthPercentageOfSegmentWidth
    }
    
    private var selectedSegment: Int = 0 {
        didSet {
            repositionUnderlineToSelectedSegment(animated: true)
        }
    }
    
    private func repositionUnderlineToSelectedSegment(animated: Bool) {
        
        let isInBounds: Bool = selectedSegment >= 0 && selectedSegment < segments.count
        
        if isInBounds {
            guard let cellFrame = segmentsCollectionView.layoutAttributesForItem(at: IndexPath(item: selectedSegment, section: 0))?.frame else {
                return
            }
                            
            underlineLeading.constant = (cellFrame.origin.x + (cellFrame.size.width / 2)) - (underlineWidthValue / 2)
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                self?.layoutIfNeeded()
            }, completion: nil)
        }
    }
}

extension GTSegmentedControl: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return segments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedSegment = indexPath.item
        segmentsCollectionView.reloadData()
                
        delegate?.segmentedControl(
            segmentedControl: self,
            didSelect: segments[indexPath.item],
            at: indexPath.item
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: GTSegmentCell = segmentsCollectionView.dequeueReusableCell(withReuseIdentifier: GTSegmentCell.reuseIdentifier, for: indexPath) as! GTSegmentCell
        let segment: GTSegment = segments[indexPath.row]
        
        cell.backgroundColor = .clear
        cell.title = segment.title
                
        cell.titleColor = indexPath.item == selectedSegment ? GTSegmentedControl.selectedTitleColor : GTSegmentedControl.deselectedTitleColor
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
                    
        return CGSize(width: segmentWidth, height: segmentHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
