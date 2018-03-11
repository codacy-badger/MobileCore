//
//  FTServiceClient.swift
//  FTMobileCore
//
//  Created by Praveen Prabhakar on 10/03/18.
//  Copyright © 2017 Praveen Prabhakar. All rights reserved.
//

open class FTServiceClient {
    
    open class func getContentFromURL(_ string: String,
                                 completionHandler: @escaping (_ htmlString: String,_ data: Data, _ httpURLResponse: HTTPURLResponse) -> Swift.Void) {
        
        if string.hasPrefix("http") {
            
            let myURL = URL(string: string)
            
            self.getContentFromURL(myURL!, completionHandler: { (htmlString, data, httpURLResponse) in
                DispatchQueue.main.async() { () -> Void in
                    completionHandler(htmlString, data, httpURLResponse)
                }
            })
            
            return
        }
        
        let html: String = try! String(contentsOfFile: string)
        DispatchQueue.main.async() { () -> Void in
            completionHandler(html, html.data(using: .utf8)!, HTTPURLResponse())
        }
    }
    
    open class func getContentFromURL(_ url: URL,
                                             completionHandler: @escaping (String, Data, HTTPURLResponse) -> Swift.Void,
                                             encodingList: [String.Encoding] = [.utf8, .unicode] ) {
        
        let decodeData = { (data: Data, httpURLResponse: HTTPURLResponse) in
            
            var html: String? = ""
            
            //Try to decode the String
            for type in encodingList {
                html = String(bytes: data, encoding: type)
                if html != nil {
                    break
                }
            }
            
            //Send it main object
            DispatchQueue.main.async() { () -> Void in
                completionHandler(html ?? "", data, httpURLResponse)
            }
        }
        
        //Get content from Net
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let data = data, error == nil
                else { return }
            
            decodeData(data, httpURLResponse)
            
            }.resume()
        
    }
}


