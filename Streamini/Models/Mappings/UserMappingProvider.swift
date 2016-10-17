//
//  UserMappingProvider.swift
//  Streamini
//
//  Created by Vasily Evreinov on 23/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class UserMappingProvider: NSObject {
    
    class func loginRequestMapping() -> RKObjectMapping {
        let mapping = RKObjectMapping.requestMapping()
        mapping.addAttributeMappingsFromArray(["id", "token", "secret", "type", "apn", "password", "username"])
        
        return mapping
    }
    
    class func loginResponseMapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(forClass: NSMutableDictionary.self)
        mapping.addAttributeMappingsFromArray(["session"])
        
        return mapping
    }
    
    class func userRequestMapping() -> RKObjectMapping {
        let mapping = RKObjectMapping.requestMapping()
        
        mapping.addAttributeMappingsFromDictionary([
            "id"        : "id",
            "name"      : "name",
            "sname"     : "sname",
            "avatar"    : "avatar",
            "likes"     : "likes",
            "recent"    : "recent",
            "followers" : "followers",
            "following" : "following",
            "streams"   : "streams",
            "blocked"   : "blocked",
            "desc"      : "description",
            "isLive"    : "islive",
            "isFollowed": "isfollowed",
            "isBlocked" : "isblocked"
        ])
        
        return mapping
    }
    
    class func userResponseMapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(forClass: User.self)
        mapping.addAttributeMappingsFromDictionary([
            "id"        : "id",
            "name"      : "name",
            "sname"     : "sname",
            "avatar"    : "avatar",
            "likes"     : "likes",
            "recent"    : "recent",
            "streams"   : "streams",
            "followers" : "followers",
            "following" : "following",
            "blocked"   : "blocked",
            "description" : "desc",
            "islive"    : "isLive",
            "isfollowed": "isFollowed",
            "isblocked" : "isBlocked"
            ])
                
        return mapping
    }
}
