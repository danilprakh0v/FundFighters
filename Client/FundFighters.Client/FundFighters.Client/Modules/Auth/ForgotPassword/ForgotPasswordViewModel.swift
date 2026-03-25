/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: ForgotPasswordViewModel.swift
Расположение: FundFighters.Client/FundFighters.Client/Modules/Auth/ForgotPassword/
Назначение: UI/Логика компонента ForgotPasswordViewModel.swift
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 04.02.2026
===============================================================================
*/

import Foundation

final class ForgotPasswordViewModel {
    private let apiService = APIService.shared
    
    var onLoading: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    var onResetInitiated: ((String) -> Void)? // returns email
    var onPasswordResetSuccess: (() -> Void)?

    func initiateReset(email: String) {
        guard !email.isEmpty else {
            onError?("Please enter your email.")
            return
        }
        onLoading?(true)
        apiService.forgotPassword(request: ForgotPasswordRequest(email: email)) { [weak self] result in
            DispatchQueue.main.async {
                self?.onLoading?(false)
                switch result {
                case .success:
                    self?.onResetInitiated?(email)
                case .failure(let error):
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }

    func completeReset(email: String, code: String, newPass: String) {
        onLoading?(true)
        apiService.resetPassword(request: ResetPasswordRequest(email: email, code: code, newPassword: newPass)) { [weak self] result in
            DispatchQueue.main.async {
                self?.onLoading?(false)
                switch result {
                case .success:
                    self?.onPasswordResetSuccess?()
                case .failure(let error):
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
}
