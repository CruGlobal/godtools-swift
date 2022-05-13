//
//  GTSegmentedControl.swift
//  godtools
//
//  Created by Levi Eggert on 1/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol GTSegmentedControlDelegate: AnyObject {
    func segmentedControl(segmentedControl: GTSegmentedControl, didSelect segment: GTSegmentType, at index: Int)
}

class GTSegmentedControl: UIView, NibBased {
    
    struct LayoutConfig {
        var selectedTitleColor: UIColor
        var deselectedTitleColor: UIColor
        var segmentFont: UIFont?
        var spacingBetweenSegments: CGFloat
        var segmentLabelBottomSpacingToUnderline: CGFloat
        var underlineWidthPercentageOfSegmentWidth: CGFloat
        var underlineHeight: CGFloat
        
        static var defaultLayout: LayoutConfig {
            return LayoutConfig(
                selectedTitleColor: UIColor(red: 0.353, green: 0.353, blue: 0.353, alpha: 1),
                deselectedTitleColor: UIColor(red: 0.745, green: 0.745, blue: 0.745, alpha: 1),
                segmentFont: FontLibrary.sfProTextSemibold.uiFont(size: 19),
                spacingBetweenSegments: 30,
                segmentLabelBottomSpacingToUnderline: 4,
                underlineWidthPercentageOfSegmentWidth: 1.2,
                underlineHeight: 3
            )
        }
    }
        
    private let cellReuseIdentifier: String = "cellReuseIdentifier"
    
    private var segments: [GTSegmentType] = Array()
    private var segmentLayoutRects: [CGRect] = Array()
    private var layout: LayoutConfig = LayoutConfig.defaultLayout
    private var currentBounds: CGRect = .zero
    
    private weak var delegate: GTSegmentedControlDelegate?
    
    @IBOutlet weak private var segmentsCollectionView: UICollectionView!
    @IBOutlet weak private var underline: UIView!
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        loadNib()
                
        underline.backgroundColor = UIColor(red: 0.231, green: 0.643, blue: 0.859, alpha: 1)
                
        segmentsCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        segmentsCollectionView.delegate = self
        segmentsCollectionView.dataSource = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        if currentBounds.size.width != bounds.size.width || currentBounds.size.height != bounds.size.height {
            currentBounds = bounds
            invalidateLayout()
        }
    }
    
    func configure(segments: [GTSegmentType], delegate: GTSegmentedControlDelegate?, layout: GTSegmentedControl.LayoutConfig = LayoutConfig.defaultLayout) {
        
        self.segments = segments
        self.delegate = delegate
        self.layout = layout
        
        var prevLayoutRect: CGRect?
        for segment in segments {
            
            let label: UILabel = createNewSegmentLabel(title: segment.title)
            let layoutRect: CGRect
            
            if let prevLayoutRect = prevLayoutRect {
                layoutRect = CGRect(
                    x: prevLayoutRect.origin.x + prevLayoutRect.size.width + layout.spacingBetweenSegments,
                    y: 0,
                    width: label.frame.size.width,
                    height: label.frame.size.height
                )
            }
            else {
                layoutRect = CGRect(x: 0, y: 0, width: label.frame.size.width, height: label.frame.size.height)
            }
            
            segmentLayoutRects.append(layoutRect)
            prevLayoutRect = layoutRect
        }
        
        invalidateLayout()
    }
    
    private func invalidateLayout() {
        
        var segmentsCollectionX: CGFloat
        var segmentsCollectionWidth: CGFloat
        
        if shouldCenterSegmentsCollectionView {
            segmentsCollectionX = (bounds.size.width / 2) - (totalSegmentWidth / 2)
            segmentsCollectionWidth = totalSegmentWidth
            segmentsCollectionView.isScrollEnabled = false
        }
        else {
            segmentsCollectionX = 0
            segmentsCollectionWidth = bounds.size.width
            segmentsCollectionView.isScrollEnabled = true
        }
        
        segmentsCollectionView.frame = CGRect(
            x: segmentsCollectionX,
            y: 0,
            width: segmentsCollectionWidth,
            height: segmentHeight
        )
                
        repositionUnderlineToSelectedSegment(animated: false)
        
        segmentsCollectionView.reloadData()
    }
    
    private var totalSegmentWidth: CGFloat {
        if let lastLayoutRect = segmentLayoutRects.last {
            return lastLayoutRect.origin.x + lastLayoutRect.size.width
        }
        return 0
    }
    
    private var shouldCenterSegmentsCollectionView: Bool {
        return totalSegmentWidth < bounds.size.width
    }

    private var segmentHeight: CGFloat {
        return bounds.size.height - layout.underlineHeight
    }
    
    private var selectedSegment: Int = 0 {
        didSet {
            repositionUnderlineToSelectedSegment(animated: true)
        }
    }
    
    private func repositionUnderlineToSelectedSegment(animated: Bool) {
        
        let isInBounds: Bool = selectedSegment >= 0 && selectedSegment < segments.count
        
        if isInBounds {
            
            let segmentLayoutRect: CGRect = segmentLayoutRects[selectedSegment]
            let underlineWidth: CGFloat = segmentLayoutRect.size.width * layout.underlineWidthPercentageOfSegmentWidth
            
            let newFramePosition: CGRect = CGRect(
                x: (segmentLayoutRect.origin.x + (segmentLayoutRect.size.width / 2)) - (underlineWidth / 2),
                y: bounds.size.height - layout.underlineHeight,
                width: underlineWidth,
                height: layout.underlineHeight
            )
            
            let underlineView: UIView = underline
            underlineView.removeFromSuperview()
            segmentsCollectionView.addSubview(underlineView)
            segmentsCollectionView.clipsToBounds = false
                        
            if animated {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                    self?.underline.frame = newFramePosition
                }, completion: nil)
            }
            else {
                underline.frame = newFramePosition
            }
        }
    }
    
    private func createNewSegmentLabel(title: String) -> UILabel {
        
        let label: UILabel = UILabel()
        label.font = layout.segmentFont
        label.text = title
        label.textColor = layout.deselectedTitleColor
        label.textAlignment = .center
        label.sizeToFit()
        
        return label
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
        
        let cell: UICollectionViewCell = segmentsCollectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath)
        let segment: GTSegmentType = segments[indexPath.row]
        let segmentLabel: UILabel = createNewSegmentLabel(title: segment.title)
        
        cell.backgroundColor = .clear
        
        let segmentView: UIView = cell.contentView
        for subview in segmentView.subviews {
            subview.removeFromSuperview()
        }
        
        segmentView.addSubview(segmentLabel)
        
        segmentLabel.frame = CGRect(
            x: 0,
            y: segmentHeight - segmentLabel.frame.size.height - layout.segmentLabelBottomSpacingToUnderline,
            width: segmentLabel.frame.size.width,
            height: segmentLabel.frame.size.height
        )
        
        segmentLabel.textColor = indexPath.item == selectedSegment ? layout.selectedTitleColor : layout.deselectedTitleColor
                        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let segment: GTSegmentType = segments[indexPath.row]
        let segmentLabel: UILabel = createNewSegmentLabel(title: segment.title)
        
        return CGSize(
            width: segmentLabel.frame.size.width,
            height: segmentHeight
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return layout.spacingBetweenSegments
    }
}
