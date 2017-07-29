//
//  FTAssociatedObject.swift
//  FTCoreUtility
//
//  Created by Praveen Prabhakar on 29/07/17.
//  Copyright © 2017 Praveen Prabhakar. All rights reserved.
//

import Foundation

public class FTAssociatedObject<T> {
    
    private let aoPolicy: objc_AssociationPolicy

    public init(policy aoPolicy:objc_AssociationPolicy) {
        self.aoPolicy = aoPolicy
    }
    
    public convenience init(){
        self.init(policy: objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    public subscript(instance: AnyObject) -> T? {
        get { return objc_getAssociatedObject(instance, Unmanaged.passUnretained(self).toOpaque()) as! T? }
        set { objc_setAssociatedObject(instance, Unmanaged.passUnretained(self).toOpaque(), newValue, self.aoPolicy)}
    }
}
