/*
===============================================================================
Проект: FundFighters (iOS UIKit [Client])
Файл: VerificationViewController.swift
Расположение: Client/FundFighters.Client/FundFighters.Client/Modules/Auth/Verification/
Назначение: Экран верификации (подтверждения) email или входа.
            Осуществляет ввод и проверку 6-значного цифрового кода.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 04.02.2026
===============================================================================
*/

import UIKit

// MARK: - Liquid Glass Capsule (Информационная плашка)
fileprivate final class LiquidGlassCapsule: LiquidGlassContainerView {
    private let label = UILabel()
    init(text: String, fontSize: CGFloat = 21) {
        super.init(frame: .zero)
        setupGlass(tintColor: DT.glassGreen.withAlphaComponent(0.72),
                   shadowColor: DT.accentGreen, shadowOpacity: 0.38,
                   shadowRadius: 18, shadowOffset: CGSize(width: 0, height: 6),
                   specularAlpha: 0.62, borderAlpha: 0.72)
        label.text = text; label.font = .systemFont(ofSize: fontSize, weight: .bold)
        label.textColor = .white; label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.shadowColor = UIColor.black.cgColor; label.layer.shadowOpacity = 0.22
        label.layer.shadowOffset = CGSize(width: 0, height: 1); label.layer.shadowRadius = 2
        addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - Glass Success Overlay (Экран успешного завершения)
fileprivate final class GlassSuccessOverlay: UIView {
    private let backgroundDim  = UIView()
    private let glassContainer = LiquidGlassContainerView()
    private let checkmark      = UIImageView()
    private let titleLabel     = UILabel()
    private let messageLabel   = UILabel()

    init(title: String, message: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        alpha = 0
        backgroundDim.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        backgroundDim.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundDim)
        glassContainer.setupGlass(tintColor: DT.glassGreen.withAlphaComponent(0.92),
                                  shadowColor: DT.accentGreen, shadowOpacity: 0.4,
                                  shadowRadius: 20, specularAlpha: 0.6)
        addSubview(glassContainer)
        checkmark.image = UIImage(systemName: "checkmark.seal.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 62, weight: .bold))
        checkmark.tintColor = .white; checkmark.contentMode = .scaleAspectFit
        checkmark.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title; titleLabel.font = .systemFont(ofSize: 26, weight: .heavy)
        titleLabel.textColor = .white; titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = message; messageLabel.font = .systemFont(ofSize: 15, weight: .medium)
        messageLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        messageLabel.textAlignment = .center; messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        [checkmark, titleLabel, messageLabel].forEach { glassContainer.addSubview($0) }
        NSLayoutConstraint.activate([
            backgroundDim.topAnchor.constraint(equalTo: topAnchor),
            backgroundDim.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundDim.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundDim.trailingAnchor.constraint(equalTo: trailingAnchor),
            glassContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            glassContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            glassContainer.widthAnchor.constraint(equalToConstant: 280),
            glassContainer.heightAnchor.constraint(equalToConstant: 240),
            checkmark.centerXAnchor.constraint(equalTo: glassContainer.centerXAnchor),
            checkmark.topAnchor.constraint(equalTo: glassContainer.topAnchor, constant: 30),
            titleLabel.topAnchor.constraint(equalTo: checkmark.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: glassContainer.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: glassContainer.trailingAnchor, constant: -20),
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: glassContainer.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: glassContainer.trailingAnchor, constant: -20)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func show(in parent: UIView, completion: @escaping () -> Void) {
        parent.addSubview(self)
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: parent.topAnchor),
            bottomAnchor.constraint(equalTo: parent.bottomAnchor),
            leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            trailingAnchor.constraint(equalTo: parent.trailingAnchor)
        ])
        glassContainer.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.75,
                       initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.alpha = 1; self.glassContainer.transform = .identity
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                UIView.animate(withDuration: 0.4) {
                    self.alpha = 0
                    self.glassContainer.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                } completion: { _ in self.removeFromSuperview(); completion() }
            }
        }
    }
}

// MARK: - Liquid Glass Pagination Pill (Индикатор прогресса)
fileprivate final class LiquidGlassPaginationPill: UIView {
    private let blurView   = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
    private let tintLayer  = UIView()
    private let specular   = CAGradientLayer()
    private let inactiveBg = UIView()
    private var didSetup   = false

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupGlass()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupGlass() {
        guard !didSetup else { return }
        didSetup = true; clipsToBounds = false
        inactiveBg.translatesAutoresizingMaskIntoConstraints = false
        inactiveBg.backgroundColor = DT.disabledGray.withAlphaComponent(0.4)
        insertSubview(inactiveBg, at: 0); pin(inactiveBg)
        let vev = blurView
        vev.translatesAutoresizingMaskIntoConstraints = false; vev.clipsToBounds = true
        vev.layer.borderWidth = 1.2; vev.layer.borderColor = UIColor.white.withAlphaComponent(0.65).cgColor
        addSubview(vev); pin(vev)
        tintLayer.translatesAutoresizingMaskIntoConstraints = false
        tintLayer.backgroundColor = DT.glassGreen.withAlphaComponent(0.72)
        vev.contentView.addSubview(tintLayer); pin(tintLayer, to: vev.contentView)
        vev.contentView.layer.addSublayer(specular)
        specular.colors = [UIColor.white.withAlphaComponent(0.50).cgColor, UIColor.white.withAlphaComponent(0).cgColor]
        specular.locations = [0.0, 0.55]; specular.startPoint = CGPoint(x: 0.5, y: 0); specular.endPoint = CGPoint(x: 0.5, y: 1)
        layer.shadowColor = DT.accentGreen.cgColor; layer.shadowOpacity = 0.35
        layer.shadowOffset = CGSize(width: 0, height: 3); layer.shadowRadius = 6
        vev.alpha = 0
    }

    func apply(active: Bool, animated: Bool = true) {
        let glassView = subviews.first(where: { $0 is UIVisualEffectView })
        let change = {
            glassView?.alpha         = active ? 1 : 0
            self.inactiveBg.alpha    = active ? 0 : 1
            self.layer.shadowOpacity = active ? 0.35 : 0.0
            self.alpha               = 1.0
        }
        animated ? UIView.animate(withDuration: 0.42, delay: 0, usingSpringWithDamping: 0.80,
            initialSpringVelocity: 0.4, options: .curveEaseInOut, animations: change) : change()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let r = bounds.height / 2
        layer.cornerRadius = r; layer.cornerCurve = .continuous
        inactiveBg.layer.cornerRadius = r; inactiveBg.layer.cornerCurve = .continuous
        if let ev = subviews.first(where: { $0 is UIVisualEffectView }) as? UIVisualEffectView {
            ev.layer.cornerRadius = r; ev.layer.cornerCurve = .continuous
            specular.frame = ev.contentView.bounds; specular.cornerRadius = r
        }
    }
    private func pin(_ child: UIView) {
        NSLayoutConstraint.activate([
            child.topAnchor.constraint(equalTo: topAnchor), child.bottomAnchor.constraint(equalTo: bottomAnchor),
            child.leadingAnchor.constraint(equalTo: leadingAnchor), child.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    private func pin(_ child: UIView, to parent: UIView) {
        child.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            child.topAnchor.constraint(equalTo: parent.topAnchor), child.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
            child.leadingAnchor.constraint(equalTo: parent.leadingAnchor), child.trailingAnchor.constraint(equalTo: parent.trailingAnchor)
        ])
    }
}

// MARK: - Green Circle Button (Круглая кнопка)
fileprivate final class GreenCircleButton: UIButton {
    init(iconName: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = DT.accentGreen
        setImage(UIImage(systemName: iconName,
                         withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)), for: .normal)
        tintColor = .black
    }
    required init?(coder: NSCoder) { fatalError() }
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2; layer.cornerCurve = .continuous
    }
}

// MARK: - Verification Type
enum VerificationType { case emailRegistration, loginConfirmation }

// MARK: - UniversalVerificationViewController
final class UniversalVerificationViewController: UIViewController {

    let type:        VerificationType
    let targetEmail: String

    // Имя пользователя (передается при регистрации)
    var registeredUsername: String?

    private lazy var backButton = GreenCircleButton(iconName: "chevron.left")
    private lazy var infoButton = GreenCircleButton(iconName: "info")
    private let viewModel       = VerificationViewModel()

    private let navTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "FundFighters"; l.font = .systemFont(ofSize: 42, weight: .heavy)
        l.textColor = .black; l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var badgePill: UIView = {
        let v = UIView()
        v.backgroundColor = DT.accentGreen; v.layer.cornerRadius = 14; v.layer.cornerCurve = .continuous
        v.layer.shadowColor = DT.accentGreen.cgColor; v.layer.shadowOpacity = 0.4
        v.layer.shadowOffset = CGSize(width: 0, height: 4); v.layer.shadowRadius = 8
        v.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        label.text = "Control your budget freely"; label.font = .systemFont(ofSize: 13, weight: .bold)
        label.textColor = .white; label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: v.topAnchor, constant: 6),
            label.bottomAnchor.constraint(equalTo: v.bottomAnchor, constant: -6),
            label.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: -16)
        ])
        return v
    }()

    private lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.text = (type == .loginConfirmation) ? "Let's quickly\nconfirm your login" : "Let's quickly\nverify your email"
        l.font = .systemFont(ofSize: 30, weight: .bold); l.textColor = .black
        l.textAlignment = .center; l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let promptPill = LiquidGlassCapsule(text: "Enter your code", fontSize: 21)

    private lazy var codeField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "345123"; tf.textColor = DT.accentGreen
        tf.font = .systemFont(ofSize: 52, weight: .bold); tf.textAlignment = .center
        tf.backgroundColor = .white; tf.layer.borderWidth = 1.0
        tf.layer.borderColor = DT.borderGray.cgColor; tf.layer.cornerRadius = 16
        tf.layer.cornerCurve = .continuous; tf.keyboardType = .numberPad
        tf.translatesAutoresizingMaskIntoConstraints = false; tf.delegate = self
        return tf
    }()

    private lazy var confirmButton = LiquidGlassActionButton(title: "Confirm and Continue")

    private let paginationStack: UIStackView = {
        let s = UIStackView(); s.axis = .horizontal; s.spacing = 10; s.alignment = .center
        s.translatesAutoresizingMaskIntoConstraints = false; return s
    }()
    private var pillViews:  [LiquidGlassPaginationPill] = []
    private var pillWidths: [NSLayoutConstraint]        = []

    init(type: VerificationType, targetEmail: String) {
        self.type = type; self.targetEmail = targetEmail
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout(); buildPagination()
        confirmButton.addTarget(self, action: #selector(handleConfirm), for: .touchUpInside)
        backButton.addTarget(self,    action: #selector(handleBack),    for: .touchUpInside)
        setupViewModel()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false; view.addGestureRecognizer(tap)
        confirmButton.isEnabled = false
    }

    // MARK: - Связывание с ViewModel

    private func setupViewModel() {
        viewModel.onLoading = { [weak self] isLoading in
            DispatchQueue.main.async {
                self?.confirmButton.isEnabled = !isLoading
                self?.confirmButton.showLoading(isLoading)
            }
        }

        viewModel.onError = { [weak self] message in
            DispatchQueue.main.async {
                self?.shakeCodeField()
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                let alert = UIAlertController(title: "Verification Failed", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: .default))
                self?.present(alert, animated: true)
            }
        }

        viewModel.onVerificationSuccess = { [weak self] in
            DispatchQueue.main.async {
                guard let self else { return }

                // Определение финального имени пользователя для сессии
                let username: String = self.registeredUsername
                    ?? UserDefaults.standard.string(forKey: "pendingUsername")
                    ?? String(self.targetEmail.split(separator: "@").first ?? "Fighter")

                UserManager.shared.session.username = username
                UserDefaults.standard.set(username, forKey: "username")
                UserDefaults.standard.removeObject(forKey: "pendingUsername")

                self.animateFourthPillSuccess()
                UINotificationFeedbackGenerator().notificationOccurred(.success)

                let overlay = GlassSuccessOverlay(
                    title: "Success!",
                    message: "Your account has been\nsuccessfully authenticated.")
                overlay.show(in: self.view) {
                    guard let window = self.view.window else { return }
                    UIView.transition(
                        with: window,
                        duration: 0.6,
                        options: .transitionCrossDissolve,
                        animations: { window.rootViewController = MainTabBarController() },
                        completion: nil
                    )
                }
            }
        }
    }

    // MARK: - Настройка верстки

    private func setupLayout() {
        let safe = view.safeAreaLayoutGuide
        [backButton, navTitleLabel, infoButton, badgePill, titleLabel,
         promptPill, codeField, confirmButton, paginationStack].forEach { view.addSubview($0) }
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
            badgePill.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 16),
            badgePill.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: badgePill.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            promptPill.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            promptPill.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            promptPill.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            promptPill.heightAnchor.constraint(equalToConstant: 54),
            codeField.topAnchor.constraint(equalTo: promptPill.bottomAnchor, constant: 20),
            codeField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            codeField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            codeField.heightAnchor.constraint(equalToConstant: 80),
            paginationStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
            paginationStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            paginationStack.heightAnchor.constraint(equalToConstant: 18),
            confirmButton.bottomAnchor.constraint(equalTo: paginationStack.topAnchor, constant: -24),
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            confirmButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    private func buildPagination() {
        for i in 0..<4 {
            let pill = LiquidGlassPaginationPill()
            let isActive = i < 3
            let w = pill.widthAnchor.constraint(equalToConstant: isActive ? 70 : 42)
            w.isActive = true; pillWidths.append(w)
            pill.heightAnchor.constraint(equalToConstant: 18).isActive = true
            pill.alpha = 1; pill.apply(active: isActive, animated: false)
            pillViews.append(pill); paginationStack.addArrangedSubview(pill)
        }
    }

    private func animateFourthPillSuccess() {
        guard pillViews.count == 4 else { return }
        pillWidths[3].constant = 70
        UIView.animate(withDuration: 0.42, delay: 0, usingSpringWithDamping: 0.72,
                       initialSpringVelocity: 0.4, options: .curveEaseOut) {
            self.paginationStack.layoutIfNeeded()
        }
        pillViews[3].apply(active: true, animated: true)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    // MARK: - Обработка действий

    @objc private func handleConfirm() {
        guard confirmButton.isEnabled else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        viewModel.verify(email: targetEmail, code: codeField.text ?? "", type: type)
    }
    @objc private func handleBack()      { dismiss(animated: true) }
    @objc private func dismissKeyboard() { view.endEditing(true) }

    private func shakeCodeField() {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.42; animation.values = [0, -10, 10, -8, 8, -5, 5, 0]
        codeField.layer.add(animation, forKey: "shake")
        UIView.animate(withDuration: 0.15) {
            self.codeField.layer.borderColor = UIColor.systemRed.cgColor
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.codeField.layer.borderColor = DT.borderGray.cgColor
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension UniversalVerificationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let current = textField.text ?? ""
        guard let strRange = Range(range, in: current) else { return false }
        let updated = current.replacingCharacters(in: strRange, with: string)
        guard updated.count <= 6, updated.allSatisfy({ $0.isNumber }) || updated.isEmpty else { return false }
        DispatchQueue.main.async { self.confirmButton.isEnabled = (updated.count == 6) }
        return true
    }
}
