//
//  URLViewController.swift
//  n2khide
//
//  Created by localuser on 28.06.18.
//  Copyright © 2018 cqd.ch. All rights reserved.
//

import UIKit
import WebKit

class URLViewController: UIViewController, WKNavigationDelegate, UISearchBarDelegate, UIWebViewDelegate, WKUIDelegate {
    
    weak var firstViewController: HiddingViewController?
    
    

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @objc func save() {
        presentingViewController?.dismiss(animated: true, completion: {
            // code
        })
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        var text = searchBar.text
        var url = URL(string: text!)  //type "http://www.apple.com"
        var req = URLRequest(url: url!)
        self.webView!.load(req)
    }
    
    // MARK: View methids
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        webView.uiDelegate = self
        searchBar.delegate = self
        
        webView.configuration.preferences.javaScriptEnabled = true
        
        
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(save))
        navigationItem.rightBarButtonItem = rightBarButton
        
//        let url = URL(string: "https://www.hackingwithswift.com")!
//        webView.load(URLRequest(url: url))
//        webView.allowsBackForwardNavigationGestures = true

        // Do any additional setup after loading the view.
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
