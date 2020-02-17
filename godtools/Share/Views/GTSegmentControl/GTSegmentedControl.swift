//
//  GTSegmentedControl.swift
//  godtools
//
//  Created by Levi Eggert on 1/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol GTSegmentedControlDelegate: class {
    func segmentedControl(segmentedControl: GTSegmentedControl, didSelect segment: GTSegmentType, at index: Int)
}

class GTSegmentedControl: UIView, NibBased {
    
    private static let selectedTitleColor: UIColor = UIColor(red: 0.353, green: 0.353, blue: 0.353, alpha: 1)
    private static let deselectedTitleColor: UIColor = UIColor(red: 0.745, green: 0.745, blue: 0.745, alpha: 1)
    
    private let cellReuseIdentifier: String = "cellReuseIdentifier"
    private let underlineWidthPercentageOfSegmentWidth: CGFloat = 0.56
    private let underlineHeight: CGFloat = 3
    
    private var segments: [GTSegmentType] = Array()
    private var segmentLayoutRects: [CGRect] = Array()
    private var totalSegmentWidth: CGFloat = 0
    private var shouldCenterSegmentsCollectionView: Bool = false
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
    
    func configure(segments: [GTSegmentType], delegate: GTSegmentedControlDelegate?) {
        
        self.segments = segments
        self.delegate = delegate
        
        invalidateLayout()
    }
    
    private func invalidateLayout() {
        
        for segment in segments {
            //let label: UILabel = createNewSegmentLabel(title: segment.title)
            //totalSegmentWidth = totalSegmentWidth + label.frame.size.width
            //segmentLabels.append(label)
        }
        
        var segmentsCollectionX: CGFloat
        var segmentsCollectionWidth: CGFloat
        
        if shouldCenterSegmentsCollectionView {
            segmentsCollectionX = (bounds.size.width / 2) - (totalSegmentWidth / 2)
            segmentsCollectionWidth = totalSegmentWidth
        }
        else {
            segmentsCollectionX = 0
            segmentsCollectionWidth = bounds.size.width
        }
        
        segmentsCollectionView.frame = CGRect(
            x: segmentsCollectionX,
            y: 0,
            width: segmentsCollectionWidth,
            height: segmentHeight
        )
        
        segmentsCollectionView.drawBorder(color: .green)
        
        /*
        underline.frame = CGRect(
            x: 0,
            y: bounds.size.height - underlineHeight,
            width: segmentWidth * underlineWidthPercentageOfSegmentWidth,
            height: underlineHeight
        )*/
        
        repositionUnderlineToSelectedSegment(animated: false)
        
        segmentsCollectionView.reloadData()
    }
    
    private var segmentHeight: CGFloat {
        return bounds.size.height - underlineHeight
    }
    
    private var selectedSegment: Int = 0 {
        didSet {
            repositionUnderlineToSelectedSegment(animated: true)
        }
    }
    
    private func repositionUnderlineToSelectedSegment(animated: Bool) {
        
        /*
        let isInBounds: Bool = selectedSegment >= 0 && selectedSegment < segments.count
        
        if isInBounds {
            
            let segmentOriginX: CGFloat = CGFloat(selectedSegment) * segmentWidth
            
            let newFramePosition: CGRect = CGRect(
                x: (segmentOriginX + (segmentWidth / 2)) - (underline.frame.size.width / 2),
                y: underline.frame.origin.y,
                width: underline.frame.size.width,
                height: underline.frame.size.height
            )
                        
            if animated {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                    self?.underline.frame = newFramePosition
                }, completion: nil)
            }
            else {
                underline.frame = newFramePosition
            }
        }*/
    }
    
    private func createNewSegmentLabel(title: String) -> UILabel {
        
        let label: UILabel = UILabel()
        label.font = FontLibrary.sfProTextRegular.font(size: 17)
        label.text = title
        label.textColor = GTSegmentedControl.deselectedTitleColor
        label.textAlignment = .center
        label.sizeToFit()
        var labelFrame: CGRect = label.frame
        labelFrame.size.height = segmentHeight
        label.frame = labelFrame
        label.drawBorder()
        
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
        
        segmentLabel.frame = CGRect(x: 0, y: 0, width: segmentLabel.frame.size.width, height: segmentHeight)
        
        //cell.title = segment.title
        //cell.titleColor = indexPath.item == selectedSegment ? GTSegmentedControl.selectedTitleColor : GTSegmentedControl.deselectedTitleColor
        
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
        return 0
    }
}
