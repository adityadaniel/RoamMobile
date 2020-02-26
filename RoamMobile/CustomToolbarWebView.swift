//
//  NoToolbar.swift
//  RoamMobile
//
//  Created by Daniel Aditya Istyana on 26/02/20.
//  Copyright © 2020 Daniel Aditya Istyana. All rights reserved.
//

import UIKit
import WebKit

class CustomToolbarWebView: WKWebView {
  
  override var inputAccessoryView: UIView? {
    return nil
  }
  
  override init(frame: CGRect, configuration: WKWebViewConfiguration) {
    super.init(frame: frame, configuration: configuration)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  

}
