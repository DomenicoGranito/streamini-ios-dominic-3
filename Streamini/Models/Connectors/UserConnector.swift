//
//  UserConnector.swift
//  Streamini
//
//  Created by Vasily Evreinov on 23/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class UserConnector: Connector {
    
    func logout(success: () -> (), failure: (error: NSError) -> ()) {
        let path = "user/logout"
        
        manager.postObject(nil, path: path, parameters: nil, success: { (operation, mappingResult) -> Void in
            // success code
            let error:Error = self.findErrorObject(mappingResult: mappingResult)!
            if !error.status {
                failure(error: error.toNSError())
            } else {
                success()
            }
            }) { (operation, error) -> Void in
                // failure code
                failure(error: error)
        }
    }
    
    func get(id: UInt?, success: (user: User) -> (), failure: (error: NSError) -> ()) {
        let path = "user"
        
        let responseMapping = UserMappingProvider.userResponseMapping()
        
        let statusCode = RKStatusCodeIndexSetForClass(.Successful)
        
        let userResponseDescriptor = RKResponseDescriptor(mapping: responseMapping, method:.GET, pathPattern: nil, keyPath: "data", statusCodes: statusCode)
        manager.addResponseDescriptor(userResponseDescriptor)
        
        var params=self.sessionParams()
        
        if let uid=id
        {
            params!["id"] = uid
        }
        
        manager.getObjectsAtPath(path, parameters: params, success: { (operation, mappingResult) -> Void in
            // success code
            let error:Error = self.findErrorObject(mappingResult: mappingResult)!

            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.get(id, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error: error.toNSError())
                    })
                } else {
                    failure(error: error.toNSError())
                }
            } else {
                let user = mappingResult.dictionary()["data"] as! User
                success(user: user)
            }
            }) { (operation, error) -> Void in
                // failure code
                failure(error: error)
        }
    }
    
    func followers(data: NSDictionary, success: (users: [User]) -> (), failure: (error: NSError) -> ()) {
        usersList("user/followers", data: data, success: success, failure: failure)
    }
    
    func following(data: NSDictionary, success: (users: [User]) -> (), failure: (error: NSError) -> ()) {
        usersList("user/following", data: data, success: success, failure: failure)
    }
    
    func blocked(data: NSDictionary, success: (users: [User]) -> (), failure: (error: NSError) -> ()) {
        usersList("user/blocked", data: data, success: success, failure: failure)
    }
    
    func avatar(success: () -> (), failure: (error: NSError) -> ()) {
        let path = "user/avatar"
        
        manager.postObject(nil, path: path, parameters: self.sessionParams(), success: { (operation, mappingResult) -> Void in
            let error:Error = self.findErrorObject(mappingResult: mappingResult)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.avatar(success, failure: failure)
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
    
    func uploadAvatar(filename: String, data: NSData, success: () -> (), failure: (error: NSError) -> (), progress: ((UInt, Int64, Int64) -> Void)) {
        let path = "user/avatar"
        
        let request =
        manager.multipartFormRequestWithObject(nil, method:.POST, path: path, parameters: self.sessionParams()) { (formData) -> Void in
            formData.appendPartWithFileData(data, name: "image", fileName: filename, mimeType: "image/jpeg")
        }
        
        let operation = manager.objectRequestOperationWithRequest(request, success: { (operation, mappingResult) -> Void in
            let error:Error = self.findErrorObject(mappingResult: mappingResult)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.uploadAvatar(filename, data: data, success: success, failure: failure, progress: progress)
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
        
        operation.HTTPRequestOperation.setUploadProgressBlock(progress)
        manager.enqueueObjectRequestOperation(operation)
    }
    
    func userDescription(text: String, success:() -> (), failure: (error: NSError) -> ()) {
        let path = "user/description"
        
        var params = self.sessionParams()
        params!["text"] = text
        
        manager.postObject(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            let error:Error = self.findErrorObject(mappingResult: mappingResult)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.userDescription(text, success: success, failure: failure)
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
    
    func forgot(text: String, success:() -> (), failure: (error: NSError) -> ()) {
        let path = "user/forgot"
        
        let params: [NSObject: AnyObject] = [ "id" : text ]
        
        manager.postObject(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            let error:Error = self.findErrorObject(mappingResult: mappingResult)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.forgot(text, success: success, failure: failure)
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
    
    func password(text: String, success:() -> (), failure: (error: NSError) -> ()) {
        let path = "user/password"
        
        var params = self.sessionParams()
        params!["password"] = text
        
        manager.postObject(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            let error:Error = self.findErrorObject(mappingResult: mappingResult)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.password(text, success: success, failure: failure)
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
    
    private func usersList(path: String, data: NSDictionary, success: (users: [User]) -> (), failure: (error: NSError) -> ()) {
        let responseMapping = UserMappingProvider.userResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(.Successful)
        
        let userResponseDescriptor = RKResponseDescriptor(mapping: responseMapping, method:.GET, pathPattern: nil, keyPath: "data.users", statusCodes: statusCode)
        manager.addResponseDescriptor(userResponseDescriptor)
        
        var params = self.sessionParams()
        if let id: AnyObject = data["id"] {
            params!["id"] = id
        }
        if let page: AnyObject = data["p"] {
            params!["p"] = page
        }
        if let query: AnyObject = data["q"] {
            params!["q"] = query
        }
        
        manager.getObjectsAtPath(path, parameters: params, success: { (operation, mappingResult) -> Void in
            // success code
            let error:Error = self.findErrorObject(mappingResult: mappingResult)!
            if !error.status {
                if error.code == Error.kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.usersList(path, data: data, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error: error.toNSError())
                    })
                } else {
                    failure(error: error.toNSError())
                }
            } else {
                let users = mappingResult.dictionary()["data.users"] as! [User]
                success(users: users)
            }
            }) { (operation, error) -> Void in
                // failure code
                failure(error: error)
        }
    }
}
