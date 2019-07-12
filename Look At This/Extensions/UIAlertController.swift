//
//  UIAlertController.swift
//  Look At This
//
//  Created by Artem Kirillov on 12/07/2019.
//

import UIKit

extension UIAlertController {
    
    static func standard(error: Error) -> UIAlertController {
        let alertContoller = UIAlertController(
            title: "Something went wrong",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        let action = UIAlertAction(
            title: "Ok",
            style: .default,
            handler: { [weak alertContoller] _ in
                alertContoller?.dismiss(animated: true, completion: nil)
        })
        alertContoller.addAction(action)
        return alertContoller
    }
    
}
