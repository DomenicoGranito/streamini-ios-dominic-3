//
//  YouTubeSearchWebView.swift
//  Music Player
//
//  Created by Takuya Okamoto on 2015/12/30.
//  Copyright © 2015年 Sem. All rights reserved.
//

import UIKit
import WebKit
//import SnapKit


protocol YouTubeSearchWebViewDelegate {
    func didTapDownloadButton(url: NSURL)
}


enum YoutubeUrlType {
    case Playlist(id: String)
    case Video(id: String)
    case Other
}


class YouTubeSearchWebView: WKWebView {

    private let downloadButton = UIButton()
    
    var delegate: YouTubeSearchWebViewDelegate?
    
    init() {
        let conf = WKWebViewConfiguration()
        //doesn't work
        /*if #available(iOS 9.0, *) {
            conf.requiresUserActionForMediaPlayback = true
        } else {
            conf.mediaPlaybackRequiresUserAction = true
        }
        conf.allowsInlineMediaPlayback = true*/
        super.init(frame: CGRectZero, configuration: conf)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        allowsBackForwardNavigationGestures = true
        addDownloadButton()
        addObserver(self, forKeyPath:"URL", options:.New, context:nil)
    }
    
    deinit {
        removeObserver(self, forKeyPath: "URL")
    }
    
    func didTapDownloadButton() {
        if let url = self.URL {
            delegate?.didTapDownloadButton(url)
        }
    }
    
    
    // MARK: Check URL
    
    private func didChangeURL(url: NSURL) {
        switch detectURLType(url) {
        case .Playlist, .Video: enableButton()
        case .Other: disableButton()
        }
    }
    
    
    // MARK: Download Button
    
    private func addDownloadButton() {
        downloadButton.setTitle("↓", forState: .Normal)
        downloadButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        downloadButton.titleLabel?.font = UIFont(name: "HiraKakuProN-W6", size: 20)
        disableButton()
        
        // add
        let btnSize: CGFloat = 44
        let margin: CGFloat = 12
        downloadButton.layer.cornerRadius = btnSize / 2
        addSubview(downloadButton)
     //   downloadButton.snp_makeConstraints { make in
           // make.size.equalTo(btnSize)
           // make.right.equalTo(self).offset(-margin)
         //   make.bottom.equalTo(self).offset(-margin)
       // }

        downloadButton.addTarget(self, action: #selector(YouTubeSearchWebView.didTapDownloadButton), forControlEvents: .TouchUpInside)
    }
    
    private func disableButton() {
        downloadButton.enabled = false
        downloadButton.backgroundColor = UIColor.grayColor()
        downloadButton.alpha = 0.1
    }

    private func enableButton() {
        downloadButton.enabled = true
        downloadButton.backgroundColor = UIColor.redColor()
        UIView.animateWithDuration(0.2) { self.downloadButton.alpha = 1 }
    }
    
}



// util
extension YouTubeSearchWebView {
    
    private func detectURLType(url: NSURL) -> YoutubeUrlType {
        let (videoId, playlistId) = MiscFuncs.parseIDs(url: url.absoluteString!)
        if let videoId = videoId {
            return YoutubeUrlType.Video(id: videoId)
        }
        else if let playlistId = playlistId {
            return YoutubeUrlType.Playlist(id: playlistId)
        }
        else {
            return YoutubeUrlType.Other
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let keyPath = keyPath {
            switch keyPath {
            case "URL":
                if let url = change![NSKeyValueChangeNewKey] as? NSURL {
                    didChangeURL(url)
                }
            default: return
            }
        }
    }
}
