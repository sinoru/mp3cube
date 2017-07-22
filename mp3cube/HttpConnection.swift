//
//  HttpConnection.swift
//  mp3cube
//
//  Created by INSU BYEON on 20/07/2017.
//  Copyright © 2017 kokonoe. All rights reserved.
//
import Alamofire

class HttpConnection {
    
    init() {
        print("HttpConnection Created")
    }
    
    class var isConnected :Bool {
        return NetworkReachabilityManager()!.isReachable
    }
    
    func search(name: String) -> String {
        var result = ""
        Alamofire.request("https://insu.party")
            .responseString { response in
                print(response.request)
                print(response.response)
                print(response.result)
                if response.result.isSuccess {
                    result = response.result.value!
                    print(result)
                    return result
                } else {
                    result = "failed"
                }
        }
        return result
    }
}
