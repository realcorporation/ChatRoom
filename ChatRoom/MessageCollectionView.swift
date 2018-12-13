//
//  MessageCollectionView.swift
//  ChatRoom
//
//  Created by Keith Chan on 23/4/2018.
//  Copyright © 2018 co.real. All rights reserved.
//

import UIKit

protocol MessageCollectionViewTouchDelegate: NSObjectProtocol {
    func collectionViewDidEndTouches(_ collectionView: MessageCollectionView)
}

open class MessageCollectionView: UICollectionView {
    
    weak var touchDelegate: MessageCollectionViewTouchDelegate?
    
    var compatibleContentInset: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return adjustedContentInset
        } else {
            return contentInset
        }
    }
    
    var minimumContentOffsetY: CGFloat {
        return -compatibleContentInset.top
    }
    
    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        touchDelegate?.collectionViewDidEndTouches(self)
    }
    
    func scrollToBottom(at indexPath: IndexPath, animated: Bool) {
        let collectionViewContentSize = collectionViewLayout.collectionViewContentSize
        let visibleHeight = frame.height - compatibleContentInset.bottom - compatibleContentInset.top
        
        // weird calculation in iOS
        let iOSScrollableHeight = frame.height - compatibleContentInset.bottom + compatibleContentInset.top
        
        if collectionViewContentSize.height < iOSScrollableHeight && collectionViewContentSize.height > visibleHeight {
            let contentOffsetY = collectionViewContentSize.height - visibleHeight - compatibleContentInset.top
            setContentOffset(CGPoint(x: contentOffset.x, y: contentOffsetY), animated: animated)
        } else {
            scrollToItem(at: indexPath, at: .bottom, animated: animated)
        }
    }
    
    public func lastIndexPath() -> IndexPath? {
        
        guard numberOfSections > 0 else { return nil }
        
        let lastSection = numberOfSections - 1
        
        guard numberOfItems(inSection: lastSection) > 0 else { return nil }
        
        let lastItem = numberOfItems(inSection: lastSection) - 1
        
        return IndexPath(item: lastItem, section: lastSection)
    }
}
