//
//  CallApi.swift
//  Nariko
//
//  Created by Zsolt Papp on 14/06/16.
//  Copyright © 2016 Nariko. All rights reserved.
//

import UIKit
import SwiftHTTP

class CallApi {
    
    func authRequest(paremeters: [String: AnyObject], callCompletion: ((success: Bool, errorCode: Int, msg: String) -> Void)!) {
        
        do {
            let opt = try HTTP.POST("http://nariko.io/api/application/login", parameters: paremeters, headers: nil, requestSerializer: JSONParameterSerializer())
            
            opt.start { response in
                if let jsonObject: AnyObject = response.text?.parseJSONString {
                    
                    if jsonObject["Status"]! as! Int == 200{
                        dispatch_async(dispatch_get_main_queue()){
                          
                            callCompletion(success: true, errorCode: -1, msg: jsonObject["ApiKey"]! as? String ?? "")
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue()){
                            callCompletion(success: false, errorCode: jsonObject["Status"]! as? Int ?? 900, msg: "")
                        }
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()){
                        callCompletion(success: false, errorCode: 900, msg: "")
                    }
                }
            }
        } catch let error {
            print("got an error creating the request: \(error)")
        }
    }
    
    func sendData(image: UIImage, comment: String, callCompletion: ((success: Bool, errorCode: Int, msg: String) -> Void)!) {
        
        do {
            let base64Str = UIImageJPEGRepresentation(image, 1.0)!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
            
            let opt = try HTTP.POST("http://nariko.io/api/application/task", parameters: ["ApiKey": NarikoTool.sharedInstance.apiKey!, "modelName": UIDevice().modelName, "systemVersion":UIDevice.currentDevice().systemVersion, "orientation": UIDevice.currentDevice().orientation.rawValue.description, "name": UIDevice.currentDevice().name, "systemName": UIDevice.currentDevice().systemName, "image": base64Str, "comment": comment], headers: nil, requestSerializer: JSONParameterSerializer())
            
         //   let opt = try HTTP.POST("http://nariko.io/api/task", parameters: ["ApiKey": "", "modelName": UIDevice().modelName, "systemVersion":UIDevice.currentDevice().systemVersion, "orientation": UIDevice.currentDevice().orientation.rawValue, "name":UIDevice.currentDevice().name, "systemName": UIDevice.currentDevice().systemName, "file": Upload(data: UIImageJPEGRepresentation(image, 1.0)!, fileName: "teszt", mimeType: "image/jpeg")], headers: nil, requestSerializer: JSONParameterSerializer())
            
            opt.start { response in
                
                print(response.text)
                dispatch_async(dispatch_get_main_queue()){
                    callCompletion(success: true, errorCode: -1, msg: "")
                }
            }
        } catch let error {
            print("got an error creating the request: \(error)")
        }
    }
    
    
    
}