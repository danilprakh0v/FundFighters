/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: ForgotPasswordViewController.swift
Расположение: FundFighters.Client/FundFighters.Client/Modules/Auth/ForgotPassword/
Назначение: UI/Логика компонента ForgotPasswordViewController.swift
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 04.02.2026
===============================================================================
*/

import UIKit

// MARK: - Design Tokens
fileprivate enum DT {
    static let accentGreen  = UIColor(red: 30/255,  green: 140/255, blue: 98/255,  alpha: 1)
    static let deepContrastGreen = UIColor(red: 15/255, green: 110/255, blue: 70/255, alpha: 1)
    static let glassGreen   = UIColor(red: 110/255, green: 184/255, blue: 151/255, alpha: 1)
    static let borderGray   = UIColor(red: 210/255, green: 212/255, blue: 218/255, alpha: 1)
    static let disabledGray = UIColor(red: 174/255, green: 178/255, blue: 185/255, alpha: 1)
}

// MARK: - Liquid Glass Container (base)
fileprivate class LiquidGlassContainerView: UIView {
    private(set) var tintOverlay = UIView()
    private let blurContainer    = UIView()
    private let accentBackground = UIView()
    private let specularGradient = CAGradientLayer()
    private let innerGlowLayer   = CAGradientLayer()
    private var didSetup         = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
    }
    required init?(coder: NSCoder) { fatalError() }

    func setupGlass(tintColor: UIColor = DT.glassGreen.withAlphaComponent(0.65),
                    shadowColor: UIColor = DT.glassGreen,
                    shadowOpacity: Float = 0.30,
                    shadowRadius: CGFloat = 14,
                    shadowOffset: CGSize = CGSize(width: 0, height: 6),
                    specularAlpha: CGFloat = 0.60,
                    borderAlpha: CGFloat = 0.70) {
        guard !didSetup else { return }
        didSetup = true
        layer.shadowColor   = shadowColor.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset  = shadowOffset
        layer.shadowRadius  = shadowRadius

        accentBackground.translatesAutoresizingMaskIntoConstraints = false
        accentBackground.backgroundColor = DT.accentGreen
        blurContainer.translatesAutoresizingMaskIntoConstraints = false
        blurContainer.clipsToBounds = true

        specularGradient.colors     = [UIColor.white.withAlphaComponent(specularAlpha).cgColor,
                                       UIColor.white.withAlphaComponent(0).cgColor]
        specularGradient.locations  = [0.0, 0.50]
        specularGradient.startPoint = CGPoint(x: 0.5, y: 0)
        specularGradient.endPoint   = CGPoint(x: 0.5, y: 1)

        innerGlowLayer.colors     = [UIColor.white.withAlphaComponent(0.15).cgColor,
                                     UIColor.clear.cgColor,
                                     UIColor.white.withAlphaComponent(0.08).cgColor]
        innerGlowLayer.locations  = [0.0, 0.4, 1.0]
        innerGlowLayer.startPoint = CGPoint(x: 0, y: 0)
        innerGlowLayer.endPoint   = CGPoint(x: 1, y: 1)

        let vev = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        vev.translatesAutoresizingMaskIntoConstraints = false
        vev.clipsToBounds     = true
        vev.layer.borderWidth = 1.5
        vev.layer.borderColor = UIColor.white.withAlphaComponent(borderAlpha).cgColor
        blurContainer.addSubview(vev)
        pinEdges(vev, to: blurContainer)

        tintOverlay.translatesAutoresizingMaskIntoConstraints = false
        tintOverlay.backgroundColor = tintColor
        vev.contentView.addSubview(tintOverlay)
        pinEdges(tintOverlay, to: vev.contentView)
        vev.contentView.layer.addSublayer(specularGradient)
        vev.contentView.layer.addSublayer(innerGlowLayer)

        insertSubview(accentBackground, at: 0)
        insertSubview(blurContainer, aboveSubview: accentBackground)
        pinEdges(blurContainer, to: self)
        pinEdges(accentBackground, to: self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let r = bounds.height / 2
        accentBackground.layer.cornerRadius = r
        accentBackground.layer.cornerCurve  = .continuous
        blurContainer.layer.cornerRadius    = r
        blurContainer.layer.cornerCurve     = .continuous
        if let ev = blurContainer.subviews.first as? UIVisualEffectView {
            ev.layer.cornerRadius         = r
            ev.layer.cornerCurve          = .continuous
            specularGradient.frame        = ev.contentView.bounds
            specularGradient.cornerRadius = r
            innerGlowLayer.frame          = ev.contentView.bounds
            innerGlowLayer.cornerRadius   = r
        }
    }

    func pinEdges(_ child: UIView, to parent: UIView) {
        NSLayoutConstraint.activate([
            child.topAnchor.constraint(equalTo: parent.topAnchor),
            child.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
            child.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            child.trailingAnchor.constraint(equalTo: parent.trailingAnchor)
        ])
    }
}

// MARK: - Liquid Glass Action Button
fileprivate final class LiquidGlassActionButton: UIControl {
    private let glassContainer  = LiquidGlassContainerView()
    private let disabledCapsule = UIView()
    private let titleLabel      = UILabel()
    private var didLayout       = false

    init(title: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        disabledCapsule.translatesAutoresizingMaskIntoConstraints = false
        disabledCapsule.backgroundColor = DT.disabledGray
        addSubview(disabledCapsule)
        NSLayoutConstraint.activate([
            disabledCapsule.topAnchor.constraint(equalTo: topAnchor),
            disabledCapsule.bottomAnchor.constraint(equalTo: bottomAnchor),
            disabledCapsule.leadingAnchor.constraint(equalTo: leadingAnchor),
            disabledCapsule.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        glassContainer.isUserInteractionEnabled = false
        addSubview(glassContainer)
        NSLayoutConstraint.activate([
            glassContainer.topAnchor.constraint(equalTo: topAnchor),
            glassContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            glassContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            glassContainer.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        titleLabel.font          = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor     = .white
        titleLabel.textAlignment = .center
        titleLabel.text          = title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.layer.shadowColor   = UIColor.black.cgColor
        titleLabel.layer.shadowOpacity = 0.18
        titleLabel.layer.shadowOffset  = CGSize(width: 0, height: 1)
        titleLabel.layer.shadowRadius  = 2
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20)
        ])

        addTarget(self, action: #selector(touchDown),     for: .touchDown)
        addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
        addTarget(self, action: #selector(touchCancel),   for: [.touchUpOutside, .touchCancel])
        
        infinityLoadingView.translatesAutoresizingMaskIntoConstraints = false
        infinityLoadingView.isHidden = true
        addSubview(infinityLoadingView)
        NSLayoutConstraint.activate([
            infinityLoadingView.centerXAnchor.constraint(equalTo: centerXAnchor),
            infinityLoadingView.centerYAnchor.constraint(equalTo: centerYAnchor),
            infinityLoadingView.widthAnchor.constraint(equalToConstant: 44),
            infinityLoadingView.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private let infinityLoadingView = InfinityLoadingView()


    override func layoutSubviews() {
        super.layoutSubviews()
        let r = bounds.height / 2
        disabledCapsule.layer.cornerRadius = r
        disabledCapsule.layer.cornerCurve  = .continuous
        if !didLayout, bounds.height > 0 {
            didLayout = true
            glassContainer.setupGlass(
                tintColor: DT.accentGreen.withAlphaComponent(0.85),
                shadowColor: .clear, shadowOpacity: 0, shadowRadius: 0, shadowOffset: .zero,
                specularAlpha: 0.55, borderAlpha: 0.60
            )
            layer.shadowColor   = UIColor.black.cgColor
            layer.shadowOpacity = 0.18

            layer.shadowOffset  = CGSize(width: 0, height: 4)
            layer.shadowRadius  = 12
            updateVisualState(animated: false)
        }
    }

    override var isEnabled: Bool {
        didSet { guard isEnabled != oldValue else { return }; updateVisualState(animated: true) }
    }

    private func updateVisualState(animated: Bool) {
        let change = {
            self.glassContainer.alpha  = self.isEnabled ? 1 : 0
            self.disabledCapsule.alpha = self.isEnabled ? 0 : 1
        }
        if animated {
            UIView.animate(withDuration: 0.28, delay: 0,
                           usingSpringWithDamping: 0.85, initialSpringVelocity: 0.2,
                           options: [.curveEaseInOut, .allowUserInteraction], animations: change)
        } else { change() }
    }

    func setTitle(_ title: String) {
        titleLabel.text = title
    }

    @objc private func touchDown() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        UIView.animate(withDuration: 0.12, delay: 0,
                       options: [.curveEaseIn, .allowUserInteraction, .beginFromCurrentState]) {
            self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            self.glassContainer.tintOverlay.alpha = 0.78
        }
    }
    @objc private func touchUpInside() { springBack() }
    @objc private func touchCancel()   { springBack() }
    private func springBack() {
        UIView.animate(withDuration: 0.36, delay: 0,
                       usingSpringWithDamping: 0.72, initialSpringVelocity: 0.3,
                       options: [.allowUserInteraction, .beginFromCurrentState]) {
            self.transform = .identity
            self.glassContainer.tintOverlay.alpha = 1.0
        }
    }

    func showLoading(_ show: Bool) {
        if show {
            infinityLoadingView.startAnimating()
            UIView.animate(withDuration: 0.3) {
                self.titleLabel.alpha = 0
            }
        } else {
            infinityLoadingView.stopAnimating()
            UIView.animate(withDuration: 0.3) {
                self.titleLabel.alpha = 1
            }
        }
    }
}

// MARK: - Dark Capsule Text Field
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

// MARK: - Green Circle Button
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

// MARK: - Controller
final class ForgotPasswordViewController: UIViewController {
    private let viewModel = ForgotPasswordViewModel()
    
    // UI Elements
    private lazy var backButton = GreenCircleButton(iconName: "chevron.left")
    private lazy var infoButton = GreenCircleButton(iconName: "info") // Missing before!
    
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
        
        // Critical fix: don't swallow button taps
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

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

            // Use flexible top spacing that adapts based on visible fields
            actionButton.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            actionButton.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            actionButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        // Dynamic constraint depending on step
        let constraint1 = actionButton.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 32)
        constraint1.priority = .defaultHigh
        constraint1.isActive = true
        
        let constraint2 = actionButton.topAnchor.constraint(equalTo: passField.bottomAnchor, constant: 32)
        constraint2.priority = .defaultLow
        constraint2.isActive = true
    }

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

    private func switchToStepTwo() {
        guard !isStepTwo else { return }
        isStepTwo = true
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        // Update constraints for the action button to move down
        if let constraints = view.constraints.filter({ $0.firstItem as? UIView == actionButton && $0.firstAttribute == .top }).first {
            // Find constraints
            view.constraints.forEach { c in
                if c.firstItem as? UIView == actionButton && c.firstAttribute == .top {
                    if c.secondItem as? UIView == emailField {
                        c.priority = .defaultLow
                    } else if c.secondItem as? UIView == passField {
                        c.priority = .defaultHigh
                    }
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
