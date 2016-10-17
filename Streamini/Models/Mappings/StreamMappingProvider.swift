//
//  StreamMappingProvider.swift
//  Streamini
//
//  Created by Vasily Evreinov on 23/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class StreamMappingProvider: NSObject {
    
    class func cityResponseMapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(forClass: NSMutableDictionary.self)
        mapping.addAttributeMappingsFromArray(["name"])
        
        return mapping
    }
    
    class func streamRequestMapping() -> RKObjectMapping {
        let mapping = RKObjectMapping.requestMapping()
        
        mapping.addAttributeMappingsFromDictionary([
            "id"            : "id",
            "title"         : "title",
            "streamHash"    : "hash",
            "ended"         : "ended",
            "viewers"       : "viewers",
            "tviewers"      : "tviewers",
            "rviewers"      : "rviewers",
            "city"          : "city",
            "lon"           : "lon",
            "lat"           : "lat",
            "likes"         : "likes",
            "rlikes"        : "rlikes"
        ])
        
        let userMapping = UserMappingProvider.userRequestMapping()
        let userRelationshipMapping = RKRelationshipMapping(fromKeyPath: "user", toKeyPath: "user", withMapping: userMapping)
        mapping.addPropertyMapping(userRelationshipMapping)
        
        return mapping
    }
        
    class func streamResponseMapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(forClass: Stream.self)
        
        mapping.addAttributeMappingsFromDictionary([
            "id"            : "id",
            "title"         : "title",
            "hash"          : "streamHash",
            "ended"         : "ended",
            "viewers"       : "viewers",
            "tviewers"      : "tviewers",
            "rviewers"      : "rviewers",
            "city"          : "city",
            "lon"           : "lon",
            "lat"           : "lat",
            "likes"         : "likes",
            "rlikes"        : "rlikes"
        ])
        
        let userMapping = UserMappingProvider.userResponseMapping()
        let userRelationshipMapping = RKRelationshipMapping(fromKeyPath: "user", toKeyPath: "user", withMapping: userMapping)
        mapping.addPropertyMapping(userRelationshipMapping)
        
        return mapping
    }
    
    class func viewersResponseMapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(forClass: NSMutableDictionary.self)
        mapping.addAttributeMappingsFromArray(["viewers", "likes"])
        
        let userMapping = UserMappingProvider.userResponseMapping()
        let userRelationshipMapping = RKRelationshipMapping(fromKeyPath: "users", toKeyPath: "users", withMapping: userMapping)
        mapping.addPropertyMapping(userRelationshipMapping)
        
        return mapping
    }
        
    class func createStreamRequestMapping() -> RKObjectMapping {
        let mapping = RKObjectMapping.requestMapping()
        mapping.addAttributeMappingsFromArray(["title", "lon", "lat", "city", "category", "keep"])
        return mapping
    }    
}
