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
  
  var webView: WKWebView!
  var toolbar : UIToolbar?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .systemBackground
    
    setupWebView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: true)
  }
  
  func setupWebView() {
    
    if let disableZoomScript = generateMetaViewportScript() {
      wkController.addUserScript(disableZoomScript)
    }
    
    if let customCSSScript = generateCustomCSS() {
      wkController.addUserScript(customCSSScript)
    }
    
//    if let darkModeCSSSCript = generateDarkModeCSS() {
//      wkController.addUserScript(darkModeCSSSCript)
//    }
    
    // need user agent in order to be able to sign in when using Google service
    config.applicationNameForUserAgent = "Version/8.0.2 Safari/600.2.5"
    config.userContentController = wkController
    
    webView = WKWebView(frame: .zero, configuration: config)
    let url = URL(string: "https://roamresearch.com/#/")
    let urlRequest = URLRequest(url: url!, cachePolicy: .useProtocolCachePolicy)
    webView.load(urlRequest)
    
    webView.addInputAccessoryView(toolbar: getToolbar(height: 44))
    
    webView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(webView)
    
    NSLayoutConstraint.activate([
      webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
    ])
    
    webView.navigationDelegate = self
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
      if traitCollection.userInterfaceStyle == .dark {
        // do something with dark mode, possibly inject javascript then reload the page
      } else {
        // remove the dark mode css
      }
    }
  }
  
  func generateMetaViewportScript() -> WKUserScript? {
    guard let scriptPath = Bundle.main.path(forResource: "betterroam", ofType: "js"),
      let scriptContent = try? String(contentsOfFile: scriptPath) else {
        return nil
    }
    
    let script = WKUserScript(source: scriptContent, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    return script
  }
  
  func generateCustomCSS() -> WKUserScript? {
    guard let cssPath = Bundle.main.path(forResource: "betterroam", ofType: "css"),
      let cssContent = try? String(contentsOfFile: cssPath) else {
        return nil
    }
    
    let cssScript = "var style = document.createElement('style'); style.innerHTML = '\(cssContent.components(separatedBy: .newlines).joined())'; document.head.appendChild(style);"
  
    let script = WKUserScript(source: cssScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    return script
  }
  
  func generateDarkModeCSS() -> WKUserScript? {
     guard let darkModeCssPath = Bundle.main.path(forResource: "darkmode-roam", ofType: "css"),
       let darkModeCssContent = try? String(contentsOfFile: darkModeCssPath) else {
         return nil
     }
     
     let darkModeCssScript = "var style = document.createElement('style'); style.innerHTML = '\(darkModeCssContent.components(separatedBy: .newlines).joined())'; document.head.appendChild(style);"
   
     let script = WKUserScript(source: darkModeCssScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
     return script
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
    let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil )
    
    let toolBarItems = [
      increaseIndentButton,
      spacer,
      decreaseIndentButton,
      spacer,
      upButton,
      spacer,
      downButton,
      spacer,
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
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .darkContent
  }
  
}

extension MainViewController: WKNavigationDelegate {
  
  func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    guard let url = navigationAction.request.url else { return }
    print(url)
    if url.absoluteString.contains("https://roamresearch.com/#/app") {
      if traitCollection.userInterfaceStyle == .dark {
        guard let darkModeCssPath = Bundle.main.path(forResource: "darkmode-roam", ofType: "css"),
          let darkModeCssContent = try? String(contentsOfFile: darkModeCssPath) else {
            return
        }
        
        let darkModeCssScript = "var style = document.createElement('style'); style.innerHTML = '\(darkModeCssContent.components(separatedBy: .newlines).joined())'; document.head.appendChild(style);"
        
        let popOverScript = "document.getElementsByClassName('bp3-elevation-3')[0].getAttribute('style').replace('background-color: white;', 'background-color: #191919;');"
        
        webView.evaluateJavaScript(darkModeCssScript, completionHandler: nil)
        webView.evaluateJavaScript(popOverScript, completionHandler: nil)
      }
    }
    decisionHandler(.allow)
  }
}


