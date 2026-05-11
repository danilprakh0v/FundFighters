/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: LiquidGlassComponents.swift
Расположение: FundFighters.Client/Core/UI/
Назначение: Переиспользуемые UI-компоненты в стиле Liquid Glass.
===============================================================================
*/

import UIKit

// MARK: - Design Tokens
enum DT {
    static let accentGreen   = UIColor(red: 30/255,  green: 140/255, blue: 98/255,  alpha: 1)
    static let deepContrastGreen = UIColor(red: 15/255, green: 110/255, blue: 70/255, alpha: 1)
    static let glassGreen   = UIColor(red: 110/255, green: 184/255, blue: 151/255, alpha: 1)
    static let borderGray   = UIColor(red: 210/255, green: 212/255, blue: 218/255, alpha: 1)
    static let disabledGray = UIColor(red: 174/255, green: 178/255, blue: 185/255, alpha: 1)
    static let expenseRed   = UIColor(red: 235/255, green: 75/255, blue: 75/255, alpha: 1)
}

// MARK: - Liquid Glass Container
class LiquidGlassContainerView: UIView {
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
        accentBackground.backgroundColor = shadowColor == .clear ? tintColor.withAlphaComponent(1.0) : DT.accentGreen
        
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
    
    func updateColors(tint: UIColor, background: UIColor) {
        tintOverlay.backgroundColor = tint
        accentBackground.backgroundColor = background
    }
}

// MARK: - Liquid Glass Action Button
final class LiquidGlassActionButton: UIControl {
    private let glassContainer  = LiquidGlassContainerView()
    private let disabledCapsule = UIView()
    private let titleLabel      = UILabel()
    private var didLayout       = false
    private let baseColor       : UIColor
    
    private let infinityLoadingView = InfinityLoadingView()

    init(title: String, color: UIColor = DT.accentGreen) {
        self.baseColor = color
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

        titleLabel.font          = .systemFont(ofSize: 18, weight: .bold)
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
                tintColor: baseColor.withAlphaComponent(0.85),
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
    
    // Метод для визуального переключения состояния
    func setActive(_ isActive: Bool, activeColor: UIColor) {
        let tint = isActive ? activeColor.withAlphaComponent(0.85) : DT.disabledGray.withAlphaComponent(0.4)
        let bg = isActive ? activeColor : DT.disabledGray
        UIView.animate(withDuration: 0.3) {
            self.glassContainer.updateColors(tint: tint, background: bg)
            self.titleLabel.alpha = isActive ? 1.0 : 0.8
        }
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
