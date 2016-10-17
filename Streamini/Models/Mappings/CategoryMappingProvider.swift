//
//  CategoryMappingProvider.swift
//  Streamini
//
//  Created by Vasiliy Evreinov on 14.06.16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

import UIKit

class CategoryMappingProvider: NSObject {
    
    class func categoryResponseMapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(forClass: Category.self)
        mapping.addAttributeMappingsFromDictionary([
            "id"        : "id",
            "name"      : "name"
            ])
        
        return mapping
    }
}