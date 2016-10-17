//
//  Camera.swift
//  Streamini
//
//  Created by Vasily Evreinov on 29/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit
import AVFoundation

class Camera {
    var liveStreamId: UInt?
    var session: VCSimpleSession?
    var image: UIImage?
    var previewView: UIView?

    func setup(view: UIView) {
        self.previewView = view
        
        var h = view.bounds.size.height
        var w = view.bounds.size.width
        
        while(h%16>0)
        {
            h = h + 1.0
        }
        
        while(w%16>0)
        {
            w = w + 1.0
        }
        
        let vSize = CGSize(width: w, height: h)
        
        self.session = VCSimpleSession(videoSize: vSize, frameRate: 30, bitrate: 1000000, useInterfaceOrientation: false)
        session!.orientationLocked = true
        addPreviewView(view)
        session!.previewView.frame = view.bounds
    }
    
    func start(hash: String, streamId: UInt) {
        self.liveStreamId = streamId
        let (url, streamName) = self.getConnectionData(hash, streamId: streamId)
        session!.startRtmpSessionWithURL(url, andStreamKey: streamName)
    }
    
    func stop() {
        if let ses = session {
            ses.endRtmpSession()
            ses.previewView.removeFromSuperview()
        }
        
        self.liveStreamId = nil
        
        session     = nil
        previewView = nil
    }
    
    func captureStillImage() -> UIImage? {
        if let view = previewView {
            UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0)
            view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: false)
            self.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return self.image
        }
        return nil
    }
    
    func addPreviewView(view: UIView) {
        view.addSubview(session!.previewView)
    }
    
    func switchCameraDirection() {
        session!.cameraState = (session!.cameraState == VCCameraState.Back) ? VCCameraState.Front : VCCameraState.Back
    }
    
    // MAKR: - Private methods
    
    private func getConnectionData(hash: String, streamId: UInt) -> (String, String) {
        let (host, port, application, username, password) = Config.shared.wowza()
        let url = "rtmp://\(username):\(password)@\(host):\(port)/\(application)"
        let streamName = "\(hash)-\(streamId)"
        return (url, streamName)
    }
    
}
