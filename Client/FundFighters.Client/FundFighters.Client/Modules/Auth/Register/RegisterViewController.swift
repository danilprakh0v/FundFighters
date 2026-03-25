/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: RegisterViewController.swift
Расположение: FundFighters.Client/FundFighters.Client/Modules/Auth/Register/
Назначение: UI/Логика компонента RegisterViewController.swift
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 04.02.2026
===============================================================================
*/

// RegistrationViewController.swift
import UIKit

// MARK: - Design Tokens
fileprivate enum DT {
    static let accentGreen  = UIColor(red: 30/255,  green: 140/255, blue: 98/255,  alpha: 1)
    static let deepContrastGreen = UIColor(red: 15/255, green: 110/255, blue: 70/255, alpha: 1)
    static let glassGreen   = UIColor(red: 110/255, green: 184/255, blue: 151/255, alpha: 1)
    static let borderGray   = UIColor(red: 210/255, green: 212/255, blue: 218/255, alpha: 1)
    static let pillDark     = UIColor(red: 58/255,  green: 60/255,  blue: 66/255,  alpha: 1)
    static let pillInactive = UIColor(red: 200/255, green: 200/255, blue: 208/255, alpha: 0.60)
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

// MARK: - Liquid Glass Capsule (prompt pill)
fileprivate final class LiquidGlassCapsule: LiquidGlassContainerView {
    private let label = UILabel()

    init(text: String, fontSize: CGFloat = 21) {
        super.init(frame: .zero)
        setupGlass(
            tintColor:     DT.glassGreen.withAlphaComponent(0.72),
            shadowColor:   DT.accentGreen,
            shadowOpacity: 0.38,
            shadowRadius:  18,
            shadowOffset:  CGSize(width: 0, height: 6),
            specularAlpha: 0.62,
            borderAlpha:   0.72
        )
        label.text          = text
        label.font          = .systemFont(ofSize: fontSize, weight: .bold)
        label.textColor     = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.shadowColor   = UIColor.black.cgColor
        label.layer.shadowOpacity = 0.22
        label.layer.shadowOffset  = CGSize(width: 0, height: 1)
        label.layer.shadowRadius  = 2
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

// MARK: - Subtitle Pill
fileprivate final class SubtitlePill: UIView {
    private let label = UILabel()

    init(text: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor    = DT.accentGreen
        layer.cornerRadius = 14
        layer.cornerCurve  = .continuous
        layer.shadowColor   = DT.accentGreen.cgColor
        layer.shadowOpacity = 0.55
        layer.shadowOffset  = .zero
        layer.shadowRadius  = 10

        label.text          = text
        label.font          = .systemFont(ofSize: 13, weight: .bold)
        label.textColor     = .white
        label.textAlignment = .center
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
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

// MARK: - Bordered Text Field
fileprivate final class BorderedTextField: UIView {
    let textField          = UITextField()
    private let titleLabel = UILabel()
    var text: String?      { textField.text }

    init(title: String, placeholder: String, icon: String? = nil, isSecure: Bool = false) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text      = title
        titleLabel.font      = .systemFont(ofSize: 13, weight: .medium)
        titleLabel.textColor = UIColor(red: 130/255, green: 130/255, blue: 138/255, alpha: 1)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        textField.attributedPlaceholder = NSAttributedString(string: placeholder,
            attributes: [.foregroundColor: UIColor.lightGray])
        textField.isSecureTextEntry   = isSecure
        textField.autocapitalizationType = .none
        textField.autocorrectionType  = .no
        textField.backgroundColor     = UIColor(white: 0.985, alpha: 1)
        textField.layer.cornerRadius  = 14
        textField.layer.cornerCurve   = .continuous
        textField.layer.borderWidth   = 1.2
        textField.layer.borderColor   = DT.borderGray.cgColor
        textField.layer.shadowColor   = UIColor.black.cgColor
        textField.layer.shadowOpacity = 0.07
        textField.layer.shadowOffset  = CGSize(width: 0, height: 2)
        textField.layer.shadowRadius  = 6
        textField.layer.masksToBounds = false
        textField.font                = .systemFont(ofSize: 16, weight: .medium)
        textField.translatesAutoresizingMaskIntoConstraints = false

        if let ic = icon {
            let iv = UIImageView(image: UIImage(systemName: ic))
            iv.tintColor   = UIColor(red: 160/255, green: 160/255, blue: 168/255, alpha: 1)
            iv.contentMode = .scaleAspectFit
            iv.frame       = CGRect(x: 16, y: 0, width: 20, height: 20)
            let cv         = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 20))
            cv.addSubview(iv)
            textField.leftView = cv
        } else {
            textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 20))
        }
        textField.leftViewMode = .always

        addSubview(titleLabel)
        addSubview(textField)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
            textField.heightAnchor.constraint(equalToConstant: 54)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - Password Strength
fileprivate final class AnimatedPasswordStrengthView: UIView {
    private let stack       = UIStackView()
    private let statusLabel = UILabel()
    private var segments:   [UIView] = []
    var currentScore: Int   = 0

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        stack.axis         = .horizontal
        stack.spacing      = 6
        stack.distribution = .fillEqually
        for _ in 0..<4 {
            let v = UIView()
            v.layer.cornerRadius = 3
            v.layer.cornerCurve  = .continuous
            v.backgroundColor    = DT.borderGray
            v.translatesAutoresizingMaskIntoConstraints = false
            v.heightAnchor.constraint(equalToConstant: 6).isActive = true
            v.widthAnchor.constraint(equalToConstant: 24).isActive = true
            stack.addArrangedSubview(v)
            segments.append(v)
        }
        let dash = UILabel()
        dash.text      = "————"
        dash.font      = .systemFont(ofSize: 12, weight: .bold)
        dash.textColor = .lightGray

        statusLabel.font      = .systemFont(ofSize: 14, weight: .bold)
        statusLabel.textColor = .black
        statusLabel.text      = "None"

        let container = UIStackView(arrangedSubviews: [stack, dash, statusLabel])
        container.axis      = .horizontal
        container.spacing   = 8
        container.alignment = .center
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            container.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func animateToScore(_ score: Int) {
        guard score != currentScore else { return }
        currentScore = score
        let color: UIColor; let text: String
        switch score {
        case 0...2: color = .systemRed;     text = "Weak"
        case 3...4: color = .systemYellow;  text = "Medium"
        default:    color = DT.accentGreen; text = "Strong"
        }
        UIView.transition(with: statusLabel, duration: 0.3, options: .transitionCrossDissolve) {
            self.statusLabel.text = text; self.statusLabel.textColor = color
        }
        UIView.animate(withDuration: 0.35, delay: 0,
                       usingSpringWithDamping: 0.75, initialSpringVelocity: 0.5) {
            for (i, seg) in self.segments.enumerated() {
                let fill = i < min(score, 4)
                seg.backgroundColor = fill ? color : DT.borderGray
                seg.transform = fill ? CGAffineTransform(scaleX: 1.12, y: 1.12) : .identity
            }
        } completion: { _ in
            UIView.animate(withDuration: 0.2) { self.segments.forEach { $0.transform = .identity } }
        }
    }
}

// MARK: - Email Validation
fileprivate struct EmailValidator {
    private static let blockedDomains: Set<String> = [
        "mailinator.com","guerrillamail.com","guerrillamail.net","guerrillamail.org",
        "guerrillamailblock.com","grr.la","spam4.me","trashmail.com","trashmail.me",
        "trashmail.net","trashmail.at","trashmail.io","trashmail.xyz","yopmail.com",
        "yopmail.fr","cool.fr.nf","jetable.fr.nf","nospam.ze.tc","nomail.xl.cx",
        "mega.zik.dj","speed.1s.fr","courriel.fr.nf","moncourrier.fr.nf","monemail.fr.nf",
        "monmail.fr.nf","dispostable.com","mailnull.com","maildrop.cc","tempr.email",
        "tempmail.com","temp-mail.org","fakeinbox.com","throwam.com","throwam.net",
        "sharklasers.com","guerrillamail.info","mintemail.com","cfl.fr","discard.email",
        "spamgourmet.com","spamgourmet.net","spamgourmet.org","spamspot.com",
        "spamthis.co.uk","spamtraps.nl","mt2015.com","mt2014.com",
        "inoutmail.eu","inoutmail.info","inoutmail.net","inoutmail.de",
        "bobmail.info","chammy.info","devnullmail.com","letthemeatspam.com",
        "put2.net","somenums.net","mailnew.com","binkmail.com",
        "mytempemail.com","spamevader.com","trbvm.com",
        "10minutemail.com","20minutemail.com","throwaway.email"
    ]

    static func validate(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !trimmed.contains(" ") else { return false }
        let parts = trimmed.components(separatedBy: "@")
        guard parts.count == 2 else { return false }
        let local = parts[0], domain = parts[1]
        guard !local.isEmpty, local.count <= 64,
              !local.hasPrefix("."), !local.hasSuffix("."), !local.contains("..") else { return false }
        let localAllowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "!#$%&'*+/=?^_`{|}~.-"))
        guard local.unicodeScalars.allSatisfy({ localAllowed.contains($0) }) else { return false }
        let domainParts = domain.components(separatedBy: ".")
        guard domainParts.count >= 2, !domain.hasPrefix("."), !domain.hasSuffix("."),
              !domain.hasPrefix("-"), !domain.hasSuffix("-") else { return false }
        let partAllowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-"))
        for part in domainParts {
            guard !part.isEmpty, !part.hasPrefix("-"), !part.hasSuffix("-"),
                  part.unicodeScalars.allSatisfy({ partAllowed.contains($0) }) else { return false }
        }
        let tld = domainParts.last!.lowercased()
        guard tld.count >= 2, tld.unicodeScalars.allSatisfy({ CharacterSet.letters.contains($0) }),
              trimmed.count <= 254 else { return false }
        return !blockedDomains.contains(domain.lowercased())
    }
}

// MARK: - Session & Protocol
final class RegistrationSession {
    var username = "", firstName = "", lastName = "", email = "", password = ""
}

protocol RegistrationStepDelegate: AnyObject {
    func didCompleteStep(index: Int)
    func canAdvance(from index: Int) -> Bool
}

// MARK: - Registration Container
final class RegistrationContainerViewController: UIViewController {
    let session = RegistrationSession()
    private lazy var backButton = GreenCircleButton(iconName: "chevron.left")
    private lazy var infoButton = GreenCircleButton(iconName: "info")
    private let viewModel = RegisterViewModel()


    var initialPillOffset: Int = 0
    weak var loginSourceViewController: LoginViewController?

    private let navTitleLabel: UILabel = {
        let l = UILabel()
        l.text          = "FundFighters"
        l.font          = .systemFont(ofSize: 42, weight: .heavy)
        l.textColor     = .black
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let paginationStack: UIStackView = {
        let s = UIStackView()
        s.axis      = .horizontal
        s.spacing   = 10
        s.alignment = .center
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private var pillViews:  [LiquidGlassPaginationPill] = []
    private var pillWidths: [NSLayoutConstraint]        = []

    private lazy var pageController: UIPageViewController = {
        let pc = UIPageViewController(transitionStyle: .scroll,
                                      navigationOrientation: .horizontal, options: nil)
        pc.view.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()

    private var stepControllers: [RegistrationStepViewController] = []

    private var currentIndex: Int = 0 {
        didSet { updatePagination(to: currentIndex + initialPillOffset) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        stepControllers = [
            RegisterNameViewController(session: session),
            RegisterEmailViewController(session: session),
            RegisterPasswordViewController(session: session)
        ]
        for (i, step) in stepControllers.enumerated() {
            step.stepIndex = i
            step.delegate  = self
        }
        setupLayout()
        buildPagination()
        pageController.setViewControllers([stepControllers[0]], direction: .forward, animated: false)
        pageController.delegate   = self
        pageController.dataSource = self
        setupViewModel()
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
    }

    private func setupViewModel() {
        viewModel.onLoading = { [weak self] isLoading in
            DispatchQueue.main.async {
                self?.view.isUserInteractionEnabled = !isLoading
                if let currentStep = self?.pageController.viewControllers?.first as? RegistrationStepViewController {
                    currentStep.showLoading(isLoading)
                }
            }
        }

        
        viewModel.onError = { [weak self] message in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Registration Error", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
        
        viewModel.onRegisterSuccess = { [weak self] in
            DispatchQueue.main.async {
                self?.proceedToVerification()
            }
        }
    }

    private func proceedToVerification() {
        activateFinalPill()
        
        // Небольшая задержка чтобы пилюля успела загореться до перехода
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) { [weak self] in
            guard let self = self else { return }
            let email = self.session.email.isEmpty ? "user@mail.com" : self.session.email
            let vc    = UniversalVerificationViewController(
                type:        .emailRegistration,
                targetEmail: email
            )
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle   = .crossDissolve
            self.present(vc, animated: true)
        }
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed {
            loginSourceViewController?.animatePillTransitionBackToLogin()
        }
    }

    private func setupLayout() {
        addChild(pageController)
        view.addSubview(pageController.view)
        pageController.didMove(toParent: self)
        [backButton, navTitleLabel, infoButton, paginationStack].forEach { view.addSubview($0) }

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

            pageController.view.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 10),
            pageController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageController.view.bottomAnchor.constraint(equalTo: paginationStack.topAnchor, constant: -12),

            paginationStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
            paginationStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            paginationStack.heightAnchor.constraint(equalToConstant: 18)
        ])
    }

    private func buildPagination() {
        for i in 0..<4 {
            let pill     = LiquidGlassPaginationPill()
            let isActive = (i == initialPillOffset)
            let w        = pill.widthAnchor.constraint(equalToConstant: isActive ? 70 : 42)
            w.isActive   = true
            pillWidths.append(w)
            pill.heightAnchor.constraint(equalToConstant: 18).isActive = true
            pill.apply(active: isActive, animated: false)
            pillViews.append(pill)
            paginationStack.addArrangedSubview(pill)
        }
    }

    private func updatePagination(to absoluteIndex: Int) {
        for (i, pill) in pillViews.enumerated() {
            let active = (i == absoluteIndex)
            pillWidths[i].constant = active ? 70 : 42
            pill.apply(active: active, animated: true)
        }
        UIView.animate(withDuration: 0.38, delay: 0,
                       usingSpringWithDamping: 0.78, initialSpringVelocity: 0.4,
                       options: .curveEaseInOut) { self.view.layoutIfNeeded() }
    }

    /// Активирует 4-ю пилюлю (индекс 3) — вызывается перед переходом на Verification
    func activateFinalPill() {
        guard pillViews.count == 4 else { return }
        pillWidths[3].constant = 70
        pillViews[3].apply(active: true, animated: true)
        UIView.animate(withDuration: 0.38, delay: 0,
                       usingSpringWithDamping: 0.78, initialSpringVelocity: 0.4,
                       options: .curveEaseInOut) { self.view.layoutIfNeeded() }
    }

    @objc private func handleBack() { dismiss(animated: true) }
}

// MARK: - Page Controller + Step Delegate
extension RegistrationContainerViewController: UIPageViewControllerDelegate,
                                               UIPageViewControllerDataSource,
                                               RegistrationStepDelegate {

    func pageViewController(_ pvc: UIPageViewController,
                            viewControllerBefore vc: UIViewController) -> UIViewController? {
        guard let s = vc as? RegistrationStepViewController, s.stepIndex > 0 else { return nil }
        return stepControllers[s.stepIndex - 1]
    }

    func pageViewController(_ pvc: UIPageViewController,
                            viewControllerAfter vc: UIViewController) -> UIViewController? {
        guard let s = vc as? RegistrationStepViewController,
              s.stepIndex < stepControllers.count - 1,
              canAdvance(from: s.stepIndex) else { return nil }
        return stepControllers[s.stepIndex + 1]
    }

    func pageViewController(_ pvc: UIPageViewController, didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        if completed, let c = pvc.viewControllers?.first as? RegistrationStepViewController {
            currentIndex = c.stepIndex
        }
    }

    func canAdvance(from index: Int) -> Bool { stepControllers[index].isValid }

    func didCompleteStep(index: Int) {
        if index < stepControllers.count - 1 {
            // Промежуточные шаги — плавный переход с снапшотом
            let nextVC   = stepControllers[index + 1]
            let oldVC    = stepControllers[index]
            let snapshot = oldVC.view.snapshotView(afterScreenUpdates: false)

            pageController.setViewControllers([nextVC], direction: .forward, animated: false)
            currentIndex = index + 1

            if let snapshot = snapshot {
                snapshot.frame = view.convert(pageController.view.frame, from: view)
                view.addSubview(snapshot)
                UIView.animate(withDuration: 0.34, delay: 0, options: .curveEaseInOut) {
                    snapshot.alpha = 0
                } completion: { _ in
                    snapshot.removeFromSuperview()
                }
            }
        } else {
            // Последний шаг (Proceed!)
            viewModel.register(
                username: session.username,
                email: session.email,
                password: session.password
            )
        }
    }
}


// MARK: - Convenience init
extension RegistrationContainerViewController {
    convenience init(startPillIndex: Int) {
        self.init()
        self.initialPillOffset = startPillIndex
    }
}

// MARK: - Base Step VC
class RegistrationStepViewController: UIViewController {
    let session:   RegistrationSession
    var stepIndex: Int = 0
    weak var delegate: RegistrationStepDelegate?
    var isValid: Bool { false }

    let contentStack: UIStackView = {
        let s = UIStackView()
        s.axis    = .vertical
        s.spacing = 16
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    fileprivate lazy var continueButton: LiquidGlassActionButton = {
        let btn = LiquidGlassActionButton(title: "Continue")
        btn.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        return btn
    }()

    init(session: RegistrationSession) {
        self.session = session
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    func setupHeaders(subtitle: String, title: String, prompt: String) {
        view.backgroundColor = .clear

        let subPill    = SubtitlePill(text: subtitle)
        let titleLabel = UILabel()
        titleLabel.text          = title
        titleLabel.font          = .systemFont(ofSize: 30, weight: .bold)
        titleLabel.textColor     = .black
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let promptPill = LiquidGlassCapsule(text: prompt, fontSize: 21)

        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(subPill)
        NSLayoutConstraint.activate([
            subPill.centerXAnchor.constraint(equalTo: wrapper.centerXAnchor),
            subPill.topAnchor.constraint(equalTo: wrapper.topAnchor),
            subPill.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor)
        ])

        let topStack = UIStackView(arrangedSubviews: [wrapper, titleLabel, promptPill])
        topStack.axis    = .vertical
        topStack.spacing = 20
        topStack.translatesAutoresizingMaskIntoConstraints = false

        [topStack, contentStack, continueButton].forEach { view.addSubview($0) }

        NSLayoutConstraint.activate([
            promptPill.heightAnchor.constraint(equalToConstant: 56),
            topStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            topStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            topStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            contentStack.topAnchor.constraint(equalTo: topStack.bottomAnchor, constant: 32),
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            continueButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            continueButton.heightAnchor.constraint(equalToConstant: 56)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissK))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        evaluateValidation()
    }

    @objc func handleContinue() { delegate?.didCompleteStep(index: stepIndex) }
    @objc private func dismissK() { view.endEditing(true) }
    func evaluateValidation() { continueButton.isEnabled = isValid }
    
    func showLoading(_ show: Bool) {
        continueButton.showLoading(show)
    }
}


// MARK: - Step: Name
final class RegisterNameViewController: RegistrationStepViewController {
    private let uField = BorderedTextField(title: "Username", placeholder: "Corvo_Attano...", icon: "person")
    private let fField = BorderedTextField(title: "First Name", placeholder: "Corvo")
    private let lField = BorderedTextField(title: "Last Name", placeholder: "Attano")

    override var isValid: Bool {
        (uField.text?.count ?? 0) >= 3 &&
        !(fField.text?.isEmpty ?? true) &&
        !(lField.text?.isEmpty ?? true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeaders(subtitle: "Get your money on a flow with your own desire",
                     title: "Let's get to\nknow you first.",
                     prompt: "What should we call you?")
        [uField, fField, lField].forEach {
            contentStack.addArrangedSubview($0)
            $0.textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        }
    }

    @objc private func textChanged() {
        session.username  = uField.text ?? ""
        session.firstName = fField.text ?? ""
        session.lastName  = lField.text ?? ""
        evaluateValidation()
    }
}

// MARK: - Step: Email
final class RegisterEmailViewController: RegistrationStepViewController {
    private let eField = BorderedTextField(title: "Email", placeholder: "corvo-attano@gmail.com", icon: "envelope")

    override var isValid: Bool { EmailValidator.validate(eField.text ?? "") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeaders(subtitle: "Your financial glow-up starts here",
                     title: "Few things until\nwe get down to Business.",
                     prompt: "What is your email?")
        eField.textField.keyboardType           = .emailAddress
        eField.textField.autocapitalizationType = .none
        eField.textField.autocorrectionType     = .no
        contentStack.addArrangedSubview(eField)
        eField.textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
    }

    @objc private func textChanged() {
        session.email = eField.text ?? ""
        evaluateValidation()
    }
}

// MARK: - Step: Password
final class RegisterPasswordViewController: RegistrationStepViewController {
    private let pField            = BorderedTextField(title: "Set Password", placeholder: "**********", icon: "lock.fill", isSecure: true)
    private let strengthIndicator = AnimatedPasswordStrengthView()

    private let criteriaLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines  = 0
        l.font           = .systemFont(ofSize: 14)
        l.textColor      = .darkGray
        let style        = NSMutableParagraphStyle()
        style.lineSpacing = 6
        l.attributedText = NSAttributedString(string: """
            Your password must meet the following criteria:
            • At least 8 characters long
            • Contains at least one uppercase letter (A-Z)
            • Contains at least one lowercase letter (a-z)
            • Contains at least one number (0-9)
            • Contains at least one special character (!@#$%^&*_-+=?)
            • Does not contain spaces
            • Does not include your name or email
            """, attributes: [.paragraphStyle: style])
        return l
    }()

    override var isValid: Bool { strengthIndicator.currentScore >= 4 }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeaders(subtitle: "Unlock your wealth mindset",
                     title: "Last, but not least -\nlet's make it official.",
                     prompt: "Enter your password")
        continueButton.setTitle("Proceed!", for: .normal)

        let eyeContainer = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        let eyeButton    = UIButton(type: .system)
        eyeButton.setImage(UIImage(systemName: "eye.slash.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)), for: .normal)
        eyeButton.tintColor = .lightGray
        eyeButton.frame     = CGRect(x: -12, y: 0, width: 44, height: 44)
        eyeButton.addTarget(self, action: #selector(toggleEye(_:)), for: .touchUpInside)
        eyeContainer.addSubview(eyeButton)
        pField.textField.rightView     = eyeContainer
        pField.textField.rightViewMode = .always

        [pField, strengthIndicator, criteriaLabel].forEach { contentStack.addArrangedSubview($0) }
        pField.textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
    }

    @objc private func toggleEye(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        pField.textField.isSecureTextEntry.toggle()
        let icon = pField.textField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
        sender.setImage(UIImage(systemName: icon,
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)), for: .normal)
    }

    @objc private func textChanged() {
        let txt = pField.text ?? ""
        session.password = txt
        var score = 0
        if txt.count >= 8                                              { score += 1 }
        if txt.rangeOfCharacter(from: .uppercaseLetters) != nil        { score += 1 }
        if txt.rangeOfCharacter(from: .lowercaseLetters) != nil        { score += 1 }
        if txt.rangeOfCharacter(from: .decimalDigits)    != nil        { score += 1 }
        if txt.rangeOfCharacter(from: .punctuationCharacters) != nil ||
           txt.rangeOfCharacter(from: .symbols) != nil                 { score += 1 }
        strengthIndicator.animateToScore(score)
        evaluateValidation()
    }
}
