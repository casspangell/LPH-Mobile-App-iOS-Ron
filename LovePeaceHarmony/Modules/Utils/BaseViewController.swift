//
//  BaseViewController.swift
//  LovePeaceHarmony
//
//  Created by Aghil C M on 07/11/17.
//  Copyright © 2017 LovePeaceHarmony. All rights reserved.
//

import UIKit
import Lottie

class BaseViewController: UIViewController {

    // MARK: - Variables
    private let loadingAnimView = AnimationView(name: LOADING_INDICATOR)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    public func initView() {
        /*let navigationbar = self.navigationController?.navigationBar
        navigationbar?.barTintColor = ANConstant.COLOR_THEME
        navigationbar?.tintColor = ANConstant.COLOR_TEXT
        let titleDict: NSDictionary = [NSAttributedStringKey.foregroundColor: UIColor.white]
        navigationbar?.titleTextAttributes = titleDict as? [NSAttributedStringKey : Any]*/
        initAnimView()
    }
    
    private func initAnimView() {
        loadingAnimView.frame = CGRect(x: (UIScreen.main.bounds.width / 2) - 25, y: (UIScreen.main.bounds.height / 2) - 120, width: 50, height: 50)
        loadingAnimView.animationSpeed = CGFloat(1.5)
        loadingAnimView.loopMode = .loop
    }
    
    public func showLoadingIndicator() {
        view.addSubview(loadingAnimView)
        loadingAnimView.play()
    }
    
    public func hideLoadingIndicator() {
        loadingAnimView.removeFromSuperview()
    }
    
    func showToast(message : String) {
        showToast(message: message, height: Int(CGFloat(self.view.frame.size.height - 100)), width: Int(CGFloat(view.frame.width - 50)), view: view)
    }
    
    func showAlertConfirm(title: String, message: String, vc: UIViewController, callback: @escaping (UIAlertAction) -> Void) {
        var title = title
        if title.count == 0 {
            title = "Alert"
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: callback))
        vc.present(alert, animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String, vc: UIViewController) {
 
        var title = title
        if title.count == 0 {
            title = "Alert"
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    
    private func showToast(message : String, height: Int, width: Int, view: UIView) {
        let toastLabel = UILabel(frame: CGRect(x: 25, y: height, width: width, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "HelveticaNeue", size: 12)
        toastLabel.text = message
        toastLabel.alpha = 0.8
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        view.addSubview(toastLabel)
        UIView.animate(withDuration: 1.0, delay: 1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    func showNoDataText(message: String, tableView: UITableView) {
        let labelNoData: UILabel = UILabel.init(frame: CGRect(x:0, y:0, width:tableView.bounds.size.width, height: tableView.bounds.size.height))
        labelNoData.text = message
        labelNoData.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.light)
        labelNoData.textColor  = UIColor.gray
        labelNoData.textAlignment = .center
        tableView.backgroundView = labelNoData
        animNodataText(labelNoData)
    }

    func animNodataText(_ view: UIView) {
        view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.5, delay: (TimeInterval(0)), usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut,
                       animations: {
                        view.transform = CGAffineTransform(scaleX: 1, y: 1)},completion: nil)
    }
    
    func animateButton(_ view: UIView, _ duration: Double, completionListener: @escaping () -> Void) {
        UIView.animate(withDuration: duration, delay: (TimeInterval(0)), usingSpringWithDamping: 1, initialSpringVelocity: 5, options: .curveEaseInOut,
                       animations: {
                        view.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)},completion: { [weak self] finished in
                            self?.animateOut(view, duration, completionListener)
        })
    }
    
    func animateOut(_ view: UIView, _ duration: Double, _ completionListener: @escaping () -> Void) {
        UIView.animate(withDuration: 0.5, delay: (TimeInterval(0)), usingSpringWithDamping: 1, initialSpringVelocity: 5, options: .curveEaseInOut,
                       animations: {
                        view.transform = CGAffineTransform(scaleX: 1, y: 1)},completion: { finished in
                            completionListener()
                            
        })
    }
    
}
