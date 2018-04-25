//
//  MessageCell.swift
//  Example
//
//  Created by Keith Chan on 23/4/2018.
//  Copyright © 2018 co.real. All rights reserved.
//

import UIKit

class MessageCell: UICollectionViewCell {
    
    let textView: UITextView = {
        let textView = UITextView(frame: .zero, textContainer: nil)
        textView.isScrollEnabled = false
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.isEditable = false
        textView.isSelectable = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(textView)
        
        NSLayoutConstraint.activate([textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                                     textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                                     textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
                                     textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
