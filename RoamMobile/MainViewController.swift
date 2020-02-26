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
  
  var webView: NoToolbar!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    
    let disableZoom = WKUserScript(source: disableZoomScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    wkController.addUserScript(disableZoom)
    
    // needed in order to be able to sign in when using Google service
    config.applicationNameForUserAgent = "Version/8.0.2 Safari/600.2.5"
    config.userContentController = wkController
    
//    webView = WKWebView(frame: .zero, configuration: config) as! NoToolbar
    webView = CustomToolbarWebView(frame: .zero, configuration: config)
    let url = URL(string: "https://roamresearch.com")
    let urlRequest = URLRequest(url: url!)
    webView.load(urlRequest)
    
    webView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(webView)
    
    NSLayoutConstraint.activate([
      webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
    ])
    
    setToolbar()
  }
  
  override var inputAccessoryView: UIView? {
    return nil
  }
  
  func setToolbar() {
    let screenWidth = self.view.bounds.width
    let increaseIndentBarButton = UIBarButtonItem(image: UIImage(systemName: "increase.indent"), style: .plain, target: self, action: #selector(handleIncreaseIndent))
    
    let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 44))
    toolbar.isTranslucent = false
    toolbar.translatesAutoresizingMaskIntoConstraints = false
    
    toolbar.items = [increaseIndentBarButton]
    
    webView.addSubview(toolbar)
    
    NSLayoutConstraint.activate([
      toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
    
  }
  
  @objc func handleIncreaseIndent() {
    
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .darkContent
  }

  
  
}



