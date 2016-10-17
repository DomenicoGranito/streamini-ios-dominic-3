//
//  AmazonTool.swift
//  Streamini
//
//  Created by Vasily Evreinov on 01/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

protocol AmazonToolDelegate: class {
    func imageDidUpload()
    func imageUploadFailed(error: NSError)
}

let AWSRegionNameUSEast1 = "us-east-1";
let AWSRegionNameUSWest2 = "us-west-2";
let AWSRegionNameUSWest1 = "us-west-1";
let AWSRegionNameEUWest1 = "eu-west-1";
let AWSRegionNameEUCentral1 = "eu-central-1";
let AWSRegionNameAPSoutheast1 = "ap-southeast-1";
let AWSRegionNameAPNortheast1 = "ap-northeast-1";
let AWSRegionNameAPSoutheast2 = "ap-southeast-2";
let AWSRegionNameSAEast1 = "sa-east-1";
let AWSRegionNameCNNorth1 = "cn-north-1";
let AWSRegionNameUSGovWest1 = "us-gov-west-1";

class AmazonTool: NSObject {
    weak var delegate: AmazonToolDelegate?
    
    class var shared : AmazonTool {
        struct Static {
            static let instance : AmazonTool = AmazonTool()
        }
        return Static.instance
    }
    
    class func isAmazonSupported() -> Bool {
        let (accessKeyId, _, _, _, _) = Config.shared.amazon()
        return !accessKeyId.isEmpty
    }
    
    override init () {
        super.init()
        
        // Setup Amazon S3
        AWSLogger.defaultLogger().logLevel = .Error
        
        let (accessKeyId, secretAccessKey, region, _, _) = Config.shared.amazon()
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKeyId, secretKey: secretAccessKey)
        let configuration = AWSServiceConfiguration(region: AmazonTool.regionTypeFromName(region), credentialsProvider: credentialsProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
    }
    
    func uploadImage(image: UIImage, name: String) {
        uploadImage(image, name: name, uploadProgress: nil)
    }
    
    func uploadImage(image: UIImage, name: String, uploadProgress: AWSNetworkingUploadProgressBlock?) {
        let (_, _, _, _, imagesBucket) = Config.shared.amazon()
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest.key = name
        uploadRequest.bucket = imagesBucket
        
        if let progress = uploadProgress {
            uploadRequest.uploadProgress = progress
        }
        
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let basePath = paths[0] 
        let filePath = (basePath as NSString).stringByAppendingPathComponent(name)
        let binaryImageData = UIImageJPEGRepresentation(image, 1.0)
        binaryImageData!.writeToFile(filePath, atomically: true)
        
        let fileURL = NSURL(fileURLWithPath: filePath)
        
        uploadRequest.body = fileURL
        
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        transferManager.upload(uploadRequest).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in
            do {
                try NSFileManager.defaultManager().removeItemAtURL(fileURL)
            } catch _ {
            }
            if let del = self.delegate {
                if let error = task.error {
                    del.imageUploadFailed(error)
                } else {
                    del.imageDidUpload()
                }
            }
            
            return nil
        })
    }
    
    class func regionTypeFromName(regionName: String) -> (AWSRegionType) {
        
        switch (regionName) {
            case AWSRegionNameUSEast1:
                return AWSRegionType.USEast1;
            case AWSRegionNameUSWest2:
                return AWSRegionType.USWest2;
            case AWSRegionNameUSWest1:
                return AWSRegionType.USWest1;
            case AWSRegionNameEUWest1:
                return AWSRegionType.EUWest1;
            case AWSRegionNameEUCentral1:
                return AWSRegionType.EUCentral1;
            case AWSRegionNameAPSoutheast1:
                return AWSRegionType.APSoutheast1;
            case AWSRegionNameAPSoutheast2:
                return AWSRegionType.APSoutheast2;
            case AWSRegionNameAPNortheast1:
                return AWSRegionType.APNortheast1;
            case AWSRegionNameSAEast1:
                return AWSRegionType.SAEast1;
            case AWSRegionNameCNNorth1:
                return AWSRegionType.CNNorth1;
            case AWSRegionNameUSGovWest1:
                return AWSRegionType.USGovWest1;
            default:
                return AWSRegionType.Unknown;
        }
    }
}
