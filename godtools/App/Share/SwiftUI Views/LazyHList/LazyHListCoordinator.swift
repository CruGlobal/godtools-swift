//
//  LazyHListCoordinator.swift
//  godtools
//
//  Created by Levi Eggert on 5/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI
import UIKit

class LazyHListCoordinator<Content: View>: NSObject, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    private let lazyHList: LazyHList<Content>
    
    required init(lazyHList: LazyHList<Content>) {
        
        self.lazyHList = lazyHList
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lazyHList.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        lazyHList.itemTapped(indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: lazyHList.cellIdentifier, for: indexPath)
                
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        
        let itemView: Content = lazyHList.viewForItem(indexPath.row)
        let hostingView: UIHostingController = UIHostingController(rootView: itemView)
        
        let hostingParent: UIView = cell.contentView
        
        for subview in hostingParent.subviews {
            subview.removeFromSuperview()
        }
            
        hostingParent.addSubview(hostingView.view)
        hostingView.view.frame = hostingParent.bounds
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return lazyHList.itemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return lazyHList.itemSize
    }
}
