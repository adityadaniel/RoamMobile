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
        
        setupWebView()
        setupGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupGestureRecognizer() {
        let twoFingerSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleTwoFingerSwipe))
        twoFingerSwipe.numberOfTouchesRequired = 2
        twoFingerSwipe.direction = .down
        twoFingerSwipe.delegate = self
        view.addGestureRecognizer(twoFingerSwipe)
    }
    
    @objc private func handleTwoFingerSwipe() {
        let newVC = UIViewController()
        let navVc = UINavigationController(rootViewController: newVC)
        newVC.view.backgroundColor = .red
        navigationController?.present(navVc, animated: true)
    }
    
    func setupWebView() {
        
        if let disableZoomScript = generateMetaViewportScript() {
            wkController.addUserScript(disableZoomScript)
        }
        
        config.applicationNameForUserAgent = "Version/8.0.2 Safari/600.2.5"
        config.userContentController = wkController
        
        webView = WKWebView(frame: .zero, configuration: config)
        let url = URL(string: "https://roamresearch.com/#/app")
        let urlRequest = URLRequest(url: url!, cachePolicy: .useProtocolCachePolicy)
        webView.load(urlRequest)
    
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return view.backgroundColor == .white ? .darkContent : .lightContent
    }
    
}


extension MainViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
