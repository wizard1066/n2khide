//
//  WebViewController.swift
//  n2khide
//
//  Created by localuser on 04.07.18.
//  Copyright © 2018 cqd.ch. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, UISearchBarDelegate {
    
    weak var firstViewController: EditWaypointController?
    weak var secondViewController: HiddingViewController?
    weak var thirdViewController: HideTableViewController?
    var nameOfNode: String?
    var challenge2A: String?
    var index2U: Int?

    @IBOutlet weak var progressBar: UIProgressView!
    @IBAction func doneButton(_ sender: Any) {
        dismiss(animated: true) {
            // do something
        }
    }
    
  
    @IBOutlet weak var searchBar: UISearchBar? = nil
    
//    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        if let web2S = URL(string: searchBar.text!) {
//            let request = URLRequest(url: web2S)
//            webView.load(request)
//        }
//    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let web2S = URL(string: searchBar.text!) {
            let request = URLRequest(url: web2S)
            webView.load(request)
        }
    }
    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if let web2S = URL(string: searchBar.text!) {
//            let request = URLRequest(url: web2S)
//            webView.load(request)
//        }
//    }
    
    // MARK: Web routines
    @IBAction func backButtonAction(_ sender: Any) {
        webView.goBack()
    }
    
    @IBAction func forwardButtonAction(_ sender: Any) {
        webView.goForward()
    }
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    
    @IBOutlet weak var webViewOutlet: WKWebView!
    @IBOutlet weak var webView: WKWebView!
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
        progressBar.setProgress(0.0, animated: false)
       
        secondViewController?.didSetURL(name: nameOfNode, URL: webView.url?.absoluteString)
        let defaults:UserDefaults = UserDefaults.standard
        defaults.set(webView.url?.absoluteString, forKey: "URLUsed")
        if challenge2A != nil {
            challenge()
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("fcuk04072018 didStartProvisionalNavigation \(navigation.description)")
        progressBar.setProgress(0.0, animated: false)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.uiDelegate = self
        webView.navigationDelegate = self
        backButton.isEnabled = false
        forwardButton.isEnabled = false
        searchBar?.delegate = self
        searchBar?.autocapitalizationType = .none
        searchBar?.autocorrectionType = .no
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        let defaults:UserDefaults = UserDefaults.standard
        if let opened:String = defaults.string(forKey: "URLUsed" ) {
            if let web2S = URL(string: opened) {
                let request = URLRequest(url: web2S)
                searchBar?.text = opened
                webView.load(request)
            }
        }
        // Do any additional setup after loading the view.
    }
    
    // MARK: challenge code
    
    func challenge() {
        let alert = UIAlertController(title: "Challenge", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Challenge"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            if textField?.text != "" {
                if textField?.text == self.challenge2A {
                    listOfPoint2Search[self.index2U!].bon = true
                } else {
                    self.challenge()
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default,handler: { [weak alert] (_) in
            listOfPoint2Search[self.index2U!].bon = false
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Views Code
    
    override func viewDidDisappear(_ animated: Bool) {
        // do something
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "estimatedProgress") {
            progressBar.isHidden = webView.estimatedProgress == 1
            progressBar.setProgress(Float(webView.estimatedProgress), animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
