//
//  RestClient.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 07/11/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//

import Alamofire

class RestClient {
    
    public enum ANHttpMethod {
        case get
        case post
        case delete
    }
    
    public static func httpRequest(url: String , method: ANHttpMethod, params: [String: Any], isLoading: Bool, httpResponse: @escaping ([String: Any]) -> Void) {
        
        var alamofireHttpMethod: HTTPMethod?
        switch method {
        case .get:
            alamofireHttpMethod = .get
            break
            
        case .post:
            alamofireHttpMethod = .post
            break
            
        case .delete:
            alamofireHttpMethod = .delete
            break
        }
        
        print("Http url: \(url)")
        print("Http param: \(params)")
        
        let loginVo = LPHUtils.getLoginVo()
//        var header = Dictionary<String, String>()
        var header : HTTPHeaders = ["Authorization": "Basic MY-API-KEY",
                                    "Content-Type" : "application/x-www-form-urlencoded"
                                ]
        
        if loginVo.isLoggedIn && loginVo.loginType != .withoutLogin {
            print("Header")
            header["Authorization"] = "Bearer \(loginVo.token)"
            print(header)
        }

        AF.request(url, method: alamofireHttpMethod!, parameters: params, encoding: URLEncoding.default, headers: header).responseJSON(completionHandler: { (responseData) in
            print("Http response: \(responseData)")
            httpResponse(responseData.result as! [String: Any])
        })
        
    }
    
    public static func initiateDownload(fileRemoteUrl: String, fileName: String) {
        
        let destination: DownloadRequest.Destination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(fileName)
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        AF.download(fileRemoteUrl, to: destination).downloadProgress{ progress in
            print("logo download progress: \(progress.fractionCompleted)")
            }.response { response in
                
//                if response.error == nil, let _ = response.destinationURL?.path {
//                    print("download completed successfully")
//                } else {
//                    print("download error")
//                }
        }
    }
    
}

