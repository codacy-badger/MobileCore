//
//  FTThemeView+Utility.swift
//  FTCoreUtility
//
//  Created by Praveen Prabhakar on 05/08/17.
//  Copyright © 2017 Praveen Prabhakar. All rights reserved.
//

import Foundation

public typealias FTThemeDic = [String : Any]

public extension NSNotification.Name {
    public static let FTSwiftyAppearanceWillRefreshWindow = NSNotification.Name(rawValue: "FTSwiftyAppearanceWillRefreshWindow.Notofication")
    public static let FTSwiftyAppearanceDidRefreshWindow = NSNotification.Name(rawValue: "FTSwiftyAppearanceDidRefreshWindow.Notofication")
}

public struct ThemeStyle {
    public static let defaultStyle = "default"
    static let highlightedStyle = "highlighted"
    static let selectedStyle = "selected"
    static let disabledStyle = "disabled"
    
    static func allStyles() -> [String] {
        return [ThemeStyle.highlightedStyle,
                ThemeStyle.selectedStyle,
                ThemeStyle.disabledStyle]
    }
}

//Used for UIView subclasses Type
public protocol FTThemeProtocol: AnyObject {
    
    // Retruns 'ThemeStyle' specific to current state of object.
    // Say if UIView is disabled, retrun "disabled", which can be clubed with main Theme style.
    // Eg, if currentTheme is 'viewB', then when disabled state, theme willbe : 'viewB:disabled'
    func get_ThemeSubType() -> String?
    
    // Custom Subclass can implement, to config Custom component
    func updateTheme(_ theme: FTThemeDic)
}

public extension FTThemeProtocol where Self: UIView {
    func get_ThemeSubType() -> String? {
        // If view is disabled, check for ".disabledStyle" style
        return self.isUserInteractionEnabled ? nil : ThemeStyle.disabledStyle
    }
}

//Used for UIControl objects, when multiple states are possible to set at initalization
public protocol FTUIControlThemeProtocol: FTThemeProtocol {
    
    func get_AllThemeSubType() -> Bool
    func setThemes(_ themes: FTThemeDic)
    func update(themeDic: FTThemeDic, state: UIControl.State)
}

extension UIView {

    // Swizzling out view's layoutSubviews property for Updating Visual theme
    static var SwizzleLayoutSubview = {
        FTInstanceSwizzling(UIView.self, #selector(layoutSubviews), #selector(swizzled_layoutSubviews))
    }
    static func __setupThemes__() { _ = SwizzleLayoutSubview }
    
    // Theme style-name for the view
    @IBInspectable
    public var theme: String? {
        get { return UIView.aoThemes[self] }
        set {
            UIView.aoThemes[self] = newValue
            //Relaod view's theme, if styleName changes, when next time view layouts
            self.needsThemesUpdate = true
        }
    }
    
    // To tigger view-Theme styling
    private var needsThemesUpdate: Bool {
        get { return UIView.aoThemesNeedsUpdate[self] ?? false }
        set {
            UIView.aoThemesNeedsUpdate[self] = newValue
            if newValue {
                self.setNeedsLayout()
                //Update View with Theme properties
                self.generateVisualThemes()
            }
        }
    }
    
    open override func prepareForInterfaceBuilder() {
//        showErrorIfInvalidStyles()
    }
    
    // MARK: swizzled layoutSubviews
    @objc func swizzled_layoutSubviews() {
        if self.needsThemesUpdate {
            self.__updateVisualThemes__()
        }
        // Invoke view's original layoutSubviews
        self.swizzled_layoutSubviews()
    }
}

fileprivate extension UIView {
    
    static let aoThemes = FTAssociatedObject<String>()
    static let aoThemesNeedsUpdate = FTAssociatedObject<Bool>()

    final func __updateVisualThemes__() {
        self.needsThemesUpdate = false
        // Update View with Theme properties
        self.generateVisualThemes()
    }
    
    func generateVisualThemes() {
        
        // If Theme is emtpy, retrun
        guard !FTThemesManager.themesJSON.isEmpty else {
            return
        }
        
        // Get ThemeName and view's name to get Theme's property
        guard let (className, themeName) = self.get_ThemeName() else {
            return
        }
        
        // Checkout if view supports Theming protocol
        let delegate: FTThemeProtocol? = self as? FTThemeProtocol
        
        // Get Theme property of view based on its state
        guard let themeDic = FTThemesManager.generateVisualThemes(forClass: className,
                                                                  withStyleName: themeName,
                                                                  withSubStyleName: delegate?.get_ThemeSubType()) else {
            return
        }
        
        // Step 1. Config view with new Theme-style
        self.configureTheme(themeDic)
        
        // Step 2. Only needed for UIControl types, Eg. Button
        guard let controlThemeSelf = self as? FTUIControlThemeProtocol else {
            return
        }

        // Get styles for diffrent states of UIControl
        if controlThemeSelf.get_AllThemeSubType() == true {
            
            let baseName = themeName.components(separatedBy: ":").first

            var styles: FTThemeDic = [:]

            //For each style, get Theme value
            ThemeStyle.allStyles().forEach { (style) in
                
                if let styleThemeDic = FTThemesManager.generateVisualThemes(forClass: className,
                                                                       withStyleName: baseName!,
                                                                       withSubStyleName: style) {
                    
                    //Create FTThemeDic as, ['ThemeStyle.UIControlState' : 'ActualTheme for the state']
                    styles[style] = styleThemeDic
                }
            }
            
            //Setup visual component for each style
            controlThemeSelf.setThemes(styles)
        }
    }
    
    // Retruns ('classname', 'Theme-style-name') only if both are valid
    func get_ThemeName() -> (String, String)? {
        
        // Vadidate className and ThemeName
        guard
            let className = get_classNameAsString(obj: self),
            let themeName = self.theme else {
            return nil
        }
        
        var baseClassName: String? = className
    
        // Iterate through superClass till we get a valid Theme class
        while baseClassName != nil && !FTThemesManager.isViewComponentValid(componentName: baseClassName!) {
            //Get super Class
            let superClass: AnyClass? = class_getSuperclass(type(of: self))
            
            //If SuperClass becomes invalid, terminate loop
            if (superClass != nil) && superClass != NSObject.self {
                 baseClassName = get_classNameAsString(obj: superClass!)
            } else{
                break
            }
        }
        
        // If there is no valid Theme, return nil
        if baseClassName == nil {
            return nil
        }
        
        // Create (class,theme) name pair
        return (baseClassName!, themeName)
    }
    
    // Update view with styleValues
    @objc func configureTheme(_ themeDic: FTThemeDic?) {
        
        guard let theme = themeDic else {
            return
        }
        
        // Set theme for view
        self.swizzled_updateTheme(theme)
        
        // Only needed for UIControl types, Eg. Button
        guard let controlThemeSelf = self as? FTUIControlThemeProtocol else {
            return
        }
        
        // Get all subTheme for all stats of the control
        let themeDic = [controlThemeSelf.get_ThemeSubType() ?? ThemeStyle.defaultStyle : theme]
        controlThemeSelf.setThemes(themeDic)
    }
}

//MARK: UIView: FTThemeProtocol
extension UIView {
    
    @objc public func swizzled_updateTheme(_ theme: FTThemeDic) {

        // "backgroundColor"
        if let textcolor = theme["backgroundColor"] {
            if
                let colorName = textcolor as? String,
                let color = FTThemesManager.getColor(colorName) {
                self.theme_backgroundColor(color)
                // TODO: For attributed title
            }
        }

        // "layer"
        // TODO: to generate a layer and add it as subView
        if let layerValue = theme["layer"] as? FTThemeDic {
            FTThemesManager.getBackgroundLayer(layerValue, toLayer: self.layer)
        }
        
        // Only needed for UIView types that has extended from FTThemeProtocol
        guard let controlThemeSelf = self as? FTThemeProtocol else {
            return
        }
        
        controlThemeSelf.updateTheme(theme)
    }
    
    // views background color
    public func theme_backgroundColor(_ color: UIColor) {
        self.backgroundColor = color
    }
}

//MARK: UIControl : Style for Different states for UIControl object
extension UIControl {
    
    public func get_AllThemeSubType() -> Bool { return true }

    public func setThemes(_ themes: FTThemeDic) {
        
        guard let themeSelf = self as? FTUIControlThemeProtocol else {
            return
        }

        for (kind, value) in themes {
            
            guard let theme = value as? FTThemeDic else { continue }
            
            switch kind {
                
            case ThemeStyle.defaultStyle:
                themeSelf.update(themeDic: theme, state: .normal)
                break
                
            case ThemeStyle.disabledStyle:
                themeSelf.update(themeDic: theme, state: .disabled)
                break
                
            case ThemeStyle.highlightedStyle:
                themeSelf.update(themeDic: theme, state: .highlighted)
                break
                
            case ThemeStyle.selectedStyle:
                themeSelf.update(themeDic: theme, state: .selected)
                break
                
            default:
                break
            }
        }
    }
}

//MARK: Window Refresh
public extension UIWindow {

    @nonobjc private func _refreshAppearance() {
        let constraints = self.constraints
        removeConstraints(constraints)
        for subview in subviews {
            subview.removeFromSuperview()
            addSubview(subview)
        }
        addConstraints(constraints)
    }

    // / Refreshes appearance for the window
    // / - Parameter animated: if the refresh should be animated
    public func refreshAppearance(animated: Bool) {
        NotificationCenter.default.post(name: .FTSwiftyAppearanceWillRefreshWindow, object: self)
        UIView.animate(withDuration: animated ? 0.25 : 0, animations: {
            self._refreshAppearance()
        }, completion: { _ in
            NotificationCenter.default.post(name: .FTSwiftyAppearanceDidRefreshWindow, object: self)
        })
    }
}
