/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: VerificationViewModel.swift
Расположение: FundFighters.Client/FundFighters.Client/Modules/Auth/Verification/
Назначение: ViewModel handling verification logic (Email, Login). //              ViewModel, обрабатывающая логику подтверждения (Email, Вход).
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 14.03.2026
===============================================================================
*/

import Foundation

final class VerificationViewModel {
    
    // MARK: - Properties
    
    private let apiService = APIService.shared
    
    // Closures for UI binding
    var onVerificationSuccess: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoading: ((Bool) -> Void)?
    
    // MARK: - Actions
    
    func verify(email: String, code: String, type: VerificationType) {
        onLoading?(true)
        
        let request = VerifyCodeRequest(email: email, code: code)
        
        if type == .emailRegistration {
            apiService.verifyEmail(request: request) { [weak self] result in
                DispatchQueue.main.async {
                    self?.onLoading?(false)
                    switch result {
                    case .success:
                        self?.onVerificationSuccess?()
                    case .failure(let error):
                        self?.onError?(error.localizedDescription)
                    }
                }
            }
        } else {
            apiService.verifyLogin(request: request) { [weak self] result in
                DispatchQueue.main.async {
                    self?.onLoading?(false)
                    switch result {
                    case .success(let response):
                        if let token = response.token {
                            TokenManager.shared.save(token)
                            self?.onVerificationSuccess?()
                        } else {
                            self?.onError?("Verification failed: No token received.")
                        }
                    case .failure(let error):
                        self?.onError?(error.localizedDescription)
                    }
                }
            }
        }
    }
}
