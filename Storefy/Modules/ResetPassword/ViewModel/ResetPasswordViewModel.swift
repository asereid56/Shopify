//
//  ResetPasswordViewModel.swift
//  Shopify
//
//  Created by Mina on 21/06/2024.
//

import Foundation

class ResetPasswordViewModel {
    func resetPassword(with email: String, completion: @escaping () -> Void) {
        AuthenticationManager.shared.resetPassword(with: email) {
            completion()
        }
    }
}
