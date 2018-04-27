//
//  MessageViewController.swift
//  ChatRoom
//
//  Created by Keith Chan on 23/4/2018.
//  Copyright © 2018 co.real. All rights reserved.
//

import UIKit

public protocol MessageViewControllerDelegate: NSObjectProtocol {
    func messageViewController(_ controller: MessageViewController, textWillSubmit text: String)
    func messageViewController(_ controller: MessageViewController, textDidClear text: String)
    func messageViewController(_ controller: MessageViewController, imagesDidPaste images: [UIImage])
    func messageViewController(_ controller: MessageViewController, typingStateDidChange typingState: MessageViewController.TypingState)
}

public extension MessageViewControllerDelegate {
    func messageViewController(_ controller: MessageViewController, typingStateDidChange typingState: MessageViewController.TypingState) {
        // optional
    }
}

open class MessageViewController: UIViewController {
    
    public enum TypingState {
        case idle
        case typing
    }
    
    open weak var delegate: MessageViewControllerDelegate?
    
    /// Only work when datasource setup before first layout
    open var shouldScrollToBottomWhenFirstLayout = true
    
    open var typingDelaySeconds = TimeInterval(2)
    
    open private(set) var typingState: TypingState = .idle {
        didSet {
            delegate?.messageViewController(self, typingStateDidChange: typingState)
        }
    }
    
    open private(set) var messageCollectionView: MessageCollectionView
    open private(set) var messageCollectionViewLayout = MessageCollectionViewFlowLayout()
    
    open private(set) var messageInputBar = MessageInputBar(frame: .zero)
    
    private var inputBarBottomConstraint: NSLayoutConstraint?
    private var inputBarHeightConstraint: NSLayoutConstraint?
    
    private var didLayoutSubviews = false
    
    private var typingTimer: Timer?
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {

        messageCollectionView = MessageCollectionView(frame: UIScreen.main.bounds, collectionViewLayout: messageCollectionViewLayout)
        messageCollectionView.bounces = true
        messageCollectionView.backgroundColor = .white
        messageCollectionView.alwaysBounceVertical = true
        messageCollectionView.showsHorizontalScrollIndicator = false
        messageCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 11.0, *) {
            messageCollectionView.keyboardDismissMode = .onDrag
        }
        
        super.init(nibName: nil, bundle: nil)
        
        messageCollectionView.touchDelegate = self
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView(messageCollectionView, layout: messageCollectionViewLayout)
        configureInputBar(messageInputBar)
        
        view.backgroundColor = .white
        
        view.addSubview(messageCollectionView)
        
        messageInputBar.delegate = self
        messageInputBar.translatesAutoresizingMaskIntoConstraints = false
    
        view.addSubview(messageInputBar)
        
        
        NSLayoutConstraint.activate([messageCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
                                     messageCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     messageCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     messageCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)])
        
        NSLayoutConstraint.activate([messageInputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     messageInputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)])
        
        inputBarHeightConstraint = messageInputBar.heightAnchor.constraint(equalToConstant: messageInputBar.intrinsicContentSize.height)
        inputBarHeightConstraint?.isActive = true
        
        if #available(iOS 11.0, *) {
            inputBarBottomConstraint = messageInputBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        } else {
            inputBarBottomConstraint = messageInputBar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        }
        inputBarBottomConstraint?.isActive = true
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardNotification(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
    }
    
    deinit {
        if typingTimer != nil {
            typingTimer?.invalidate()
            typingTimer = nil
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !didLayoutSubviews {
            didLayoutSubviews = true
            messageCollectionView.contentInset.bottom = messageInputBar.frame.height
            messageCollectionView.scrollIndicatorInsets = messageCollectionView.contentInset
            
            if shouldScrollToBottomWhenFirstLayout {
                scrollToBottom(animated: false)
            }
        }
    }
    
    // MARK: - Notifications

    @objc private func keyboardNotification(notification: Notification) {
        
        if let userInfo = notification.userInfo,
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber {
        
            let endFrameY = endFrame.origin.y
            let duration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRaw = animationCurveRawNSN.uintValue
            let animationCurve: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            
            var bottomContentInset = CGFloat(messageInputBar.frame.height)
            var contentOffsetYDiff = endFrame.height
            if #available(iOS 11.0, *) {
                contentOffsetYDiff -= view.safeAreaInsets.bottom
            }
            
            if endFrameY >= UIScreen.main.bounds.size.height {
                inputBarBottomConstraint?.constant = 0.0
                contentOffsetYDiff = -contentOffsetYDiff
                
            } else {
                
                bottomContentInset += endFrame.height
                
                var constant = -endFrame.height
                if #available(iOS 11.0, *) {
                    constant += view.safeAreaInsets.bottom
                    bottomContentInset -= view.safeAreaInsets.bottom
                }
                inputBarBottomConstraint?.constant = constant
            }

            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: {
                                self.view.layoutIfNeeded()
                                self.messageCollectionView.contentOffset.y += contentOffsetYDiff
                                self.messageCollectionView.contentInset.bottom = bottomContentInset
                                self.messageCollectionView.scrollIndicatorInsets = self.messageCollectionView.contentInset
                           },
                           completion: nil)
        }
    }
    
    // MARK: - Configurations
    
    open func configureCollectionView(_ collectionView: MessageCollectionView, layout: MessageCollectionViewFlowLayout) {

    }
    
    open func configureInputBar(_ inputBar: MessageInputBar) {
        
    }
    
    // MARK: - Actions
    
    open func reloadData(shouldScrollToBottom: Bool, animated: Bool) {
        messageCollectionView.reloadData()
        if animated {
            messageCollectionView.performBatchUpdates(nil) { [weak self] _ in
                self?.scrollToBottom(animated: animated)
            }
        } else {
            scrollToBottom(animated: animated)
        }
        
    }
    
    open func submitInput() {
        guard let text = messageInputBar.growingTextView.textView.text, text.count > 0 else { return }
        typingState = .idle
        delegate?.messageViewController(self, textWillSubmit: text)
        clearInput()
    }
    
    open func clearInput() {
        guard let text = messageInputBar.growingTextView.textView.text, text.count > 0 else { return }
        messageInputBar.growingTextView.textView.text = ""
        messageInputBar.resetState()
        delegate?.messageViewController(self, textDidClear: text)
    }
    
    open func scrollToBottom(animated: Bool) {
        guard let lastIndexPath = messageCollectionView.lastIndexPath() else { return }
        messageCollectionView.scrollToBottom(at: lastIndexPath, animated: animated)
    }
}

extension MessageViewController: MessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: MessageInputBar, willChangeHeight height: CGFloat) {
        
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didChangeHeight height: CGFloat) {
        
        guard let constraint = inputBarHeightConstraint else { return }
        
        let oldConstant = constraint.constant
        constraint.constant = height
        
        let diff = height - oldConstant
        
        var bottomContentInset = view.frame.height - inputBar.frame.minY + diff
        if #available(iOS 11.0, *) {
            bottomContentInset -= view.safeAreaInsets.bottom
        }
        
        UIView.animate(withDuration: 0.2) {
            
            self.messageCollectionView.contentOffset.y += diff
            self.messageCollectionView.contentInset.bottom = bottomContentInset
            self.messageCollectionView.scrollIndicatorInsets = self.messageCollectionView.contentInset
            
            // will affect cell layout
            self.view.layoutIfNeeded()
        }
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, textDidChange text: String) {
        typingState = .typing
        
        if typingTimer != nil {
            typingTimer?.invalidate()
            typingTimer = nil
        }
        
        typingTimer = Timer.scheduledTimer(withTimeInterval: typingDelaySeconds, repeats: false, block: { [weak self] _ in
            self?.typingState = .idle
        })
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, imagesDidPaste images: [UIImage]) {
        delegate?.messageViewController(self, imagesDidPaste: images)
    }
}

extension MessageViewController: MessageCollectionViewTouchDelegate {
    func collectionViewDidEndTouches(_ collectionView: MessageCollectionView) {
        if messageInputBar.growingTextView.isFirstResponder {
            let _ = messageInputBar.growingTextView.resignFirstResponder()
        }
    }
}
