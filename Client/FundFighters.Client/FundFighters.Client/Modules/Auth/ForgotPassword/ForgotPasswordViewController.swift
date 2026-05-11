/*
===============================================================================
Проект: FundFighters (iOS UIKit [Client])
Файл: ForgotPasswordViewController.swift
Расположение: Client/FundFighters.Client/FundFighters.Client/Modules/Auth/ForgotPassword/
Назначение: Экран восстановления пароля. Позволяет запросить код сброса
            на почту и установить новый пароль.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 04.02.2026
===============================================================================
*/

import UIKit

// MARK: - DarkCapsuleTextField (Стилизованное текстовое поле)
fileprivate final class DarkCapsuleTextField: UITextField {
    init(placeholder: String, iconName: String, isSecure: Bool = false) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isSecureTextEntry = isSecure
        autocapitalizationType = .none
        autocorrectionType = .no
        backgroundColor   = .black
        layer.cornerRadius = 14
        layer.cornerCurve  = .continuous
        textColor = .white
        font      = .systemFont(ofSize: 16, weight: .medium)
        attributedPlaceholder = NSAttributedString(string: placeholder,
            attributes: [.foregroundColor: UIColor(white: 0.45, alpha: 1)])
        let icon = UIImageView(image: UIImage(systemName: iconName,
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)))
        icon.tintColor   = DT.accentGreen
        icon.contentMode = .scaleAspectFit
        let container    = UIView(frame: CGRect(x: 0, y: 0, width: 52, height: 24))
        icon.frame       = CGRect(x: 18, y: 2, width: 20, height: 20)
        container.addSubview(icon)
        leftView     = container
        leftViewMode = .always
    }
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - GreenCircleButton (Круглая кнопка)
fileprivate final class GreenCircleButton: UIButton {
    init(iconName: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 26.0, *) {
            var cfg = UIButton.Configuration.prominentGlass()
            cfg.image = UIImage(systemName: iconName,
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))
            cfg.baseBackgroundColor = DT.accentGreen
            cfg.baseForegroundColor = .black
            cfg.cornerStyle = .capsule
            self.configuration = cfg
        } else {
            backgroundColor = DT.accentGreen
            setImage(UIImage(systemName: iconName,
                             withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)),
                     for: .normal)
            tintColor = .black
        }
    }
    required init?(coder: NSCoder) { fatalError() }
    override func layoutSubviews() {
        super.layoutSubviews()
        if #unavailable(iOS 26.0) {
            layer.cornerRadius = bounds.height / 2
            layer.cornerCurve  = .continuous
        }
    }
}

// MARK: - ForgotPasswordViewController
final class ForgotPasswordViewController: UIViewController {
    private let viewModel = ForgotPasswordViewModel()
    
    // Элементы UI
    private lazy var backButton = GreenCircleButton(iconName: "chevron.left")
    private lazy var infoButton = GreenCircleButton(iconName: "info")
    
    private let navTitleLabel: UILabel = {
        let l = UILabel()
        l.text          = "FundFighters"
        l.font          = .systemFont(ofSize: 42, weight: .heavy)
        l.textColor     = .black
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text          = "Reset your\nPassword"
        l.font          = .systemFont(ofSize: 34, weight: .bold)
        l.textColor     = .black
        l.textAlignment = .center
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let detailLabel: UILabel = {
        let l = UILabel()
        l.text          = "Enter your email to receive\na verification code."
        l.font          = .systemFont(ofSize: 16, weight: .medium)
        l.textColor     = .gray
        l.textAlignment = .center
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var emailField = DarkCapsuleTextField(placeholder: "Email address", iconName: "envelope")
    private lazy var codeField  = DarkCapsuleTextField(placeholder: "Verification Code", iconName: "key.fill")
    private lazy var passField  = DarkCapsuleTextField(placeholder: "New Password", iconName: "lock.fill", isSecure: true)
    
    private lazy var actionButton = LiquidGlassActionButton(title: "Send Code")
    private var isStepTwo = false
    private var currentEmail = ""

    // MARK: - Жизненный цикл
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        setupViewModel()
        
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        actionButton.addTarget(self, action: #selector(handleAction), for: .touchUpInside)
        
        codeField.isHidden = true
        passField.isHidden = true
        codeField.alpha = 0
        passField.alpha = 0
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // MARK: - Настройка верстки
    private func setupLayout() {
        [backButton, navTitleLabel, infoButton, titleLabel, detailLabel, emailField, codeField, passField, actionButton].forEach { view.addSubview($0) }
        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: safe.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            infoButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            infoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            infoButton.widthAnchor.constraint(equalToConstant: 44),
            infoButton.heightAnchor.constraint(equalToConstant: 44),
            
            navTitleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            navTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: navTitleLabel.bottomAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            detailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            emailField.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 32),
            emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            emailField.heightAnchor.constraint(equalToConstant: 54),

            codeField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 16),
            codeField.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            codeField.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            codeField.heightAnchor.constraint(equalToConstant: 54),

            passField.topAnchor.constraint(equalTo: codeField.bottomAnchor, constant: 16),
            passField.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            passField.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            passField.heightAnchor.constraint(equalToConstant: 54),

            actionButton.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            actionButton.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            actionButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        let constraint1 = actionButton.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 32)
        constraint1.priority = .defaultHigh
        constraint1.isActive = true
        
        let constraint2 = actionButton.topAnchor.constraint(equalTo: passField.bottomAnchor, constant: 32)
        constraint2.priority = .defaultLow
        constraint2.isActive = true
    }

    // MARK: - Связывание с ViewModel
    private func setupViewModel() {
        viewModel.onLoading = { [weak self] ld in 
            self?.actionButton.isEnabled = !ld
            self?.actionButton.showLoading(ld) 
        }
        viewModel.onError = { [weak self] msg in
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
        viewModel.onResetInitiated = { [weak self] email in
            self?.currentEmail = email
            self?.switchToStepTwo()
        }
        viewModel.onPasswordResetSuccess = { [weak self] in
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            let alert = UIAlertController(title: "Success", message: "Your password has been successfully reset.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Login", style: .default) { _ in self?.dismiss(animated: true) })
            self?.present(alert, animated: true)
        }
    }

    // MARK: - Переключение состояний
    private func switchToStepTwo() {
        guard !isStepTwo else { return }
        isStepTwo = true
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        // Обновление приоритетов констрейнтов для перемещения кнопки вниз
        view.constraints.forEach { c in
            if c.firstItem as? UIView == actionButton && c.firstAttribute == .top {
                if c.secondItem as? UIView == emailField {
                    c.priority = .defaultLow
                } else if c.secondItem as? UIView == passField {
                    c.priority = .defaultHigh
                }
            }
        }
        
        codeField.isHidden = false
        passField.isHidden = false

        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.emailField.alpha = 0.5
            self.emailField.isUserInteractionEnabled = false
            self.codeField.alpha = 1
            self.passField.alpha = 1
            
            self.detailLabel.text = "Check your email for the code\nand enter your new password."
            self.actionButton.setTitle("Reset Password") 
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Обработка событий
    @objc private func handleAction() {
        if isStepTwo {
            viewModel.completeReset(email: currentEmail, code: codeField.text ?? "", newPass: passField.text ?? "")
        } else {
            viewModel.initiateReset(email: emailField.text ?? "")
        }
    }

    @objc private func handleBack() { 
        dismiss(animated: true) 
    }
    
    @objc private func dismissKeyboard() { 
        view.endEditing(true) 
    }
}
