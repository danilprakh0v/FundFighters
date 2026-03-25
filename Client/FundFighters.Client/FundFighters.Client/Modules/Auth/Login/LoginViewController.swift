/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: LoginViewController.swift
Расположение: FundFighters.Client/Modules/Auth/Login/
Назначение: User authentication screen (Login).
//              Экран входа пользователя в систему.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 04.02.2026
===============================================================================
*/
import UIKit

// MARK: - Design Tokens
fileprivate enum DT {
    static let accentGreen       = UIColor(red: 30/255,  green: 140/255, blue: 98/255,  alpha: 1)
    static let deepContrastGreen = UIColor(red: 15/255,  green: 110/255, blue: 70/255,  alpha: 1)
    static let glassGreen        = UIColor(red: 110/255, green: 184/255, blue: 151/255, alpha: 1)
    static let borderGray        = UIColor(red: 210/255, green: 212/255, blue: 218/255, alpha: 1)
    static let pillDark          = UIColor(red: 58/255,  green: 60/255,  blue: 66/255,  alpha: 1)
    static let pillInactive      = UIColor(red: 200/255, green: 200/255, blue: 208/255, alpha: 0.60)
    static let disabledGray      = UIColor(red: 174/255, green: 178/255, blue: 185/255, alpha: 1)
}

// MARK: - Liquid Glass Container
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

        let vev: UIVisualEffectView
        if #available(iOS 26.0, *) {
            vev = UIVisualEffectView(effect: UIGlassEffect())
        } else {
            vev = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        }
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
    private let infinityLoadingView = InfinityLoadingView()

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

    func setTitle(_ title: String, for state: UIControl.State = .normal) {
        if state == .normal { titleLabel.text = title }
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
            UIView.animate(withDuration: 0.3) { self.titleLabel.alpha = 0 }
        } else {
            infinityLoadingView.stopAnimating()
            UIView.animate(withDuration: 0.3) { self.titleLabel.alpha = 1 }
        }
    }
}

// MARK: - Liquid Glass Pagination Pill
fileprivate final class LiquidGlassPaginationPill: UIView {
    private let blurView  = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterialDark))
    private let tintLayer = UIView()
    private let specular  = CAGradientLayer()
    private var didSetup  = false

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupGlass()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupGlass() {
        guard !didSetup else { return }
        didSetup = true
        clipsToBounds = false

        let vev: UIVisualEffectView
        if #available(iOS 26.0, *) {
            vev = UIVisualEffectView(effect: UIGlassEffect())
        } else {
            vev = blurView
        }
        vev.translatesAutoresizingMaskIntoConstraints = false
        vev.clipsToBounds     = true
        vev.layer.borderWidth = 1.2
        vev.layer.borderColor = UIColor.white.withAlphaComponent(0.55).cgColor
        addSubview(vev)
        pin(vev)

        tintLayer.translatesAutoresizingMaskIntoConstraints = false
        tintLayer.backgroundColor = UIColor(white: 0.18, alpha: 0.72)
        vev.contentView.addSubview(tintLayer)
        pin(tintLayer, to: vev.contentView)
        vev.contentView.layer.addSublayer(specular)

        specular.colors     = [UIColor.white.withAlphaComponent(0.30).cgColor,
                               UIColor.white.withAlphaComponent(0).cgColor]
        specular.locations  = [0.0, 0.55]
        specular.startPoint = CGPoint(x: 0.5, y: 0)
        specular.endPoint   = CGPoint(x: 0.5, y: 1)

        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOpacity = 0.28
        layer.shadowOffset  = CGSize(width: 0, height: 3)
        layer.shadowRadius  = 8
    }

    func apply(active: Bool, animated: Bool = true) {
        let change = {
            self.tintLayer.backgroundColor = active
                ? UIColor(white: 0.18, alpha: 0.80)
                : UIColor(white: 0.82, alpha: 0.45)
            self.layer.shadowOpacity = active ? 0.30 : 0.12
            self.alpha = active ? 1.0 : 0.72
        }
        if animated {
            UIView.animate(withDuration: 0.38, delay: 0,
                           usingSpringWithDamping: 0.78, initialSpringVelocity: 0.4,
                           options: .curveEaseInOut, animations: change)
        } else { change() }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let r = bounds.height / 2
        layer.cornerRadius = r
        layer.cornerCurve  = .continuous
        if let ev = subviews.first as? UIVisualEffectView {
            ev.layer.cornerRadius = r
            ev.layer.cornerCurve  = .continuous
            specular.frame        = ev.contentView.bounds
            specular.cornerRadius = r
        }
    }

    private func pin(_ child: UIView) {
        NSLayoutConstraint.activate([
            child.topAnchor.constraint(equalTo: topAnchor),
            child.bottomAnchor.constraint(equalTo: bottomAnchor),
            child.leadingAnchor.constraint(equalTo: leadingAnchor),
            child.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    private func pin(_ child: UIView, to parent: UIView) {
        child.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            child.topAnchor.constraint(equalTo: parent.topAnchor),
            child.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
            child.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            child.trailingAnchor.constraint(equalTo: parent.trailingAnchor)
        ])
    }
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

// MARK: - Dark Capsule Text Field
fileprivate final class DarkCapsuleTextField: UITextField {
    init(placeholder: String, iconName: String, isSecure: Bool = false) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isSecureTextEntry      = isSecure
        autocapitalizationType = .none
        autocorrectionType     = .no
        backgroundColor        = .black
        layer.cornerRadius     = 14
        layer.cornerCurve      = .continuous
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

// MARK: - Soft Crossfade Animator
fileprivate final class SoftCrossfadePresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var midpointCallback: (() -> Void)?

    func transitionDuration(using ctx: UIViewControllerContextTransitioning?) -> TimeInterval { 0.46 }

    func animateTransition(using ctx: UIViewControllerContextTransitioning) {
        guard let toVC   = ctx.viewController(forKey: .to),
              let fromVC = ctx.viewController(forKey: .from) else {
            ctx.completeTransition(false); return
        }
        let container  = ctx.containerView
        let finalFrame = ctx.finalFrame(for: toVC)
        toVC.view.frame     = finalFrame
        toVC.view.alpha     = 0
        toVC.view.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        container.addSubview(toVC.view)

        DispatchQueue.main.asyncAfter(
            deadline: .now() + transitionDuration(using: ctx) * 0.42
        ) { self.midpointCallback?() }

        UIView.animate(
            withDuration: transitionDuration(using: ctx), delay: 0,
            usingSpringWithDamping: 0.94, initialSpringVelocity: 0.05,
            options: .curveEaseInOut
        ) {
            toVC.view.alpha       = 1
            toVC.view.transform   = .identity
            fromVC.view.alpha     = 0
            fromVC.view.transform = CGAffineTransform(scaleX: 1.015, y: 1.015)
        } completion: { _ in
            fromVC.view.alpha     = 1
            fromVC.view.transform = .identity
            ctx.completeTransition(!ctx.transitionWasCancelled)
        }
    }
}

// MARK: - LoginViewController
final class LoginViewController: UIViewController {

    private lazy var backButton = GreenCircleButton(iconName: "chevron.left")
    private lazy var infoButton = GreenCircleButton(iconName: "info")
    private let viewModel       = LoginViewModel()

    private let navTitleLabel: UILabel = {
        let l = UILabel()
        l.text          = "FundFighters"
        l.font          = .systemFont(ofSize: 42, weight: .heavy)
        l.textColor     = .black
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let logoBlurImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "logo_green_blur"))
        iv.contentMode = .scaleAspectFit
        iv.alpha       = 0.85
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let logoImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "logo_green"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let textGroupStack: UIStackView = {
        let s = UIStackView()
        s.axis      = .vertical
        s.spacing   = 8
        s.alignment = .center
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text          = "Sign in to your\nAccount"
        l.font          = .systemFont(ofSize: 34, weight: .bold)
        l.textColor     = .black
        l.textAlignment = .center
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var signUpLabel: UILabel = {
        let l = UILabel()
        l.attributedText           = makeSignUpString()
        l.textAlignment            = .center
        l.isUserInteractionEnabled = true
        l.translatesAutoresizingMaskIntoConstraints = false
        l.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleSignUpTapped)))
        return l
    }()

    private lazy var emailField    = DarkCapsuleTextField(placeholder: "Email address", iconName: "envelope")
    private lazy var passwordField = DarkCapsuleTextField(placeholder: "Password", iconName: "lock.fill", isSecure: true)
    private lazy var forgotButton: UIButton  = makeSmallTextButton(title: "Forgot Your Password?")
    private lazy var customLoginButton       = LiquidGlassActionButton(title: "Log In")
    private lazy var otherMethodsButton      = makeSmallTextButton(title: "Other methods")
    private lazy var googleButton = makeSocialButton(title: "Continue with Google",
                                                     iconImageName: "google_icon", systemFallback: nil)
    private lazy var appleButton  = makeSocialButton(title: "Continue with Apple",
                                                     iconImageName: "apple_icon", systemFallback: "applelogo")

    private let paginationStack: UIStackView = {
        let s = UIStackView()
        s.axis      = .horizontal
        s.spacing   = 10
        s.alignment = .center
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    private var pillViews:         [LiquidGlassPaginationPill] = []
    private var pillWidths:        [NSLayoutConstraint]        = []
    private var otherMethodsShown  = false
    private var presentAnimator:   SoftCrossfadePresentAnimator?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        googleButton.alpha     = 0
        appleButton.alpha      = 0
        googleButton.transform = CGAffineTransform(scaleX: 0.88, y: 0.88)
        appleButton.transform  = CGAffineTransform(scaleX: 0.88, y: 0.88)
        buildPagination()
        wireActions()
        setupViewModel()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // MARK: - ViewModel
    private func setupViewModel() {
        viewModel.onLoading = { [weak self] isLoading in
            DispatchQueue.main.async {
                self?.customLoginButton.isEnabled = !isLoading
                self?.customLoginButton.showLoading(isLoading)
            }
        }
        viewModel.onError = { [weak self] message in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
        // ✅ ИЗМЕНЕНО: DashboardViewControllerUIKit → MainTabBarController
        viewModel.onLoginSuccess = { [weak self] in
            DispatchQueue.main.async {
                guard let window = self?.view.window else { return }
                UIView.transition(with: window, duration: 0.6, options: .transitionCrossDissolve, animations: {
                    window.rootViewController = MainTabBarController()
                }, completion: nil)
            }
        }
        viewModel.onVerificationRequired = { [weak self] in
            DispatchQueue.main.async {
                self?.proceedToVerification(type: .loginConfirmation)
            }
        }
    }

    private func proceedToVerification(type: VerificationType) {
        let vc = UniversalVerificationViewController(type: type, targetEmail: emailField.text ?? "")
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle   = .crossDissolve
        present(vc, animated: true)
    }

    // MARK: - Layout
    private func setupLayout() {
        let sp: CGFloat = 24, gap: CGFloat = 8
        textGroupStack.addArrangedSubview(titleLabel)
        textGroupStack.addArrangedSubview(signUpLabel)

        [logoBlurImageView, logoImageView, backButton, navTitleLabel, infoButton,
         textGroupStack, emailField, passwordField, forgotButton,
         customLoginButton, otherMethodsButton, googleButton, appleButton, paginationStack
        ].forEach { view.addSubview($0) }
        view.sendSubviewToBack(logoBlurImageView)

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
            navTitleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 4),
            navTitleLabel.trailingAnchor.constraint(equalTo: infoButton.leadingAnchor, constant: -4),

            logoBlurImageView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 8),
            logoBlurImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoBlurImageView.widthAnchor.constraint(equalToConstant: 215),
            logoBlurImageView.heightAnchor.constraint(equalToConstant: 215),

            logoImageView.centerXAnchor.constraint(equalTo: logoBlurImageView.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: logoBlurImageView.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 210),
            logoImageView.heightAnchor.constraint(equalToConstant: 210),

            textGroupStack.topAnchor.constraint(equalTo: logoBlurImageView.bottomAnchor, constant: 4),
            textGroupStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sp),
            textGroupStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sp),

            emailField.topAnchor.constraint(equalTo: textGroupStack.bottomAnchor, constant: gap),
            emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sp),
            emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sp),
            emailField.heightAnchor.constraint(equalToConstant: 54),

            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: gap),
            passwordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sp),
            passwordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sp),
            passwordField.heightAnchor.constraint(equalToConstant: 54),

            forgotButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: gap),
            forgotButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            customLoginButton.topAnchor.constraint(equalTo: forgotButton.bottomAnchor, constant: gap),
            customLoginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sp),
            customLoginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sp),
            customLoginButton.heightAnchor.constraint(equalToConstant: 50),

            otherMethodsButton.topAnchor.constraint(equalTo: customLoginButton.bottomAnchor, constant: gap),
            otherMethodsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            googleButton.topAnchor.constraint(equalTo: otherMethodsButton.bottomAnchor, constant: gap),
            googleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sp),
            googleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sp),
            googleButton.heightAnchor.constraint(equalToConstant: 46),

            appleButton.topAnchor.constraint(equalTo: googleButton.bottomAnchor, constant: gap),
            appleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sp),
            appleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sp),
            appleButton.heightAnchor.constraint(equalToConstant: 46),

            paginationStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
            paginationStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            paginationStack.heightAnchor.constraint(equalToConstant: 18)
        ])
    }

    private func buildPagination() {
        for i in 0..<4 {
            let pill     = LiquidGlassPaginationPill()
            let isActive = (i == 0)
            let w        = pill.widthAnchor.constraint(equalToConstant: isActive ? 70 : 42)
            w.isActive   = true
            pillWidths.append(w)
            pill.heightAnchor.constraint(equalToConstant: 18).isActive = true
            pill.apply(active: isActive, animated: false)
            pillViews.append(pill)
            paginationStack.addArrangedSubview(pill)
        }
    }

    func animatePillTransitionToRegistration() {
        guard pillViews.count >= 2 else { return }
        pillWidths[0].constant = 42; pillWidths[1].constant = 70
        pillViews[0].apply(active: false, animated: true)
        pillViews[1].apply(active: true,  animated: true)
        UIView.animate(withDuration: 0.38, delay: 0,
                       usingSpringWithDamping: 0.78, initialSpringVelocity: 0.4,
                       options: .curveEaseInOut) { self.view.layoutIfNeeded() }
    }

    func animatePillTransitionBackToLogin() {
        guard pillViews.count >= 2 else { return }
        pillWidths[0].constant = 70; pillWidths[1].constant = 42
        pillViews[0].apply(active: true,  animated: true)
        pillViews[1].apply(active: false, animated: true)
        UIView.animate(withDuration: 0.38, delay: 0,
                       usingSpringWithDamping: 0.78, initialSpringVelocity: 0.4,
                       options: .curveEaseInOut) { self.view.layoutIfNeeded() }
    }

    private func wireActions() {
        backButton.addTarget(self,         action: #selector(handleBack),               for: .touchUpInside)
        infoButton.addTarget(self,         action: #selector(handleInfo),               for: .touchUpInside)
        forgotButton.addTarget(self,       action: #selector(handleForgotPassword),     for: .touchUpInside)
        customLoginButton.addTarget(self,  action: #selector(handleSignIn),             for: .touchUpInside)
        otherMethodsButton.addTarget(self, action: #selector(handleOtherMethodsTapped), for: .touchUpInside)
    }

    @objc private func handleOtherMethodsTapped() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        otherMethodsShown.toggle()
        let alpha: CGFloat = otherMethodsShown ? 1.0 : 0.0
        let scale: CGFloat = otherMethodsShown ? 1.0 : 0.88
        UIView.animate(withDuration: 0.42, delay: 0,
                       usingSpringWithDamping: 0.78, initialSpringVelocity: 0.6,
                       options: [.curveEaseOut, .allowUserInteraction]) {
            self.googleButton.alpha     = alpha; self.appleButton.alpha      = alpha
            self.googleButton.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.appleButton.transform  = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    @objc private func handleSignIn() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        viewModel.login(email: emailField.text, password: passwordField.text)
    }
    @objc private func handleForgotPassword() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let vc = ForgotPasswordViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle   = .crossDissolve
        present(vc, animated: true)
    }
    @objc private func handleSignUpTapped() {
        let animator = SoftCrossfadePresentAnimator()
        animator.midpointCallback = { [weak self] in self?.animatePillTransitionToRegistration() }
        self.presentAnimator = animator
        let vc = RegistrationContainerViewController(startPillIndex: 1)
        vc.loginSourceViewController = self
        vc.modalPresentationStyle    = .fullScreen
        vc.modalTransitionStyle      = .crossDissolve
        vc.transitioningDelegate     = self
        present(vc, animated: true)
    }
    @objc private func handleBack()      { dismiss(animated: true) }
    @objc private func handleInfo()      {}
    @objc private func dismissKeyboard() { view.endEditing(true) }

    private func makeSignUpString() -> NSAttributedString {
        let full = "Don't have an account?  •  Sign Up"
        let base = NSMutableAttributedString(string: full)
        let ns   = full as NSString
        let all  = NSRange(location: 0, length: full.utf16.count)
        base.addAttribute(.font,            value: UIFont.systemFont(ofSize: 15, weight: .medium), range: all)
        base.addAttribute(.foregroundColor, value: UIColor.black, range: all)
        for (str, color, wt): (String, UIColor, UIFont.Weight) in [
            ("•", DT.accentGreen, .medium), ("Sign Up", DT.accentGreen, .bold)
        ] {
            let r = ns.range(of: str)
            base.addAttribute(.foregroundColor, value: color, range: r)
            base.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: wt), range: r)
        }
        return base
    }
    private func makeSmallTextButton(title: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setAttributedTitle(NSAttributedString(string: title, attributes: [
            .font:           UIFont.systemFont(ofSize: 14, weight: .semibold),
            .foregroundColor: DT.accentGreen,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }
    private func makeSocialButton(title: String, iconImageName: String, systemFallback: String?) -> UIButton {
        var cfg = UIButton.Configuration.filled()
        cfg.title = title
        if let img = UIImage(named: iconImageName) {
            cfg.image = img.withConfiguration(UIImage.SymbolConfiguration(pointSize: 17))
        } else if let sys = systemFallback {
            cfg.image = UIImage(systemName: sys)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        }
        cfg.imagePadding        = 10
        cfg.imagePlacement      = .leading
        cfg.baseBackgroundColor = .black
        cfg.baseForegroundColor = .white
        cfg.background.cornerRadius = 13
        cfg.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { a in
            var b = a; b.font = .systemFont(ofSize: 15, weight: .semibold); return b
        }
        let btn = UIButton(configuration: cfg)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.shadowColor   = UIColor.black.cgColor
        btn.layer.shadowOpacity = 0.28
        btn.layer.shadowOffset  = CGSize(width: 0, height: 4)
        btn.layer.shadowRadius  = 8
        return btn
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension LoginViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentAnimator
    }
}
