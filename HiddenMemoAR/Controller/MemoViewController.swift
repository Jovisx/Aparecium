//
//  MemoViewController.swift
//  HiddenMemoAR
//
//  Created by HyungJung Kim on 19/11/2018.
//  Copyright © 2018 HyungJung Kim. All rights reserved.
//

import UIKit
import ARKit
import AVKit
import CoreGraphics

class MemoViewController: UIViewController {
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var notesTextView: UITextView!
    @IBOutlet weak private var imageView: UIImageView!
    
    private let displayDuration: TimeInterval = 60.0
    private var hideTimer: Timer?
    
    private lazy var playerViewController: AVPlayerViewController = {
        return children.lazy.compactMap { $0 as? AVPlayerViewController }.first!
    }()
    
    @IBAction func tabCloseButton(_ sender: Any) {
        if let player = self.playerViewController.player {
            player.pause()
        }
        
        self.setIsHidden(true, animated: true)
    }
    
    func show(_ hiddenMemo: HiddenMemo, isAutoHide: Bool = false) {
        self.hideTimer?.invalidate()
        
        self.titleLabel.text = hiddenMemo.title
        
        if let notes = hiddenMemo.content?.notes {
            self.notesTextView.text = notes
            self.imageView.image = nil
            self.playerViewController.view.isHidden = true
        } else if let notesImage = hiddenMemo.content?.notesImage {
            self.notesTextView.text = ""
            self.imageView.image = notesImage.alphaImage(0.9)
            self.playerViewController.view.isHidden = true
        } else if let videoURL = hiddenMemo.content?.videoURL {
            self.notesTextView.text = ""
            self.imageView.image = nil
            self.playerViewController.view.isHidden = false
            
            self.playerViewController.player = AVPlayer(url: videoURL)
            
            if let player = playerViewController.player {
                player.play()
            }
        }
        
        self.setIsHidden(false, animated: true)
        
        if isAutoHide {
            self.hideTimer = Timer.scheduledTimer(withTimeInterval: displayDuration, repeats: false) { [weak self] _ in
                self?.setIsHidden(true, animated: true)
            }
        }
    }
    
    private func setIsHidden(_ isHidden: Bool, animated: Bool) {
        view.isHidden = false
        
        guard animated else {
            self.view.alpha = isHidden ? 0 : 1
            self.titleLabel.alpha = isHidden ? 0 : 1
            self.notesTextView.alpha = isHidden ? 0 : 1
            self.imageView.alpha = isHidden ? 0 : 1
            self.playerViewController.view.alpha = isHidden ? 0 : 1
            
            return
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState], animations: {
            self.view.alpha = isHidden ? 0 : 1
            self.titleLabel.alpha = isHidden ? 0 : 1
            self.notesTextView.alpha = isHidden ? 0 : 1
            self.imageView.alpha = isHidden ? 0 : 1
            self.playerViewController.view.alpha = isHidden ? 0 : 1
        }, completion: nil)
    }
    
}


extension UIImage {
    
    fileprivate func alphaImage(_ alpha: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        self.draw(at: CGPoint.zero, blendMode: .normal, alpha: alpha)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
}