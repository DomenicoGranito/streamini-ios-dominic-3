//
//  User.swift
//  Streamini
//
//  Created by Vasily Evreinov on 23/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class User: NSObject {
    var id: UInt = 0
    var name = ""
    var sname = ""
    var avatar: String? = ""
    var likes: UInt = 0
    var recent: UInt = 0
    var followers: UInt = 0
    var following: UInt = 0
    var streams: UInt = 0
    var blocked: UInt = 0
    var desc: String? = ""
    var isLive = false
    var isFollowed = false
    var isBlocked = false
}
