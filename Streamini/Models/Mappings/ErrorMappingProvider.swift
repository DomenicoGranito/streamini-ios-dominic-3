//
//  ErrorMappingProvider.swift
//  Streamini
//
//  Created by Vasily Evreinov on 08/02/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import Foundation

class ErrorMappingProvider {
    
    class func errorObjectMapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(forClass: Error.self)
        mapping.addAttributeMappingsFromDictionary([
            "status"        : "status",
            "errCode"       : "code",
            "errMessage"    : "message"
        ])

        return mapping
    }
}