//
//  FTUtils.swift
//  FTMobileCore
//
//  Created by Praveen Prabhakar on 15/06/17.
//  Copyright © 2017 Praveen Prabhakar. All rights reserved.
//

import Foundation

//CGRect
public extension CGRect {
    
    func getX() -> CGFloat {
        return self.origin.x
    }
    
    func getY() -> CGFloat {
        return self.origin.y
    }
    
    func getWidth() -> CGFloat {
        return self.size.width
    }
    
    func getHeight() -> CGFloat {
        return self.size.height
    }
}

public let FTInstanceSwizzling: (AnyClass, Selector, Selector) -> () = { forClass, originalSelector, swizzledSelector in
    let originalMethod = class_getInstanceMethod(forClass, originalSelector)
    let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector)
    method_exchangeImplementations(originalMethod, swizzledMethod)
}
