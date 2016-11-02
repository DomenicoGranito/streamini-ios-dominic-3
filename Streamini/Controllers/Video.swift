//
//  Video.swift
//  BEINIT
//
//  Created by Ankit Garg on 11/2/16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

class Video:NSObject
{
    var id:Int
    var title:String
    var url:String
    var thumbnail:String
    var followersCount:String
    
    init(id:Int, title:String, url:String, thumbnail:String, followersCount:String)
    {
        self.id=id
        self.title=title
        self.url=url
        self.thumbnail=thumbnail
        self.followersCount=followersCount
    }
}
