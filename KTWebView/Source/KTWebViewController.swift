//
//  KTWebViewController.swift
//  KTWebView
//
//  Created by @TryWabbit on 6/03/19.
//  Copyright © 2019 Jaded developers. All rights reserved.
//

import UIKit
import WebKit
class KTWebViewController: UIViewController {
    
    private let webview = WKWebView()
    @IBOutlet weak private var viewBase: UIView!
    @IBOutlet weak private var  viewClose: UIView!
    @IBOutlet weak private var viewBottomBar: UIView!
    @IBOutlet weak private var btnForward: UIButton!
    @IBOutlet weak private var btnBack: UIButton!
    @IBOutlet weak private var btnRefresh: UIButton!
    @IBOutlet weak private var constraintCloseBottom: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var url : String?
    
    private var previousContentOffset : CGFloat = 0.0
    private var barAnimationDuration = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addWebview()
        if let finalUrl = URL(string: url ?? "https://github.com/tryWabbit") {
            webview.load(URLRequest(url: finalUrl))
        }
    }
    private func addShadows() {
        let offset = CGSize(width: -1.0, height: -1.0)
        let ridius : CGFloat = 5.0
        viewBottomBar.addShadow(offset:offset , color: UIColor.lightGray, radius: ridius, opacity: 1.0)
        viewClose.addShadow(offset:offset , color: UIColor.lightGray, radius: ridius, opacity: 1.0)
    }
    private func addWebview() {
        webview.navigationDelegate  = self
        webview.uiDelegate  = self
        webview.scrollView.delegate = self
        webview.frame = viewBase.frame
        viewBase.insertSubview(webview, at: 0)
        webview.translatesAutoresizingMaskIntoConstraints = false
        viewBase.addConstraint(NSLayoutConstraint(item: viewBase , attribute: .top, relatedBy: .equal, toItem:webview , attribute: .top, multiplier: 1.0, constant: 0.0))
        viewBase.addConstraint(NSLayoutConstraint(item: viewBase, attribute: .bottom, relatedBy: .equal, toItem: webview, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        viewBase.addConstraint(NSLayoutConstraint(item: viewBase, attribute: .leading, relatedBy: .equal, toItem: webview, attribute: .leading, multiplier: 1.0, constant: 0.0))
        viewBase.addConstraint(NSLayoutConstraint(item: viewBase, attribute: .trailing, relatedBy: .equal, toItem: webview, attribute: .trailing, multiplier: 1.0, constant: 0.0))
    }
    private func setupView() {
        addShadows()
        viewClose.backgroundColor = UIColor.clear
        viewBottomBar.backgroundColor = UIColor.clear
        viewClose.addBlur()
        viewBottomBar.addBlur()
        viewClose.makeCircle = true
        viewClose.clipsToBounds = true
    }
    class func getViewController() -> KTWebViewController {
        return KTWebViewController.init(nibName: "KTWebViewController", bundle: nil)
    }
    
    //MARK :- Actions
    @IBAction private func closeButtonPressed(_ sender: Any) {
        if let navigation = self.navigationController {
            navigation.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    @IBAction private func refreshButtonPressed(_ sender: Any) {
        webview.reload()
    }
    
    @IBAction private func forwardPressed(_ sender: Any) {
        if webview.canGoForward {
            webview.goForward()
        }
    }
    @IBAction private func backPressed(_ sender: Any) {
        if webview.canGoBack {
            webview.goBack()
        }
    }
    private func showNavigationBar() {
        guard constraintCloseBottom.constant != 0.0 else { return }
        constraintCloseBottom.constant = 0.0
        viewBottomBar.alpha = 0.0
        viewClose.alpha = 0.0
        UIView.animate(withDuration: barAnimationDuration) {
            self.viewBottomBar.alpha = 1.0
            self.viewClose.alpha = 1.0
            self.viewBase.layoutIfNeeded()
        }
    }
    private func hideNavigationBar() {
        guard constraintCloseBottom.constant == 0.0 else { return }
        constraintCloseBottom.constant = -(viewClose.frame.height)
        viewBottomBar.alpha = 1.0
        viewClose.alpha = 1.0
        UIView.animate(withDuration: barAnimationDuration, animations: {
            self.viewBottomBar.alpha = 0.0
            self.viewClose.alpha = 0.0
            self.viewBase.layoutIfNeeded()
        })
    }
    
}
extension KTWebViewController : WKNavigationDelegate{
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        updateButtons(webView: webView)
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        updateButtons(webView: webView)
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }
    private func updateButtons(webView:WKWebView) {
        let enableColor = UIColor.black
        let disableColor = UIColor.lightGray
        let back  = webView.canGoBack
        let forward  = webView.canGoForward
        btnForward.isEnabled = forward
        btnBack.isEnabled = back
        btnForward.tintColor = forward ? enableColor : disableColor
        btnBack.tintColor = back ? enableColor : disableColor
    }
}
extension KTWebViewController : WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webview.stopLoading()
            webview.load(navigationAction.request)
        }
        return nil
    }
}
extension KTWebViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentContentOffset = scrollView.contentOffset.y;
        guard (currentContentOffset + webview.frame.height) < scrollView.contentSize.height else { return }
        if currentContentOffset <= 0.0 {
            showNavigationBar()
        }else if (currentContentOffset > previousContentOffset) {
            // scrolling towards the bottom
            hideNavigationBar()
        } else if (currentContentOffset < previousContentOffset) {
            // scrolling towards the top
            showNavigationBar()
        }
        previousContentOffset = currentContentOffset
        print(currentContentOffset)
    }
}

extension UIView {
    public func addBlur(style: UIBlurEffect.Style = .extraLight) {
        let blurEffect = UIBlurEffect(style: style)
        let blurBackground = UIVisualEffectView(effect: blurEffect)
        insertSubview(blurBackground, at: 0)
        blurBackground.translatesAutoresizingMaskIntoConstraints = false
        blurBackground.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        blurBackground.topAnchor.constraint(equalTo: topAnchor).isActive = true
        blurBackground.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        blurBackground.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    @IBInspectable var cornerRadius: Double {
        get {
            return Double(self.layer.cornerRadius)
        }set {
            self.layer.cornerRadius = CGFloat(newValue)
        }
    }
    
    @IBInspectable var makeCircle : Bool {
        get {
            return self.makeCircle
        } set {
            if newValue {
                self.layer.cornerRadius=self.frame.height/2
            } else {
                self.layer.cornerRadius=0
            }
        }
    }
    func addShadow(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float) {
        layer.masksToBounds = false
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        let backgroundCGColor = backgroundColor?.cgColor
        backgroundColor = nil
        layer.backgroundColor =  backgroundCGColor
    }
}
