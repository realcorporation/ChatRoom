//
//  MessageInputBar.swift
//  ChatRoom
//
//  Created by Keith Chan on 23/4/2018.
//  Copyright © 2018 co.real. All rights reserved.
//

import UIKit
import NextGrowingTextView

protocol GrowingTextViewDelegate: NSObjectProtocol {
    func growingTextView(_ textView: GrowingTextView, imagesDidPaste images: [UIImage])
}

open class GrowingTextView: NextGrowingTextView {
    
    weak var customDelegate: GrowingTextViewDelegate?
    
    var canHandlePasteImages: Bool = true
        
    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        
        if canHandlePasteImages && UIPasteboard.general.hasImages && action == #selector(paste(_:)) {
            return true
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
    
    override open func paste(_ sender: Any?) {
        if UIPasteboard.general.hasImages {
            guard let images = UIPasteboard.general.images else { return }
            customDelegate?.growingTextView(self, imagesDidPaste: images)
        } else {
            super.paste(sender)
        }
    }
}

protocol MessageInputBarDelegate: NSObjectProtocol {
    func messageInputBar(_ inputBar: MessageInputBar, willChangeHeight height: CGFloat)
    func messageInputBar(_ inputBar: MessageInputBar, didChangeHeight height: CGFloat)
    
    func messageInputBar(_ inputBar: MessageInputBar, textDidChange text: String)
    
    func messageInputBar(_ inputBar: MessageInputBar, imagesDidPaste images: [UIImage])
}

open class MessageInputBar: UIView {
    
    public enum State {
        case normal
        case textEditing
    }
    
    class BarItems {
        var state: State
        var leadingItems = [MessageInputBarItem]()
        var trailingItems = [MessageInputBarItem]()
        
        required init(state: State) {
            self.state = state
        }
    }
    
    open var canHandlePasteImages: Bool = true {
        didSet {
            growingTextView.canHandlePasteImages = canHandlePasteImages
        }
    }
    
    open var barItemsSpacing = CGFloat(8) {
        didSet {
            stackView.spacing = barItemsSpacing
        }
    }
    
    open private(set) var state: MessageInputBar.State = .normal {
        didSet {
            guard oldValue != state else { return }
            changeState(state)
        }
    }
    
    override open var intrinsicContentSize: CGSize {
        let margins = layoutMargins
        return CGSize(width: super.intrinsicContentSize.width, height: max(44.0, growingTextView.intrinsicContentSize.height + margins.top + margins.bottom))
    }
    
    override open class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    override open var backgroundColor: UIColor? {
        didSet {
            backgroundView.backgroundColor = backgroundColor
        }
    }
    
    weak var delegate: MessageInputBarDelegate?
    
    open private(set) var growingTextView: GrowingTextView = {
        let growingTextView = GrowingTextView(frame: .zero)
        growingTextView.minNumberOfLines = 1
        growingTextView.maxNumberOfLines = 5
        growingTextView.backgroundColor = .clear
        growingTextView.textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        growingTextView.layer.cornerRadius = 8
        growingTextView.layer.masksToBounds = true
        growingTextView.textView.font = UIFont.preferredFont(forTextStyle: .body)
        return growingTextView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .bottom
        stackView.spacing = 8
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    open private(set) var topHairline: UIView = {
        let topHairline = UIView()
        topHairline.backgroundColor = .lightGray
        return topHairline
    }()
    
    open var topHairLineHeight = CGFloat(1)
    
    private var backgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .white
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        return backgroundView
    }()
    
    private var normalStateBarItems = BarItems(state: .normal)
    private var textEditingStateBarItems = BarItems(state: .textEditing)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        initViews()
        setupDelegates()
    }
    
    private func initViews() {
        
        translatesAutoresizingMaskIntoConstraints = false
        layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        backgroundColor = .white
        
        growingTextView.customDelegate = self
        stackView.addArrangedSubview(growingTextView)
        
        addSubview(backgroundView)
        addSubview(stackView)
        
        NSLayoutConstraint.activate([backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     backgroundView.topAnchor.constraint(equalTo: topAnchor),
                                     backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 34)])
        
        let guide = layoutMarginsGuide
        NSLayoutConstraint.activate([stackView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
                                     stackView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
                                     stackView.topAnchor.constraint(equalTo: guide.topAnchor),
                                     stackView.bottomAnchor.constraint(equalTo: guide.bottomAnchor)])
        
        addSubview(topHairline)
    }
    
    private func setupDelegates() {
        growingTextView.delegates.willChangeHeight = { [weak self] height in
            guard let strongSelf = self else { return }
            
            strongSelf.delegate?.messageInputBar(strongSelf, willChangeHeight: height)
        }
        
        growingTextView.delegates.didChangeHeight = { [weak self] height in

            guard let strongSelf = self else { return }

            let margins = strongSelf.layoutMargins
            let adjustedHeight = max(44.0, height + margins.top + margins.bottom)
            
            guard strongSelf.frame.height != adjustedHeight else { return }
            
            strongSelf.delegate?.messageInputBar(strongSelf, didChangeHeight: adjustedHeight)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChangeNotification(_:)), name: NSNotification.Name.UITextViewTextDidChange, object: growingTextView.textView)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        topHairline.frame = CGRect(x: 0, y: 0, width: frame.width, height: topHairLineHeight)
    }
    
    open func setLeadingItems(_ leadingItems: [MessageInputBarItem], for state: MessageInputBar.State) {
        switch state {
        case .normal:
            normalStateBarItems.leadingItems = leadingItems
            break
        case .textEditing:
            textEditingStateBarItems.leadingItems = leadingItems
            break
        }
        
        configureStackView()
    }
    
    open func setTrailingItems(_ trailingItems: [MessageInputBarItem], for state: MessageInputBar.State) {
        switch state {
        case .normal:
            normalStateBarItems.trailingItems = trailingItems
            break
        case .textEditing:
            textEditingStateBarItems.trailingItems = trailingItems
            break
        }
        
        configureStackView()
    }
    
    // MARK: - Private Methods
    
    private func configureStackView() {
        stackView.arrangedSubviews.forEach { stackView.removeArrangedSubview($0) }
        
        for item in normalStateBarItems.leadingItems {
            item.isHidden = normalStateBarItems.state != state
            stackView.addArrangedSubview(item)
        }
        
        for item in textEditingStateBarItems.leadingItems {
            item.isHidden = textEditingStateBarItems.state != state
            stackView.addArrangedSubview(item)
        }
        
        stackView.addArrangedSubview(growingTextView)
        
        for item in normalStateBarItems.trailingItems {
            item.isHidden = normalStateBarItems.state != state
            stackView.addArrangedSubview(item)
        }
        
        for item in textEditingStateBarItems.trailingItems {
            item.isHidden = textEditingStateBarItems.state != state
            stackView.addArrangedSubview(item)
        }
    }
    
    private func changeState(_ state: State) {
        switch state {
        case .normal:
            normalStateBarItems.leadingItems.forEach { $0.isHidden = false }
            normalStateBarItems.trailingItems.forEach { $0.isHidden = false }
            textEditingStateBarItems.leadingItems.forEach { $0.isHidden = true }
            textEditingStateBarItems.trailingItems.forEach { $0.isHidden = true }
            break
        case .textEditing:
            if textEditingStateBarItems.leadingItems.count == 0 {
                normalStateBarItems.leadingItems.forEach { $0.isHidden = false }
            } else {
                normalStateBarItems.leadingItems.forEach { $0.isHidden = true }
                textEditingStateBarItems.leadingItems.forEach { $0.isHidden = false }
            }
            
            if textEditingStateBarItems.trailingItems.count == 0 {
                normalStateBarItems.trailingItems.forEach { $0.isHidden = false }
            } else {
                normalStateBarItems.trailingItems.forEach { $0.isHidden = true }
                textEditingStateBarItems.trailingItems.forEach { $0.isHidden = false }
            }
            break
        }
    }
    
    func resetState() {
        state = .normal
    }
    
    // MARK: - Notifications
    
    @objc private func textDidChangeNotification(_ noti: Notification) {
        guard let textView = noti.object as? UITextView else { return }
        
        if let text = textView.text, text.count > 0 {
            state = .textEditing
        } else {
            state = .normal
        }
        
        delegate?.messageInputBar(self, textDidChange: textView.text ?? "")
    }
}

extension MessageInputBar: GrowingTextViewDelegate {
    func growingTextView(_ textView: GrowingTextView, imagesDidPaste images: [UIImage]) {
        delegate?.messageInputBar(self, imagesDidPaste: images)
    }
}
