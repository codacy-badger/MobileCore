//
//  FTUITabBar.swift
//  FTCoreUtility
//
//  Created by Praveen Prabhakar on 18/08/17.
//  Copyright © 2017 Praveen Prabhakar. All rights reserved.
//

import Foundation

open class FTUITabBar: UITabBar, FTThemeProtocol {

    public func updateTheme(_ theme: FTThemeDic) { }

    public func get_ThemeSubType() -> String? {
        return self.isUserInteractionEnabled ? nil : ThemeStyle.disabledStyle
    }
    
    open func theme_backgroundColor(_ color: UIColor) {
        self.backgroundColor = color
    }
}
