//
//  FTData.swift
//  FTCoreUtility
//
//  Created by Praveen Prabhakar on 11/04/18.
//  Copyright © 2018 Praveen Prabhakar. All rights reserved.
//

import Foundation

public extension Data {

    //Data decoder based on resposne mimeType or defaluts to [.utf8, .unicode]
    public func decodeToString(forResponse response: URLResponse? = nil, encodingList: [String.Encoding] = [.utf8, .unicode]) -> String? {

        var html: String? = nil

        //Try to decode the String
        for type in encodingList {
            html = String(bytes: self, encoding: type)
            if html != nil {
                break
            }
        }

        return (html)
    }
}
