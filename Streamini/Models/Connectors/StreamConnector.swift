//
//  StreamConnector.swift
//  Streamini
//
//  Created by Vasily Evreinov on 23/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class StreamConnector: Connector {
    
    func cities(success: (cities: [String]) -> (), failure: (error: NSError) -> ()) {
        let path = "stream/cities"
        
        let mapping = StreamMappingProvider.cityResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(.Successful)
        
        let responseDescriptor = RKResponseDescriptor(mapping: mapping, method:.GET, pathPattern: nil, keyPath: "data.cities", statusCodes: statusCode)
        
        manager.addResponseDescriptor(responseDescriptor)
        
        manager.getObjectsAtPath(path, parameters: self.sessionParams(), success: { (operation, mappingResult) -> Void in
            // success code
            let error:Error = self.findErrorObject(mappingResult: mappingResult)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.cities(success, failure: failure)
                        }, failure: { () -> () in
                            failure(error: error.toNSError())
                    })
                } else {
                    failure(error: error.toNSError())
                }
            } else {
                let cs = mappingResult.dictionary()["data.cities"] as! [NSDictionary]
                var cities: [String] = []
                for c in cs {
                    cities.append(c["name"] as! String)
                }
                success(cities: cities)
            }
        }) { (operation, error) -> Void in
            // failure code
            failure(error: error)
        }

    }
    
    func categories(success: (cats: [Category]) -> (), failure: (error: NSError) -> ()) {
   
    //let path = "stream/categories"
        let path = "category/categories"
        
        let mapping = CategoryMappingProvider.categoryResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(.Successful)
        
        let responseDescriptor = RKResponseDescriptor(mapping: mapping, method:.GET, pathPattern: nil, keyPath: "data.categories", statusCodes: statusCode)
        
        manager.addResponseDescriptor(responseDescriptor)
        
        manager.getObjectsAtPath(path, parameters: self.sessionParams(), success: { (operation, mappingResult) -> Void in
            // success code
            let error:Error = self.findErrorObject(mappingResult: mappingResult)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.categories(success, failure: failure)
                        }, failure: { () -> () in
                            failure(error: error.toNSError())
                    })
                } else {
                    failure(error: error.toNSError())
                }
            } else {
                let cats = mappingResult.dictionary()["data.categories"] as! [Category]
                success(cats: cats)
            }
        }) { (operation, error) -> Void in
            // failure code
            failure(error: error)
        }
    }
    
    
    
    func streams(getGlobal: Bool, success: (live: [Stream], recent: [Stream]) -> (), failure: (error: NSError) -> ()) {
        let path = (getGlobal) ? "stream/global" : "stream/followed"
        
        let streamMapping = StreamMappingProvider.streamResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(.Successful)
        
        let liveStreamResponseDescriptor = RKResponseDescriptor(mapping: streamMapping, method:.GET, pathPattern: nil, keyPath: "data.live", statusCodes: statusCode)
        
        let recentStreamResponseDescriptor = RKResponseDescriptor(mapping: streamMapping, method: RKRequestMethod.GET, pathPattern: nil, keyPath: "data.recent", statusCodes: statusCode)
        
        manager.addResponseDescriptor(liveStreamResponseDescriptor)
        manager.addResponseDescriptor(recentStreamResponseDescriptor)        
        
        manager.getObjectsAtPath(path, parameters: self.sessionParams(), success: { (operation, mappingResult) -> Void in
            // success code
            let error:Error = self.findErrorObject(mappingResult: mappingResult)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.streams(getGlobal, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error: error.toNSError())
                    })
                } else {
                    failure(error: error.toNSError())
                }
            } else {
                var live: [Stream] = []
                if let l: AnyObject = mappingResult.dictionary()["data.live"] {
                    live = l as! [Stream]
                }
                
                var recent: [Stream] = []
                if let r: AnyObject = mappingResult.dictionary()["data.recent"] {
                    recent = r as! [Stream]
                }

                success(live: live, recent: recent)
            }
        }) { (operation, error) -> Void in
            // failure code
            failure(error: error)
        }
    }
    
    /*** WRITTEN BY ANKIT GARG ***/
    
    func homeStreams(success:(data:NSDictionary)->(), failure:(error:NSError)->())
    {
        let path="category/streams"
        
        manager.getObjectsAtPath(path, parameters:self.sessionParams(), success:{ (operation, mappingResult)->Void in
            
            let error=self.findErrorObject(mappingResult:mappingResult)!
            
            if !error.status
            {
                if error.code==Error.kLoginExpiredCode
                {
                    self.relogin({()->() in
                        self.homeStreams(success, failure:failure)
                        },
                                 failure:{()->() in
                                    failure(error:error.toNSError())
                    })
                }
                else
                {
                    failure(error:error.toNSError())
                }
            }
            else
            {
                let json=try! NSJSONSerialization.JSONObjectWithData(operation.HTTPRequestOperation.responseData, options:.MutableLeaves) as! NSDictionary
                
                success(data:json)
            }
            })
        {(operation, error)->Void in
            failure(error:error)
        }
    }
    
    func categoryStreams(categoryID:Int, pageID:Int, success:(data:NSDictionary)->(), failure:(error:NSError)->())
    {
        let path="category/streamscategory?c=\(categoryID)&p=\(pageID)"
        
        manager.getObjectsAtPath(path, parameters:self.sessionParams(), success:{ (operation, mappingResult)->Void in
            
            let error=self.findErrorObject(mappingResult:mappingResult)!
            
            if !error.status
            {
                if error.code==Error.kLoginExpiredCode
                {
                    self.relogin({()->() in
                        self.categoryStreams(categoryID, pageID:pageID, success:success, failure:failure)
                        },
                        failure:{()->() in
                            failure(error:error.toNSError())
                    })
                }
                else
                {
                    failure(error:error.toNSError())
                }
            }
            else
            {
                let json=try! NSJSONSerialization.JSONObjectWithData(operation.HTTPRequestOperation.responseData, options:.MutableLeaves) as! NSDictionary
                
                success(data:json)
            }
            })
        {(operation, error)->Void in
            failure(error:error)
        }
    }

    /*** WRITTEN BY ANKIT GARG ***/
    
    func search(page: UInt, category: UInt, query: String, city: String, success: (streams: [Stream]) -> (), failure: (error: NSError) -> ()) {
        //let path = "stream/search"
       // let path = "stream/search"
        let path="stream/search?q=\(query)"
        let streamMapping = StreamMappingProvider.streamResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(.Successful)
        
        let responseDescriptor = RKResponseDescriptor(mapping: streamMapping, method:.GET, pathPattern: nil, keyPath: "data.streams", statusCodes: statusCode)
        
        manager.addResponseDescriptor(responseDescriptor)
        
        var params = self.sessionParams()
        params!["p"] = page
        params!["c"] = category
        params!["q"] = query
        params!["city"] = city
        
        manager.getObjectsAtPath(path, parameters: self.sessionParams(), success: { (operation, mappingResult) -> Void in
            // success code
            let error:Error = self.findErrorObject(mappingResult: mappingResult)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.search(page, category: category, query: query, city: city, success: success, failure: failure)
                        }, failure: { () -> () in
                            failure(error: error.toNSError())
                    })
                } else {
                    failure(error: error.toNSError())
                }
            } else {
                let streams = mappingResult.dictionary()["data.streams"] as! [Stream]
                success(streams: streams)
            }
        }) { (operation, error) -> Void in
            // failure code
            failure(error: error)
        }
    }
    
    func recent(userId: UInt, success: (streams: [Stream]) -> (), failure: (error: NSError) -> ()) {
        let path = ("stream/recent" as NSString).stringByAppendingPathComponent("\(userId)")
        
        let streamMapping = StreamMappingProvider.streamResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(.Successful)
        
        let responseDescriptor = RKResponseDescriptor(mapping: streamMapping, method:.GET, pathPattern: nil, keyPath: "data.recent", statusCodes: statusCode)
        
        manager.addResponseDescriptor(responseDescriptor)
        
        manager.getObjectsAtPath(path, parameters: self.sessionParams(), success: { (operation, mappingResult) -> Void in
            // success code
            let error:Error = self.findErrorObject(mappingResult: mappingResult)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.recent(userId, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error: error.toNSError())
                    })
                } else {
                    failure(error: error.toNSError())
                }
            } else {
                let streams = mappingResult.dictionary()["data.recent"] as! [Stream]                
                success(streams: streams)
            }
            }) { (operation, error) -> Void in
                // failure code
                failure(error: error)
        }
    }
    
    func my(success: (streams: [Stream]) -> (), failure: (error: NSError) -> ()) {
        let path = "stream/my"
        
        let streamMapping = StreamMappingProvider.streamResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(.Successful)
        
        let responseDescriptor = RKResponseDescriptor(mapping: streamMapping, method:.GET, pathPattern: nil, keyPath: "data.streams", statusCodes: statusCode)
        
        manager.addResponseDescriptor(responseDescriptor)
        
        manager.getObjectsAtPath(path, parameters: self.sessionParams(), success: { (operation, mappingResult) -> Void in
            // success code
            let error:Error = self.findErrorObject(mappingResult: mappingResult)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.my(success, failure: failure)
                    }, failure: { () -> () in
                        failure(error: error.toNSError())
                    })
                } else {
                    failure(error: error.toNSError())
                }
            } else {
                let streams = mappingResult.dictionary()["data.streams"] as! [Stream]
                success(streams: streams)
            }
            }) { (operation, error) -> Void in
                // failure code
                failure(error: error)
        }
    }
    
    func create(data: NSDictionary, success: (stream: Stream) -> (), failure: (error: NSError) -> ()) {
        let path = "stream/create"
        
        let requestMapping  = StreamMappingProvider.createStreamRequestMapping()
        let streamMapping   = StreamMappingProvider.streamResponseMapping()
        
        let requestDescriptor = RKRequestDescriptor(mapping: requestMapping, objectClass: NSDictionary.self, rootKeyPath: nil, method:.POST)
        manager.addRequestDescriptor(requestDescriptor)

        let statusCode = RKStatusCodeIndexSetForClass(.Successful)
        let streamResponseDescriptor = RKResponseDescriptor(mapping: streamMapping, method:.POST, pathPattern: nil, keyPath: "data", statusCodes: statusCode)
        
        manager.addResponseDescriptor(streamResponseDescriptor)
        
        manager.postObject(data, path: path, parameters: self.sessionParams(), success: { (operation, mappingResult) -> Void in
            // success code
            let error:Error = self.findErrorObject(mappingResult: mappingResult)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.create(data, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error: error.toNSError())
                    })
                } else {
                    failure(error: error.toNSError())
                }
            } else {
                let stream = mappingResult.dictionary()["data"] as! Stream
                success(stream: stream)
            }
            }) { (operation, error) -> Void in
                // failure code
                failure(error: error)
        }
    }
    
    func createWithFile(filename: String, fileData: NSData, data: NSDictionary, success: (stream: Stream) -> (), failure: (error: NSError) -> ()) {
        let path = "stream/create"
        
        let requestMapping  = StreamMappingProvider.createStreamRequestMapping()
        let streamMapping   = StreamMappingProvider.streamResponseMapping()
        
        let requestDescriptor = RKRequestDescriptor(mapping: requestMapping, objectClass: NSDictionary.self, rootKeyPath: nil, method:.POST)
        manager.addRequestDescriptor(requestDescriptor)
        
        let statusCode = RKStatusCodeIndexSetForClass(.Successful)
        let streamResponseDescriptor = RKResponseDescriptor(mapping: streamMapping, method:.POST, pathPattern: nil, keyPath: "data", statusCodes: statusCode)
        
        manager.addResponseDescriptor(streamResponseDescriptor)
        
        let request =
        manager.multipartFormRequestWithObject(data, method:.POST, path: path, parameters: self.sessionParams()) { (formData) -> Void in
            formData.appendPartWithFileData(fileData, name: "image", fileName: filename, mimeType: "image/jpeg")
        }
        
        let operation = manager.objectRequestOperationWithRequest(request, success: { (operation, mappingResult) -> Void in
            let error:Error = self.findErrorObject(mappingResult: mappingResult)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.createWithFile(filename, fileData: fileData, data: data, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error: error.toNSError())
                    })
                } else {
                    failure(error: error.toNSError())
                }
            } else {
                let stream = mappingResult.dictionary()["data"] as! Stream
                success(stream: stream)
            }
            }) { (operation, error) -> Void in
                failure(error: error)
        }
        
        manager.enqueueObjectRequestOperation(operation)
    }
    
    func del(streamId: UInt, success: () -> (), failure: (error: NSError) -> ()) {
        let path = "stream/delete"
        
        var params = self.sessionParams()
        params!["id"] = streamId
        
        manager.postObject(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            // success code
            let error:Error = self.findErrorObject(mappingResult: mappingResult)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.del(streamId, success: success, failure: failure)
                        }, failure: { () -> () in
                            failure(error: error.toNSError())
                    })
                } else {
                    failure(error: error.toNSError())
                }            } else {
                success()
            }
        }) { (operation, error) -> Void in
            // failure code
            failure(error: error)
        }
    }

    
    func close(streamId: UInt, success: () -> (), failure: (error: NSError) -> ()) {
        let path = "stream/close"
        
        var params = self.sessionParams()
        params!["id"] = streamId
        
        manager.postObject(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            // success code
            let error:Error = self.findErrorObject(mappingResult: mappingResult)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.close(streamId, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error: error.toNSError())
                    })
                } else {
                    failure(error: error.toNSError())
                }            } else {
                success()
            }
            }) { (operation, error) -> Void in
                // failure code
                failure(error: error)
        }
    }
    
    func join(streamId: UInt, success: () -> (), failure: (error: NSError) -> ()) {
        let path = "stream/join"
        
        var params = self.sessionParams()
        params!["id"] = streamId
        
        manager.postObject(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            let error:Error = self.findErrorObject(mappingResult: mappingResult)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.join(streamId, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error: error.toNSError())
                    })
                } else {
                    failure(error: error.toNSError())
                }            } else {
                success()
            }
        }) { (operation, error) -> Void in
            failure(error: error)
        }
    }
    
    func leave(streamId: UInt, likes: UInt, success: () -> (), failure: (error: NSError) -> ()) {
        let path = "stream/leave"
        
        var params = self.sessionParams()
        params!["id"] = streamId
        params!["likes"] = likes
        
        manager.postObject(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            let error:Error = self.findErrorObject(mappingResult: mappingResult)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.leave(streamId, likes: likes, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error: error.toNSError())
                    })
                } else {
                    failure(error: error.toNSError())
                }            } else {
                success()
            }
            }) { (operation, error) -> Void in
                failure(error: error)
        }
    }
    
    func viewers(data: NSDictionary, success: (likes: UInt, viewers: UInt, users: [User]) -> (), failure: (error: NSError) -> ()) {
        let streamId = data["streamId"] as! UInt
        let path = ("stream/viewers" as NSString).stringByAppendingPathComponent("\(streamId)")
        
        let streamMapping = StreamMappingProvider.viewersResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(.Successful)
        
        let streamResponseDescriptor = RKResponseDescriptor(mapping: streamMapping, method:.GET, pathPattern: nil, keyPath: "data", statusCodes: statusCode)
        
        manager.addResponseDescriptor(streamResponseDescriptor)
        
        var params = self.sessionParams()
        if let page: UInt = (data["p"] as? UInt) {
            params!["p"] = page
        }
        
        manager.getObjectsAtPath(path, parameters: params, success: { (operation, mappingResult) -> Void in
            let error:Error = self.findErrorObject(mappingResult: mappingResult)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.viewers(data, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error: error.toNSError())
                    })
                } else {
                    failure(error: error.toNSError())
                }            } else {
                let data = mappingResult.dictionary()["data"] as! NSDictionary
                let likes: UInt     = data["likes"] as! UInt
                let viewers: UInt   = data["viewers"] as! UInt
                let users:[User]    = data["users"] as! [User]
                success(likes: likes, viewers: viewers, users: users)
            }
        }) { (operation, error) -> Void in
            failure(error: error)
        }
    }
    
    func replayViewers(data: NSDictionary, success: (likes: UInt, viewers: UInt, users: [User]) -> (), failure: (error: NSError) -> ()) {
        let streamId = data["streamId"] as! UInt
        let path = ("stream/rviewers" as NSString).stringByAppendingPathComponent("\(streamId)")
        
        let streamMapping = StreamMappingProvider.viewersResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(.Successful)
        
        let streamResponseDescriptor = RKResponseDescriptor(mapping: streamMapping, method:.GET, pathPattern: nil, keyPath: "data", statusCodes: statusCode)
        
        manager.addResponseDescriptor(streamResponseDescriptor)
        
        var params = self.sessionParams()
        if let page: UInt = (data["p"] as? UInt) {
            params!["p"] = page
        }
        
        manager.getObjectsAtPath(path, parameters: params, success: { (operation, mappingResult) -> Void in
            let error:Error = self.findErrorObject(mappingResult: mappingResult)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.replayViewers(data, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error: error.toNSError())
                    })
                } else {
                    failure(error: error.toNSError())
                }            } else {
                let data = mappingResult.dictionary()["data"] as! NSDictionary
                let likes: UInt     = data["likes"] as! UInt
                let viewers: UInt   = data["viewers"] as! UInt
                let users:[User]    = data["users"] as! [User]
                success(likes: likes, viewers: viewers, users: users)
            }
            }) { (operation, error) -> Void in
                failure(error: error)
        }
    }
    
    func get(streamId: UInt, success: (stream: Stream) -> (), failure: (error: NSError) -> ()) {
        let path = ("stream" as NSString).stringByAppendingPathComponent("\(streamId)")
        
        let streamMapping = StreamMappingProvider.streamResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(.Successful)
        
        let streamResponseDescriptor = RKResponseDescriptor(mapping: streamMapping, method:.GET, pathPattern: nil, keyPath: "data", statusCodes: statusCode)
        
        manager.addResponseDescriptor(streamResponseDescriptor)
        
        manager.getObjectsAtPath(path, parameters: self.sessionParams(), success: { (operation, mappingResult) -> Void in
            let error:Error = self.findErrorObject(mappingResult: mappingResult)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.get(streamId, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error: error.toNSError())
                    })
                } else {
                    failure(error: error.toNSError())
                }            } else {
                let stream = mappingResult.dictionary()["data"] as! Stream
                success(stream: stream)
            }
            }) { (operation, error) -> Void in
                failure(error: error)
        }
    }    
    
    func report(streamId: UInt, success: () -> (), failure: (error: NSError) -> ()) {
        let path = "stream/report"
        
        var params = self.sessionParams()
        params!["id"] = streamId
        
        manager.postObject(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            let error:Error = self.findErrorObject(mappingResult: mappingResult)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.report(streamId, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error: error.toNSError())
                    })
                } else {
                    failure(error: error.toNSError())
                }            } else {
                success()
            }
            }) { (operation, error) -> Void in
                failure(error: error)
        }
    }
    
    func share(streamId: UInt, usersId: [UInt]?, success: () -> (), failure: (error: NSError) -> ()) {
        let path = "stream/share"
        
        var params = self.sessionParams()
        params!["id"] = streamId
        
        if let users = usersId {
            params!["users"] = users
        }
        
        manager.postObject(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            let error:Error = self.findErrorObject(mappingResult: mappingResult)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.share(streamId, usersId: usersId, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error: error.toNSError())
                    })
                } else {
                    failure(error: error.toNSError())
                }
            } else {
                success()
            }
            }) { (operation, error) -> Void in
                failure(error: error)
        }
    }
    
    func ping(streamId: UInt, success: () -> (), failure: (error: NSError) -> ()) {
        let path = "stream/ping"
        
        var params = self.sessionParams()
        params!["id"] = streamId
        
        manager.postObject(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            let error:Error = self.findErrorObject(mappingResult: mappingResult)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.ping(streamId, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error: error.toNSError())
                    })
                } else {
                    failure(error: error.toNSError())
                }
            } else {
                success()
            }
            }) { (operation, error) -> Void in
                failure(error: error)
        }
    }
}
