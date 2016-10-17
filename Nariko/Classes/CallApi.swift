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
    
    func authRequest(_ paremeters: [String: AnyObject], callCompletion: ((_ success: Bool, _ errorCode: Int, _ msg: String) -> Void)!) {
        
        do {
            let opt = try HTTP.POST("http://nariko.io/api/application/login", parameters: paremeters, headers: nil, requestSerializer: JSONParameterSerializer())
            
            opt.start { response in
                print(response.text)
                if let jsonObject: AnyObject = response.text?.parseJSONString {
                    
                    if jsonObject["Status"]! as! Int == 200{
                        DispatchQueue.main.async{
                            
                            callCompletion(true, -1, jsonObject["ApiKey"]! as? String ?? "")
                        }
                    } else {
                        DispatchQueue.main.async{
                            callCompletion(false, jsonObject["Status"]! as? Int ?? 900, "")
                        }
                    }
                } else {
                    DispatchQueue.main.async{
                        callCompletion(false, 900, "")
                    }
                }
            }
        } catch let error {
            print("got an error creating the request: \(error)")
        }
    }
    
    func sendData(_ image: UIImage, comment: String, callCompletion: ((_ success: Bool, _ errorCode: Int, _ msg: String) -> Void)!) {
        
        do {
            let base64Str = UIImageJPEGRepresentation(image, 1.0)!.base64EncodedString(options: .lineLength64Characters)
            
            let opt = try HTTP.POST("http://nariko.io/api/application/task", parameters: ["ApiKey": NarikoTool.sharedInstance.apiKey!, "modelName": UIDevice().modelName, "systemVersion":UIDevice.current.systemVersion, "deviceOrientation": UIDevice.current.orientation.rawValue.description, "screenOrientation": UIApplication.shared.statusBarOrientation.rawValue.description, "name": UIDevice.current.name, "systemName": UIDevice.current.systemName, "image": base64Str, "comment": comment], headers: nil, requestSerializer: JSONParameterSerializer())
            
            //   let opt = try HTTP.POST("http://nariko.io/api/task", parameters: ["ApiKey": "", "modelName": UIDevice().modelName, "systemVersion":UIDevice.currentDevice().systemVersion, "orientation": UIDevice.currentDevice().orientation.rawValue, "name":UIDevice.currentDevice().name, "systemName": UIDevice.currentDevice().systemName, "file": Upload(data: UIImageJPEGRepresentation(image, 1.0)!, fileName: "teszt", mimeType: "image/jpeg")], headers: nil, requestSerializer: JSONParameterSerializer())
            
            opt.start { response in
                
                print(response.text)
                DispatchQueue.main.async{
                    callCompletion( true,  -1, "")
                }
            }
        } catch let error {
            print("got an error creating the request: \(error)")
        }
    }
    
    
    
}
