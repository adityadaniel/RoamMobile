//
//  ViewController.swift
//  RoamMobile
//
//  Created by Daniel Aditya Istyana on 26/02/20.
//  Copyright © 2020 Daniel Aditya Istyana. All rights reserved.
//

import UIKit
import WebKit

class MainViewController: UIViewController {
  
  let config = WKWebViewConfiguration()
  let wkController = WKUserContentController()
  
  let disableZoomScript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width, initial-scale=1, maximum-scale=1'); document.getElementsByTagName('head')[0].appendChild(meta);"
  
  let source = "function captureLog(msg) { window.webkit.messageHandlers.logHandler.postMessage(msg); } window.console.log = captureLog;"
  
  var webView: WKWebView!
  var toolbar : UIToolbar?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    
    let disableZoom = WKUserScript(source: disableZoomScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    wkController.addUserScript(disableZoom)
    let logScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    wkController.addUserScript(logScript)
    // needed in order to be able to sign in when using Google service
    config.applicationNameForUserAgent = "Version/8.0.2 Safari/600.2.5"
    config.userContentController = wkController
    
    webView = WKWebView(frame: .zero, configuration: config)
    let url = URL(string: "https://roamresearch.com")
    let urlRequest = URLRequest(url: url!)
    webView.load(urlRequest)
    
    webView.configuration.userContentController.add(self, name: "logHandler")
    
    
    webView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(webView)
    
    NSLayoutConstraint.activate([
      webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
    ])
    
    webView.addInputAccessoryView(toolbar: self.getToolbar(height: 44))
    
  }
  
  func getToolbar(height: CGFloat) -> UIToolbar? {
    let screenWidth = view.bounds.width
    
    let toolBar = UIToolbar()
    toolBar.frame = CGRect(x: 0, y: 0, width: screenWidth, height: height)
    toolBar.barStyle = .default
    toolBar.tintColor = .systemBlue
    toolBar.barTintColor = .systemBackground
    
    let preferredSymbolConfig = UIImage.SymbolConfiguration(weight: .bold)
    
    let increaseIndentButton = UIBarButtonItem(image: UIImage(systemName: "increase.indent", withConfiguration: preferredSymbolConfig), style: .plain, target: self, action: #selector(handleIncreaseIndent))
    let decreaseIndentButton = UIBarButtonItem(image: UIImage(systemName: "decrease.indent", withConfiguration: preferredSymbolConfig), style: .plain, target: self, action: #selector(handleDecreaseIndent))
    let upButton = UIBarButtonItem(image: UIImage(systemName: "arrow.up", withConfiguration: preferredSymbolConfig), style: .plain, target: self, action: #selector(handleBlockMoveUp))
    let downButton = UIBarButtonItem(image: UIImage(systemName: "arrow.down", withConfiguration: preferredSymbolConfig), style: .plain, target: self, action: #selector(handleBlockMoveDown))
    let searchOrCreateButton = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass", withConfiguration: preferredSymbolConfig), style: .plain, target: self, action: #selector(handleSearchOrCreate))
    
    let flexibleSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil )
    let toolBarItems = [
      increaseIndentButton,
      flexibleSpaceItem,
      decreaseIndentButton,
      flexibleSpaceItem,
      upButton,
      flexibleSpaceItem,
      downButton,
      flexibleSpaceItem,
      searchOrCreateButton
    ]
    
    toolBar.setItems(toolBarItems, animated: false)
    toolBar.isUserInteractionEnabled = true
    
    toolBar.sizeToFit()
    return toolBar
  }
  
  @objc func handleIncreaseIndent() {
    let jsScript = "document.getElementsByClassName('bp3-button bp3-minimal rm-mobile-button dont-unfocus-block')[1].click();"
    webView.evaluateJavaScript(jsScript, completionHandler: nil)
  }
  
  @objc func handleDecreaseIndent() {
    let jsScript = "document.getElementsByClassName('bp3-button bp3-minimal rm-mobile-button dont-unfocus-block')[0].click();"
    webView.evaluateJavaScript(jsScript, completionHandler: nil)
  }
  
  @objc func handleBlockMoveUp() {
    // bp3-button bp3-minimal bp3-icon-arrow-up rm-mobile-button dont-unfocus-block
    let jsScript = "document.getElementsByClassName('bp3-button bp3-minimal bp3-icon-arrow-up rm-mobile-button dont-unfocus-block')[0].click();"
    webView.evaluateJavaScript(jsScript, completionHandler: nil)
  }
  
  @objc func handleBlockMoveDown() {
    // bp3-button bp3-minimal bp3-icon-arrow-down rm-mobile-button dont-unfocus-block
    let jsScript = "document.getElementsByClassName('bp3-button bp3-minimal bp3-icon-arrow-down rm-mobile-button dont-unfocus-block')[0].click();"
    webView.evaluateJavaScript(jsScript, completionHandler: nil)
  }
  
  @objc func handleSearchOrCreate() {
    // #find-or-create-input
    let jsScript = "document.getElementById('find-or-create-input').focus();"
    webView.evaluateJavaScript(jsScript, completionHandler: nil)
  }
  
  @objc func onToolbarDoneClick() {
    webView.resignFirstResponder()
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .darkContent
  }
  
}

extension MainViewController: WKScriptMessageHandler {
  func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    if message.name == "logHandler" {
      print("LOG: \(message.body)")
    }
  }
  
  
}

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
