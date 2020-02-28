//
//  WKWebView+Ext.swift
//  RoamMobile
//
//  Created by Daniel Aditya Istyana on 27/02/20.
//  Copyright © 2020 Daniel Aditya Istyana. All rights reserved.
//

import WebKit

var ToolbarHandle: UInt8 = 0

extension WKWebView {
  
  func addInputAccessoryView(toolbar: UIView?) {
    guard let toolbar = toolbar else {return}
    objc_setAssociatedObject(self, &ToolbarHandle, toolbar, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    
    var candidateView: UIView? = nil
    for view in self.scrollView.subviews {
      let description : String = String(describing: type(of: view))
      if description.hasPrefix("WKContent") {
        candidateView = view
        break
      }
    }
    guard let targetView = candidateView else {return}
    let newClass: AnyClass? = classWithCustomAccessoryView(targetView: targetView)
    
    guard let targetNewClass = newClass else {return}
    
    object_setClass(targetView, targetNewClass)
  }
  
  func classWithCustomAccessoryView(targetView: UIView) -> AnyClass? {
    guard let _ = targetView.superclass else {return nil}
    let customInputAccesoryViewClassName = "_CustomInputAccessoryView"
    
    var newClass: AnyClass? = NSClassFromString(customInputAccesoryViewClassName)
    if newClass == nil {
      newClass = objc_allocateClassPair(object_getClass(targetView), customInputAccesoryViewClassName, 0)
    } else {
      return newClass
    }
    
    let newMethod = class_getInstanceMethod(WKWebView.self, #selector(WKWebView.getCustomInputAccessoryView))
    class_addMethod(newClass.self, #selector(getter: WKWebView.inputAccessoryView), method_getImplementation(newMethod!), method_getTypeEncoding(newMethod!))
    
    objc_registerClassPair(newClass!)
    
    return newClass
  }
  
  @objc func getCustomInputAccessoryView() -> UIView? {
    var superWebView: UIView? = self
    while (superWebView != nil) && !(superWebView is WKWebView) {
      superWebView = superWebView?.superview
    }
    
    guard let webView = superWebView else {return nil}
    
    let customInputAccessory = objc_getAssociatedObject(webView, &ToolbarHandle)
    return customInputAccessory as? UIView
  }
}


