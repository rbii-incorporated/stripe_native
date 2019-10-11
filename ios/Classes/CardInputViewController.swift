//
//  CardInputViewController.swift
//  Flutter
//
//  Created by John N Blanchard on 10/8/19.
//

import UIKit
import Stripe

protocol CardInputDelegate {
    func canceled(reason: CardInputFailure)
    func completed(token: String)
}

enum CardInputFailure: Error {
    case DismissedByUser
    case CardTokenization
}

class CardInputViewController: UIViewController, STPPaymentCardTextFieldDelegate {
    
    var cancelButton: UIBarButtonItem?
    var doneButton: UIBarButtonItem?
    var stripeTextField: STPPaymentCardTextField?
    
    var delegate: CardInputDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        let coverColor = UIColor(displayP3Red: 242/255, green: 240/255, blue: 240/255, alpha: 1)
        let textTint = UIColor(displayP3Red: 63/255, green: 81/255, blue: 181/255, alpha: 1)
        let buttonFont = UIFont.boldSystemFont(ofSize: 18)
        
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: 0, height: 60));
        navBar.barTintColor = coverColor
        navBar.translatesAutoresizingMaskIntoConstraints = false
        navBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: textTint]
                
        view.addSubview(navBar)
        
        navBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        navBar.heightAnchor.constraint(equalToConstant: 60).isActive = true
        navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    
        let coverView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        coverView.translatesAutoresizingMaskIntoConstraints = false
        coverView.backgroundColor = coverColor
        
        view.addSubview(coverView)
        
        coverView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        coverView.leadingAnchor.constraint(equalTo: navBar.leadingAnchor).isActive = true
        coverView.trailingAnchor.constraint(equalTo: navBar.trailingAnchor).isActive = true
        coverView.bottomAnchor.constraint(equalTo: navBar.topAnchor).isActive = true
        
        cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.done, target: self, action: #selector(cancelTapped))
        cancelButton?.tintColor = textTint
        cancelButton?.setTitleTextAttributes([NSAttributedStringKey.font: buttonFont], for: UIControlState.normal)
        
        doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(doneTapped))
        doneButton?.tintColor = textTint
        doneButton?.isEnabled = false
        doneButton?.setTitleTextAttributes([NSAttributedStringKey.font: buttonFont], for: UIControlState.normal)
        
        let navItem = UINavigationItem(title: "Card Payment")
        
        navItem.leftBarButtonItem = cancelButton
        
        navItem.rightBarButtonItem = doneButton
        
        navBar.setItems([navItem], animated: true)
        
        stripeTextField = STPPaymentCardTextField(frame: CGRect.zero)
        stripeTextField?.delegate = self
        stripeTextField?.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stripeTextField!)
        
        stripeTextField?.topAnchor.constraint(equalTo: navBar.bottomAnchor, constant: 30).isActive = true
        stripeTextField?.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
        stripeTextField?.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10).isActive = true
        stripeTextField?.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
    }
    
    @objc func cancelTapped() { dismiss(animated: true) { self.delegate?.canceled(reason: CardInputFailure.DismissedByUser) } }
    
    @objc func doneTapped() {
        guard let token = stripeTextField?.cardParams.token else {
            dismiss(animated: true) { self.delegate?.canceled(reason: CardInputFailure.CardTokenization) }
            return
        }
        
        dismiss(animated: true) { self.delegate?.completed(token: token) }
    }
    
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) { doneButton?.isEnabled = textField.isValid }
    
    
}
