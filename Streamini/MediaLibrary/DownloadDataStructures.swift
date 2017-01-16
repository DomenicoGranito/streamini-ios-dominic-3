//
//  DownloadDataStructures.swift
//  Music Player
//
//  Created by Samuel Chu on 3/24/16.
//  Copyright © 2016 Sem. All rights reserved.
//

//import XCDYouTubeKit
import Foundation

public class VideoDownloadInfo {
    let video: Video//XCDYouTubeVideo
    let playlistName: String
    init(video: Video, playlistName: String)  {
        self.video = video
        self.playlistName = playlistName
    }
}

class DownloadCellInfo {
    let image : UIImage
    let duration : String
    let name : String
    var progress : Float
    
    init(image : UIImage, duration : String, name : String) {
        self.image = image
        self.duration = duration
        self.name = name
        self.progress = 0.0
    }
    
    func setProgress(progress : Float) {
        self.progress = progress
    }
    
    func downloadFinished() -> Bool {
        return progress >= 1.0
    }
}
