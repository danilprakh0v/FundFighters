/*
===============================================================================
Проект: FundFighters (iOS UIKit [Client/Backend Service])
Файл: BattleViewController.swift
Расположение: Client/FundFighters.Client/FundFighters.Client/Modules/Battle/
Назначение: Экран битвы — игровая визуализация процесса накопления средств
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 04.02.2026
===============================================================================
*/

import UIKit
import PhotosUI
import Photos

// MARK: - LightLiquidGlassContainerView (Светлый стеклянный контейнер)

fileprivate class LightLiquidGlassContainerView: UIView {
    private(set) var tintOverlay = UIView()
    private let blurContainer    = UIView()
    private let accentBackground = UIView()
    private let specularGradient = CAGradientLayer()
    private var didSetup         = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
    }
    required init?(coder: NSCoder) { fatalError() }

    // Настройка эффекта стекла
    func setupGlass() {
        guard !didSetup else { return }
        didSetup = true

        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowOffset  = CGSize(width: 0, height: 4)
        layer.shadowRadius  = 12

        accentBackground.translatesAutoresizingMaskIntoConstraints = false
        accentBackground.backgroundColor = UIColor.white.withAlphaComponent(0.2)

        blurContainer.translatesAutoresizingMaskIntoConstraints = false
        blurContainer.clipsToBounds = true

        specularGradient.colors     = [UIColor.white.withAlphaComponent(0.8).cgColor,
                                       UIColor.white.withAlphaComponent(0.0).cgColor]
        specularGradient.locations  = [0.0, 0.6]
        specularGradient.startPoint = CGPoint(x: 0.3, y: 0)
        specularGradient.endPoint   = CGPoint(x: 0.7, y: 1)

        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        let vev = UIVisualEffectView(effect: blurEffect)
        vev.translatesAutoresizingMaskIntoConstraints = false
        vev.clipsToBounds     = true
        vev.layer.borderWidth = 1.2
        vev.layer.borderColor = UIColor.white.withAlphaComponent(0.9).cgColor

        blurContainer.addSubview(vev)
        pinEdges(vev, to: blurContainer)

        tintOverlay.translatesAutoresizingMaskIntoConstraints = false
        tintOverlay.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        vev.contentView.addSubview(tintOverlay)
        pinEdges(tintOverlay, to: vev.contentView)
        vev.contentView.layer.addSublayer(specularGradient)

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
        }
    }

    private func pinEdges(_ child: UIView, to parent: UIView) {
        NSLayoutConstraint.activate([
            child.topAnchor.constraint(equalTo: parent.topAnchor),
            child.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
            child.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            child.trailingAnchor.constraint(equalTo: parent.trailingAnchor)
        ])
    }
}

// MARK: - GlassCircleButton (Стеклянная круглая кнопка)

fileprivate final class GlassCircleButton: UIControl {
    private let glassContainer = LightLiquidGlassContainerView()
    private let iconImageView = UIImageView()
    private let badgeView = UIView()
    private var didLayout = false

    init(iconName: String, iconColor: UIColor, hasBadge: Bool = false) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        glassContainer.isUserInteractionEnabled = false
        addSubview(glassContainer)

        iconImageView.image = UIImage(systemName: iconName, withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold))
        iconImageView.tintColor = iconColor
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconImageView)

        badgeView.backgroundColor = UIColor(red: 160/255, green: 160/255, blue: 165/255, alpha: 1)
        badgeView.layer.borderColor = UIColor.white.cgColor
        badgeView.layer.borderWidth = 2.0
        badgeView.isHidden = !hasBadge
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(badgeView)

        NSLayoutConstraint.activate([
            glassContainer.topAnchor.constraint(equalTo: topAnchor),
            glassContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            glassContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            glassContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            badgeView.topAnchor.constraint(equalTo: topAnchor, constant: 1),
            badgeView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1),
            badgeView.widthAnchor.constraint(equalToConstant: 12),
            badgeView.heightAnchor.constraint(equalToConstant: 12)
        ])

        addTarget(self, action: #selector(touchDown), for: .touchDown)
        addTarget(self, action: #selector(touchCancel), for: [.touchUpOutside, .touchCancel, .touchUpInside])
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        badgeView.layer.cornerRadius = badgeView.bounds.height / 2
        if !didLayout, bounds.height > 0 {
            didLayout = true
            glassContainer.setupGlass()
        }
    }

    @objc private func touchDown() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseIn, .allowUserInteraction]) {
            self.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
            self.glassContainer.tintOverlay.alpha = 0.8
        }
    }

    @objc private func touchCancel() {
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [.allowUserInteraction]) {
            self.transform = .identity
            self.glassContainer.tintOverlay.alpha = 1.0
        }
    }
}

// MARK: - BattleLiquidActionButton

fileprivate final class BattleLiquidActionButton: UIControl {
    private let glassContainer = LiquidGlassContainerView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let baseColor: UIColor
    private var didLayout = false

    init(title: String, iconName: String, color: UIColor) {
        self.baseColor = color
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        glassContainer.isUserInteractionEnabled = false
        addSubview(glassContainer)

        iconView.image = Self.iconImage(named: iconName)
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = title
        titleLabel.font = DS.golosBold(17)
        titleLabel.textColor = .white
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.72
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isUserInteractionEnabled = false

        addSubview(stack)
        NSLayoutConstraint.activate([
            glassContainer.topAnchor.constraint(equalTo: topAnchor),
            glassContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            glassContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            glassContainer.trailingAnchor.constraint(equalTo: trailingAnchor),

            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),

            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24)
        ])

        addTarget(self, action: #selector(pressDown), for: .touchDown)
        addTarget(self, action: #selector(pressUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        if !didLayout, bounds.height > 0 {
            didLayout = true
            glassContainer.setupGlass(
                tintColor: baseColor.withAlphaComponent(0.86),
                shadowColor: baseColor,
                shadowOpacity: 0.22,
                shadowRadius: 14,
                shadowOffset: CGSize(width: 0, height: 7),
                specularAlpha: 0.52,
                borderAlpha: 0.72
            )
            layer.shadowColor = baseColor.cgColor
            layer.shadowOpacity = 0.24
            layer.shadowRadius = 14
            layer.shadowOffset = CGSize(width: 0, height: 8)
        }
    }

    func setTitle(_ title: String) {
        titleLabel.text = title
    }

    func setIcon(_ iconName: String) {
        iconView.image = Self.iconImage(named: iconName)
    }

    private static func iconImage(named name: String) -> UIImage? {
        if name == "custom.sword" {
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: 28, height: 28))
            return renderer.image { context in
                let color = UIColor.white
                color.setFill()
                color.setStroke()
                let cg = context.cgContext
                cg.setLineCap(.round)
                cg.setLineJoin(.round)

                // Blade
                let blade = UIBezierPath()
                blade.move(to: CGPoint(x: 14, y: 2))
                blade.addLine(to: CGPoint(x: 17, y: 6))
                blade.addLine(to: CGPoint(x: 16, y: 18))
                blade.addLine(to: CGPoint(x: 12, y: 18))
                blade.addLine(to: CGPoint(x: 11, y: 6))
                blade.close()
                blade.fill()

                // Crossguard
                let crossguard = UIBezierPath(roundedRect: CGRect(x: 8, y: 18, width: 12, height: 3), cornerRadius: 1.5)
                crossguard.fill()

                // Hilt
                let hilt = UIBezierPath(roundedRect: CGRect(x: 12.5, y: 21, width: 3, height: 5), cornerRadius: 1)
                hilt.fill()

                // Pommel
                let pommel = UIBezierPath(ovalIn: CGRect(x: 11, y: 25, width: 6, height: 4))
                pommel.fill()




            }.withRenderingMode(.alwaysTemplate)
        }

        let config = UIImage.SymbolConfiguration(pointSize: 19, weight: .bold)
        return UIImage(systemName: name, withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
    }

    @objc private func pressDown() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        UIView.animate(withDuration: 0.10, delay: 0, options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState]) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.glassContainer.tintOverlay.alpha = 0.72
        }
    }

    @objc private func pressUp() {
        UIView.animate(withDuration: 0.30, delay: 0, usingSpringWithDamping: 0.62, initialSpringVelocity: 0.55, options: [.allowUserInteraction, .beginFromCurrentState]) {
            self.transform = .identity
            self.glassContainer.tintOverlay.alpha = 1
        }
    }
}

// MARK: - CompactLiquidCircleButton

fileprivate final class CompactLiquidCircleButton: UIControl {
    private let glassContainer = LiquidGlassContainerView()
    private let iconView = UIImageView()
    private let iconName: String
    private var didLayout = false

    init(iconName: String) {
        self.iconName = iconName
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        glassContainer.isUserInteractionEnabled = false
        addSubview(glassContainer)

        iconView.image = UIImage(systemName: iconName, withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .bold))
        iconView.tintColor = UIColor.black.withAlphaComponent(0.34)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconView)

        NSLayoutConstraint.activate([
            glassContainer.topAnchor.constraint(equalTo: topAnchor),
            glassContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            glassContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            glassContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18)
        ])

        addTarget(self, action: #selector(pressDown), for: .touchDown)
        addTarget(self, action: #selector(pressUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        if !didLayout, bounds.height > 0 {
            didLayout = true
            glassContainer.setupGlass(
                tintColor: UIColor.white.withAlphaComponent(0.58),
                shadowColor: UIColor.black.withAlphaComponent(0.10),
                shadowOpacity: 0.10,
                shadowRadius: 12,
                shadowOffset: CGSize(width: 0, height: 5),
                specularAlpha: 0.82,
                borderAlpha: 0.86
            )
        }
    }

    @objc private func pressDown() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let sx: CGFloat = iconName.contains("right") ? 1.22 : 1.12
        let sy: CGFloat = iconName.contains("right") ? 0.88 : 0.90
        UIView.animate(withDuration: 0.12, delay: 0, options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState]) {
            self.transform = CGAffineTransform(scaleX: sx, y: sy)
            self.glassContainer.tintOverlay.alpha = 0.78
        }
    }

    @objc private func pressUp() {
        UIView.animate(withDuration: 0.34, delay: 0, usingSpringWithDamping: 0.56, initialSpringVelocity: 0.75, options: [.allowUserInteraction, .beginFromCurrentState]) {
            self.transform = .identity
            self.glassContainer.tintOverlay.alpha = 1.0
        }
    }
}

// MARK: - EnemyBuilderViewController

fileprivate final class EnemyBuilderViewController: UIViewController, PHPickerViewControllerDelegate, UIGestureRecognizerDelegate {
    var onSave: ((String, UIImage, Double) -> Void)?

    private var hasSelectedPhoto = false
    private var selectedLayer: UIView?
    private var didPlaceParts = false

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = DS.golosBold(27)
        label.textColor = DS.textPrimary
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.74
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let closeButton = GreenCircleButton(iconName: "xmark")

    private let previewCard: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.86)
        view.layer.cornerRadius = 28
        view.layer.cornerCurve = .continuous
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowRadius = 18
        view.layer.shadowOffset = CGSize(width: 0, height: 10)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let canvasView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let photoObjectView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor(red: 235/255, green: 245/255, blue: 240/255, alpha: 0.52)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 22
        imageView.layer.cornerCurve = .continuous
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = DT.accentGreen.withAlphaComponent(0.18).cgColor
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let photoPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = DS.golosBold(15)
        label.textColor = DT.accentGreen.withAlphaComponent(0.86)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let leftHandView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "hand_monst"))
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let rightHandView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "hand_monst")?.withHorizontallyFlippedOrientation())
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let leftLegView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "leg_monst"))
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let rightLegView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "leg_monst")?.withHorizontallyFlippedOrientation())
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let eyesView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "angry_eyes"))
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let hintLabel: UILabel = {
        let label = UILabel()
        label.font = DS.golosSemi(13)
        label.textColor = DS.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var nameField: UITextField = makeTextField(placeholder: "")
    private lazy var targetField: UITextField = {
        let field = makeTextField(placeholder: "")
        field.keyboardType = .numberPad
        return field
    }()

    private let eyesControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["No eyes", "Angry", "Cartoon"])
        control.selectedSegmentIndex = 0
        control.backgroundColor = UIColor.white.withAlphaComponent(0.72)
        control.selectedSegmentTintColor = DT.accentGreen
        control.setTitleTextAttributes([.foregroundColor: UIColor.white, .font: DS.golosBold(13)], for: .selected)
        control.setTitleTextAttributes([.foregroundColor: DS.textPrimary, .font: DS.golosSemi(13)], for: .normal)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    private lazy var choosePhotoButton = BattleLiquidActionButton(
        title: UserManager.shared.isRussian ? "Фото" : "Photo",
        iconName: "photo.fill",
        color: DT.accentGreen
    )

    private lazy var saveButton = BattleLiquidActionButton(
        title: UserManager.shared.isRussian ? "Сохранить врага" : "Save Enemy",
        iconName: "checkmark",
        color: DT.accentGreen
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 244/255, green: 250/255, blue: 247/255, alpha: 1.0)
        setup()
        localize()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        placePartsOnce()
        photoPlaceholderLabel.frame = photoObjectView.bounds.insetBy(dx: 10, dy: 0)
    }

    private func setup() {
        [titleLabel, closeButton, previewCard, nameField, targetField, eyesControl, choosePhotoButton, saveButton].forEach {
            view.addSubview($0)
        }
        previewCard.addSubview(canvasView)
        previewCard.addSubview(hintLabel)
        photoObjectView.addSubview(photoPlaceholderLabel)
        [leftHandView, rightHandView, leftLegView, rightLegView, photoObjectView, eyesView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = true
            canvasView.addSubview($0)
            attachGestures(to: $0)
        }

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 22),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: closeButton.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -22),

            previewCard.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 24),
            previewCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 26),
            previewCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -26),
            previewCard.heightAnchor.constraint(equalToConstant: 300),

            canvasView.centerXAnchor.constraint(equalTo: previewCard.centerXAnchor),
            canvasView.topAnchor.constraint(equalTo: previewCard.topAnchor, constant: 18),
            canvasView.widthAnchor.constraint(equalToConstant: 286),
            canvasView.heightAnchor.constraint(equalToConstant: 216),

            hintLabel.leadingAnchor.constraint(equalTo: previewCard.leadingAnchor, constant: 24),
            hintLabel.trailingAnchor.constraint(equalTo: previewCard.trailingAnchor, constant: -24),
            hintLabel.bottomAnchor.constraint(equalTo: previewCard.bottomAnchor, constant: -18),

            nameField.topAnchor.constraint(equalTo: previewCard.bottomAnchor, constant: 22),
            nameField.leadingAnchor.constraint(equalTo: previewCard.leadingAnchor),
            nameField.trailingAnchor.constraint(equalTo: previewCard.trailingAnchor),
            nameField.heightAnchor.constraint(equalToConstant: 54),

            targetField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 12),
            targetField.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            targetField.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            targetField.heightAnchor.constraint(equalToConstant: 54),

            eyesControl.topAnchor.constraint(equalTo: targetField.bottomAnchor, constant: 16),
            eyesControl.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            eyesControl.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            eyesControl.heightAnchor.constraint(equalToConstant: 44),

            choosePhotoButton.topAnchor.constraint(equalTo: eyesControl.bottomAnchor, constant: 20),
            choosePhotoButton.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            choosePhotoButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -8),
            choosePhotoButton.heightAnchor.constraint(equalToConstant: 58),

            saveButton.topAnchor.constraint(equalTo: eyesControl.bottomAnchor, constant: 20),
            saveButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 8),
            saveButton.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 58)
        ])

        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        choosePhotoButton.addTarget(self, action: #selector(choosePhotoTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        eyesControl.addTarget(self, action: #selector(eyesChanged), for: .valueChanged)
        selectLayer(photoObjectView)
    }

    private func placePartsOnce() {
        guard !didPlaceParts, canvasView.bounds.width > 0 else { return }
        didPlaceParts = true
        photoObjectView.frame = CGRect(x: 82, y: 38, width: 122, height: 112)
        eyesView.frame = CGRect(x: 96, y: 70, width: 94, height: 50)
        leftHandView.frame = CGRect(x: 16, y: 86, width: 76, height: 80)
        rightHandView.frame = CGRect(x: 194, y: 86, width: 76, height: 80)
        leftLegView.frame = CGRect(x: 92, y: 148, width: 50, height: 64)
        rightLegView.frame = CGRect(x: 150, y: 148, width: 50, height: 64)
        keepAccessoriesAboveObject()
    }

    private func localize() {
        let isRu = UserManager.shared.isRussian
        titleLabel.text = isRu ? "Новый враг" : "New Enemy"
        hintLabel.text = isRu
            ? "Фото, глаза, руки и ноги можно двигать, масштабировать и крутить."
            : "Move, scale and rotate the photo, eyes, hands and legs."
        photoPlaceholderLabel.text = isRu ? "Здесь\nбудет" : "Will be\nhere"
        nameField.placeholder = isRu ? "Краткое имя цели" : "Short goal name"
        targetField.placeholder = isRu ? "Цель накопления, ₽" : "Savings target, ₽"
        nameField.text = nameField.text?.isEmpty == false ? nameField.text : UserManager.shared.session.savingsGoalName
        targetField.text = targetField.text?.isEmpty == false ? targetField.text : String(Int(UserManager.shared.session.savingsTarget))
        eyesControl.setTitle(isRu ? "Без глаз" : "No eyes", forSegmentAt: 0)
        eyesControl.setTitle(isRu ? "Злые" : "Angry", forSegmentAt: 1)
        eyesControl.setTitle(isRu ? "Мульт" : "Cartoon", forSegmentAt: 2)
        choosePhotoButton.setTitle(isRu ? "Фото" : "Photo")
        saveButton.setTitle(isRu ? "Готово" : "Done")
    }

    private func makeTextField(placeholder: String) -> UITextField {
        let field = UITextField()
        field.placeholder = placeholder
        field.font = DS.golosSemi(16)
        field.textColor = DS.textPrimary
        field.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        field.layer.cornerRadius = 18
        field.layer.cornerCurve = .continuous
        field.layer.borderColor = UIColor.white.cgColor
        field.layer.borderWidth = 1
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 18, height: 1))
        field.leftViewMode = .always
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func eyesChanged() {
        eyesView.isHidden = eyesControl.selectedSegmentIndex == 0
        if eyesControl.selectedSegmentIndex == 1 {
            eyesView.image = UIImage(named: "angry_eyes")
        } else if eyesControl.selectedSegmentIndex == 2 {
            eyesView.image = UIImage(named: "cartoon_eyes")
        }
        if !eyesView.isHidden {
            canvasView.bringSubviewToFront(eyesView)
            selectLayer(eyesView)
        }
    }

    @objc private func choosePhotoTapped() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 1
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let image = object as? UIImage else { return }
            DispatchQueue.main.async {
                self?.hasSelectedPhoto = true
                self?.photoObjectView.image = image
                self?.photoObjectView.backgroundColor = .clear
                self?.photoPlaceholderLabel.isHidden = true
                self?.photoObjectView.layer.borderColor = UIColor.white.withAlphaComponent(0.96).cgColor
                self?.selectLayer(self?.photoObjectView)
            }
        }
    }

    @objc private func saveTapped() {
        let isRu = UserManager.shared.isRussian
        guard hasSelectedPhoto else {
            let alert = UIAlertController(
                title: isRu ? "Добавьте фото" : "Add a photo",
                message: isRu ? "Сначала выберите объект для новой цели." : "Choose an object for the new goal first.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        let cleanedName = (nameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let name = cleanedName.isEmpty ? (isRu ? "Новая цель" : "New Goal") : cleanedName
        let targetText = (targetField.text ?? "").replacingOccurrences(of: " ", with: "")
        let target = Double(targetText) ?? UserManager.shared.session.savingsTarget
        let image = renderEnemy()
        onSave?(name, image, max(1000.0, target))
        dismiss(animated: true)
    }

    private func attachGestures(to view: UIView) {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
        let tap = UITapGestureRecognizer(target: self, action: #selector(bringLayerToFront(_:)))
        [pan, pinch, rotate, tap].forEach {
            $0.delegate = self
            view.addGestureRecognizer($0)
        }
    }

    @objc private func bringLayerToFront(_ recognizer: UITapGestureRecognizer) {
        guard let target = recognizer.view else { return }
        selectLayer(target)
        if target === photoObjectView {
            keepAccessoriesAboveObject()
        } else {
            canvasView.bringSubviewToFront(target)
            canvasView.bringSubviewToFront(eyesView)
        }
    }

    @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
        guard let target = recognizer.view else { return }
        let translation = recognizer.translation(in: canvasView)
        target.center = CGPoint(x: target.center.x + translation.x, y: target.center.y + translation.y)
        recognizer.setTranslation(.zero, in: canvasView)
        if target === photoObjectView { keepAccessoriesAboveObject() }
        if recognizer.state == .began { selectLayer(target) }
    }

    @objc private func handlePinch(_ recognizer: UIPinchGestureRecognizer) {
        guard let target = recognizer.view else { return }
        target.transform = target.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
        recognizer.scale = 1
        if target === photoObjectView { keepAccessoriesAboveObject() }
        if recognizer.state == .began { selectLayer(target) }
    }

    @objc private func handleRotation(_ recognizer: UIRotationGestureRecognizer) {
        guard let target = recognizer.view else { return }
        target.transform = target.transform.rotated(by: recognizer.rotation)
        recognizer.rotation = 0
        if target === photoObjectView { keepAccessoriesAboveObject() }
        if recognizer.state == .began { selectLayer(target) }
    }

    private func keepAccessoriesAboveObject() {
        [leftHandView, rightHandView, leftLegView, rightLegView, eyesView].forEach {
            canvasView.bringSubviewToFront($0)
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

    private func renderEnemy() -> UIImage {
        let previousHint = hintLabel.isHidden
        let previousSelected = selectedLayer
        clearSelection()
        hintLabel.isHidden = true
        let renderer = UIGraphicsImageRenderer(size: canvasView.bounds.size)
        let image = renderer.image { context in
            canvasView.layer.render(in: context.cgContext)
        }
        hintLabel.isHidden = previousHint
        if let previousSelected { selectLayer(previousSelected) }
        return image
    }

    private func selectLayer(_ view: UIView?) {
        clearSelection()
        selectedLayer = view
        guard let view else { return }
        view.layer.shadowColor = DT.accentGreen.cgColor
        view.layer.shadowOpacity = 0.26
        view.layer.shadowRadius = 10
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        if view !== photoObjectView {
            view.layer.borderColor = DT.accentGreen.withAlphaComponent(0.38).cgColor
            view.layer.borderWidth = 1.2
            view.layer.cornerRadius = 10
        }
    }

    private func clearSelection() {
        [leftHandView, rightHandView, leftLegView, rightLegView, eyesView].forEach {
            $0.layer.borderWidth = 0
            $0.layer.shadowOpacity = 0
        }
        photoObjectView.layer.shadowOpacity = 0
        photoObjectView.layer.borderWidth = 2
        photoObjectView.layer.borderColor = hasSelectedPhoto
            ? UIColor.white.withAlphaComponent(0.96).cgColor
            : DT.accentGreen.withAlphaComponent(0.18).cgColor
    }
}

// MARK: - BattleViewController

final class BattleViewController: UIViewController {

    // MARK: - Обратные вызовы (Callbacks)
    
    // Вызывается после каждого изменения суммы накоплений
    var onSavingsUpdated: ((Double, Double, String) -> Void)?

    // MARK: - Состояние (State)
    
    private var currentAmount: Double = 23250
    private var targetAmount: Double  = 62000
    private var goalName: String      = "Playstation 5 Slim"
    private var isAnimating = false
    private var scenePrevTopConstraint: NSLayoutConstraint?
    private var sceneNextTopConstraint: NSLayoutConstraint?
    private var buildButtonTopConstraint: NSLayoutConstraint?

    private var progress: Double { min(1.0, max(0, currentAmount / targetAmount)) }

    // MARK: - Инициализатор (Init)
    
    convenience init(currentAmount: Double, targetAmount: Double, goalName: String) {
        self.init()
        let activeGoal = UserManager.shared.activeEnemyGoal()
        self.currentAmount = targetAmount > 0 ? currentAmount : activeGoal.current
        self.targetAmount  = targetAmount > 0 ? targetAmount : activeGoal.target
        self.goalName      = goalName.isEmpty ? activeGoal.name : goalName
    }

    // MARK: - UI Элементы

    private let headerContainer = UIView()

    private lazy var backButton = GreenCircleButton(iconName: "chevron.left")
    private let notificationButton = NotificationBellButton()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = UserManager.shared.isRussian ? "Сцена битвы" : "Battle Scene"
        lbl.font = .systemFont(ofSize: 28, weight: .black)
        lbl.textColor = .black
        return lbl
    }()

    private let goalCardView = SavingsGoalCardView()

    private let battleContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 24
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        return view
    }()

    private let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "battle_bg")
        iv.contentMode = .scaleAspectFill
        return iv
    }()

    // Спрайт игрока
    private let playerImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "player_m")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // Спрайт врага
    private let enemyImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "plst_obj")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private lazy var buildEnemyButton = BattleLiquidActionButton(
        title: UserManager.shared.isRussian ? "Цель" : "Goal",
        iconName: "plus",
        color: DT.accentGreen
    )

    private lazy var scenePrevButton = CompactLiquidCircleButton(iconName: "chevron.left")
    private lazy var sceneNextButton = CompactLiquidCircleButton(iconName: "chevron.right")

    // Визуальный эффект удара
    private let slashEffectView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.alpha = 0
        v.layer.cornerRadius = 24
        return v
    }()

    private let actionsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 16
        sv.distribution = .fillEqually
        return sv
    }()

    private lazy var saveMoneyButton = BattleLiquidActionButton(
        title: UserManager.shared.isRussian ? "Отложить" : "Save",
        iconName: "custom.sword",
        color: DT.accentGreen
    )

    private lazy var trackSpendingButton = BattleLiquidActionButton(
        title: UserManager.shared.isRussian ? "Расход" : "Spend",
        iconName: "heart.slash.fill",
        color: DT.expenseRed
    )

    // MARK: - Жизненный цикл (Lifecycle)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 244/255, green: 250/255, blue: 247/255, alpha: 1.0)
        setupViews()
        setupConstraints()
        setupActions()
        updateLocalization()
        refreshCard()
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocalization), name: NSNotification.Name("LanguageChanged"), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        forceDesignOverrides()
        positionSceneControls()
    }

    // Принудительная настройка стилей карточки
    private func forceDesignOverrides() {
        goalCardView.layer.borderWidth = 0
        goalCardView.layer.shadowColor = UIColor.black.cgColor
        goalCardView.layer.shadowOpacity = 0.05
        goalCardView.layer.shadowRadius = 15
        goalCardView.layer.shadowOffset = CGSize(width: 0, height: 8)

        for subview in goalCardView.subviews {
            if let btn = subview as? UIButton {
                btn.setImage(UIImage(named: "fight_act"), for: .normal)
            }
        }
    }

    private func positionSceneControls() {
        let height = battleContainer.bounds.height
        guard height > 0 else { return }
        buildButtonTopConstraint?.constant = max(12, height * 0.035)
        scenePrevTopConstraint?.constant = buildButtonTopConstraint?.constant ?? 12
        sceneNextTopConstraint?.constant = buildButtonTopConstraint?.constant ?? 12
    }

    // MARK: - Настройка верстки (Setup)

    private func setupViews() {
        [headerContainer, backButton, titleLabel, notificationButton,
         goalCardView, battleContainer, backgroundImageView,
         playerImageView, enemyImageView, slashEffectView, buildEnemyButton,
         scenePrevButton, sceneNextButton, actionsStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        headerContainer.addSubview(backButton)
        headerContainer.addSubview(titleLabel)
        headerContainer.addSubview(notificationButton)
        view.addSubview(headerContainer)

        view.addSubview(goalCardView)

        battleContainer.addSubview(backgroundImageView)
        battleContainer.addSubview(playerImageView)
        battleContainer.addSubview(enemyImageView)
        battleContainer.addSubview(slashEffectView)
        battleContainer.addSubview(buildEnemyButton)
        battleContainer.addSubview(scenePrevButton)
        battleContainer.addSubview(sceneNextButton)
        view.addSubview(battleContainer)

        actionsStackView.addArrangedSubview(saveMoneyButton)
        actionsStackView.addArrangedSubview(trackSpendingButton)
        view.addSubview(actionsStackView)
    }

    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide

        buildButtonTopConstraint = buildEnemyButton.topAnchor.constraint(equalTo: battleContainer.topAnchor, constant: 14)
        scenePrevTopConstraint = scenePrevButton.topAnchor.constraint(equalTo: battleContainer.topAnchor, constant: 0)
        sceneNextTopConstraint = sceneNextButton.topAnchor.constraint(equalTo: battleContainer.topAnchor, constant: 0)

        NSLayoutConstraint.activate([
            // Заголовок (Header)
            headerContainer.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 6),
            headerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            headerContainer.heightAnchor.constraint(equalToConstant: 44),

            backButton.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
            backButton.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),

            notificationButton.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor),
            notificationButton.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            notificationButton.widthAnchor.constraint(equalToConstant: 44),
            notificationButton.heightAnchor.constraint(equalToConstant: 44),

            // Карточка (Card)
            goalCardView.topAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: 16),
            goalCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            goalCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // Контейнер битвы
            battleContainer.topAnchor.constraint(equalTo: goalCardView.bottomAnchor, constant: 16),
            battleContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            battleContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            battleContainer.bottomAnchor.constraint(equalTo: actionsStackView.topAnchor, constant: -16),

            backgroundImageView.topAnchor.constraint(equalTo: battleContainer.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: battleContainer.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: battleContainer.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: battleContainer.bottomAnchor),

            slashEffectView.topAnchor.constraint(equalTo: battleContainer.topAnchor),
            slashEffectView.leadingAnchor.constraint(equalTo: battleContainer.leadingAnchor),
            slashEffectView.trailingAnchor.constraint(equalTo: battleContainer.trailingAnchor),
            slashEffectView.bottomAnchor.constraint(equalTo: battleContainer.bottomAnchor),

            // Спрайты
            playerImageView.leadingAnchor.constraint(equalTo: battleContainer.leadingAnchor, constant: 30),
            playerImageView.bottomAnchor.constraint(equalTo: battleContainer.bottomAnchor, constant: -112),
            playerImageView.widthAnchor.constraint(equalToConstant: 120),
            playerImageView.heightAnchor.constraint(equalToConstant: 150),

            enemyImageView.trailingAnchor.constraint(equalTo: battleContainer.trailingAnchor, constant: -30),
            enemyImageView.bottomAnchor.constraint(equalTo: battleContainer.bottomAnchor, constant: -112),
            enemyImageView.widthAnchor.constraint(equalToConstant: 120),
            enemyImageView.heightAnchor.constraint(equalToConstant: 150),

            buildButtonTopConstraint!,
            buildEnemyButton.trailingAnchor.constraint(equalTo: battleContainer.trailingAnchor, constant: -14),
            buildEnemyButton.widthAnchor.constraint(equalToConstant: 104),
            buildEnemyButton.heightAnchor.constraint(equalToConstant: 36),

            scenePrevButton.trailingAnchor.constraint(equalTo: sceneNextButton.leadingAnchor, constant: -8),
            scenePrevTopConstraint!,
            scenePrevButton.widthAnchor.constraint(equalToConstant: 36),
            scenePrevButton.heightAnchor.constraint(equalToConstant: 36),

            sceneNextButton.trailingAnchor.constraint(equalTo: buildEnemyButton.leadingAnchor, constant: -8),
            sceneNextTopConstraint!,
            sceneNextButton.widthAnchor.constraint(equalToConstant: 36),
            sceneNextButton.heightAnchor.constraint(equalToConstant: 36),

            // Действия внизу (Bottom Actions)
            actionsStackView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -10),
            actionsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            actionsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            actionsStackView.heightAnchor.constraint(equalToConstant: 58)
        ])
    }

    private func setupActions() {
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        notificationButton.addTarget(self, action: #selector(notificationTapped), for: .touchUpInside)
        buildEnemyButton.addTarget(self, action: #selector(buildEnemyTapped), for: .touchUpInside)
        sceneNextButton.addTarget(self, action: #selector(buildEnemyTapped), for: .touchUpInside)
        scenePrevButton.addTarget(self, action: #selector(previousGoalTapped), for: .touchUpInside)
        sceneNextButton.removeTarget(self, action: #selector(buildEnemyTapped), for: .touchUpInside)
        sceneNextButton.addTarget(self, action: #selector(nextGoalTapped), for: .touchUpInside)
        let deletePress = UILongPressGestureRecognizer(target: self, action: #selector(deleteGoalLongPress(_:)))
        buildEnemyButton.addGestureRecognizer(deletePress)

        goalCardView.onFightTapped = { [weak self] in
            self?.performPlayerAttack()
        }

        saveMoneyButton.addTarget(self, action: #selector(saveMoneyTapped), for: .touchUpInside)

        trackSpendingButton.addTarget(self, action: #selector(trackSpendingTapped), for: .touchUpInside)
    }

    @objc private func updateLocalization() {
        let isRu = UserManager.shared.isRussian
        titleLabel.text = isRu ? "Сцена битвы" : "Battle Scene"
        saveMoneyButton.setTitle(isRu ? "Отложить" : "Save")
        trackSpendingButton.setTitle(isRu ? "Расход" : "Spend")
        buildEnemyButton.setTitle(isRu ? "Цель" : "Goal")
    }

    @objc private func notificationTapped() {
        let isRu = UserManager.shared.isRussian
        let alert = UIAlertController(
            title: isRu ? "Уведомления" : "Notifications",
            message: isRu ? "Здесь появятся события боя и напоминания о цели." : "Battle events and goal reminders will appear here.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Обновление данных (Refresh)

    private func refreshCard(animated: Bool = false) {
        let pct = progress * 100
        applyCustomEnemyIfNeeded()
        goalCardView.configure(
            goalName: goalName,
            current:  formatCurrency(currentAmount),
            target:   formatCurrency(targetAmount),
            percent:  String(format: "%.1f%%", pct),
            progress: progress
        )

        // Анимация карточки при обновлении
        if animated {
            UIView.animate(withDuration: 0.12, delay: 0, options: .curveEaseIn, animations: {
                self.goalCardView.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            }) { _ in
                UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.5,
                               initialSpringVelocity: 0.6, options: .curveEaseOut) {
                    self.goalCardView.transform = .identity
                }
            }
        }

        // Синхронизация с Dashboard
        UserManager.shared.saveSavingsGoal(current: currentAmount, target: targetAmount, name: goalName)
        onSavingsUpdated?(currentAmount, targetAmount, goalName)
    }

    private func applyCustomEnemyIfNeeded() {
        let activeGoal = UserManager.shared.activeEnemyGoal()
        if !activeGoal.isDefault, let custom = UserManager.shared.customEnemyImage() {
            enemyImageView.image = custom
        } else {
            enemyImageView.image = UIImage(named: "plst_obj")
        }
    }

    private func formatCurrency(_ value: Double) -> String {
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.groupingSeparator = " "
        fmt.maximumFractionDigits = 0
        return (fmt.string(from: NSNumber(value: value)) ?? "\(Int(value))") + "₽"
    }

    // MARK: - Сохранение средств (Игрок атакует врага)

    @objc private func saveMoneyTapped() {
        let isRu = UserManager.shared.isRussian
        showAmountMenu(title: isRu ? "Отложить деньги" : "Save Money",
                       subtitle: isRu ? "Сколько удалось отложить?" : "How much did you save?",
                       presets: [500, 1000, 2500, 5000]) { [weak self] amount in
            guard let self = self else { return }
            self.currentAmount = min(self.targetAmount, self.currentAmount + amount)
            self.performPlayerAttack()
        }
    }

    // MARK: - Учет расходов (Враг атакует игрока)

    @objc private func trackSpendingTapped() {
        let isRu = UserManager.shared.isRussian
        showAmountMenu(title: isRu ? "Записать расход" : "Track Spending",
                       subtitle: isRu ? "Сколько вы потратили?" : "How much did you spend?",
                       presets: [500, 1000, 2500, 5000]) { [weak self] amount in
            guard let self = self else { return }
            self.currentAmount = max(0, self.currentAmount - amount)
            self.performEnemyAttack()
        }
    }

    // MARK: - Меню выбора суммы (Amount Menu)

    private func showAmountMenu(title: String, subtitle: String,
                                 presets: [Int], completion: @escaping (Double) -> Void) {

        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .actionSheet)

        for preset in presets {
            let fmt = NumberFormatter()
            fmt.numberStyle = .decimal
            fmt.groupingSeparator = " "
            let label = fmt.string(from: NSNumber(value: preset)) ?? "\(preset)"
            alert.addAction(UIAlertAction(title: "\(label)₽", style: .default) { _ in
                completion(Double(preset))
            })
        }

        let isRu = UserManager.shared.isRussian
        alert.addAction(UIAlertAction(title: isRu ? "Своя сумма…" : "Custom amount…", style: .default) { [weak self] _ in
            self?.showCustomAmountInput(completion: completion)
        })

        alert.addAction(UIAlertAction(title: isRu ? "Отмена" : "Cancel", style: .cancel))

        // Цветовой акцент для кнопок
        alert.view.tintColor = UIColor(red: 37/255, green: 163/255, blue: 115/255, alpha: 1)
        present(alert, animated: true)
    }

    private func showCustomAmountInput(completion: @escaping (Double) -> Void) {
        let isRu = UserManager.shared.isRussian
        let alert = UIAlertController(title: isRu ? "Введите сумму" : "Enter amount", message: nil, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = isRu ? "Сумма в ₽" : "Amount in ₽"
            tf.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            if let text = alert.textFields?.first?.text,
               let val = Double(text.replacingOccurrences(of: " ", with: "")), val > 0 {
                completion(val)
            }
        })
        alert.addAction(UIAlertAction(title: isRu ? "Отмена" : "Cancel", style: .cancel))
        alert.view.tintColor = UIColor(red: 37/255, green: 163/255, blue: 115/255, alpha: 1)
        present(alert, animated: true)
    }

    // MARK: - Анимации (Animations)

    @objc private func backTapped() { dismiss(animated: true) }

    @objc private func buildEnemyTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        UIView.animate(withDuration: 0.10, animations: {
            self.buildEnemyButton.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }) { _ in
            UIView.animate(withDuration: 0.26, delay: 0, usingSpringWithDamping: 0.58, initialSpringVelocity: 0.6) {
                self.buildEnemyButton.transform = .identity
            }
        }

        let builder = EnemyBuilderViewController()
        builder.modalPresentationStyle = .fullScreen
        builder.onSave = { [weak self] name, image, target in
            guard let self = self else { return }
            let data = image.pngData() ?? Data()
            self.currentAmount = 0
            self.targetAmount = target
            self.goalName = name
            UserManager.shared.saveCustomEnemy(name: name, imageData: data, current: 0, target: target)
            self.enemyImageView.image = image
            self.refreshCard(animated: true)
        }
        present(builder, animated: true)
    }

    @objc private func previousGoalTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        UserManager.shared.switchEnemyGoal(delta: -1)
        loadActiveGoal(animated: true)
    }

    @objc private func nextGoalTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        UserManager.shared.switchEnemyGoal(delta: 1)
        loadActiveGoal(animated: true)
    }

    private func loadActiveGoal(animated: Bool) {
        let goal = UserManager.shared.activeEnemyGoal()
        goalName = goal.name
        currentAmount = goal.current
        targetAmount = goal.target
        refreshCard(animated: animated)
    }

    @objc private func deleteGoalLongPress(_ recognizer: UILongPressGestureRecognizer) {
        guard recognizer.state == .began else { return }
        let isRu = UserManager.shared.isRussian
        let goal = UserManager.shared.activeEnemyGoal()
        guard !goal.isDefault else {
            let alert = UIAlertController(title: isRu ? "Базовую цель нельзя удалить" : "Default goal cannot be deleted", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        let alert = UIAlertController(
            title: isRu ? "Удалить цель?" : "Delete goal?",
            message: goal.name,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: isRu ? "Отмена" : "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: isRu ? "Удалить" : "Delete", style: .destructive) { [weak self] _ in
            _ = UserManager.shared.deleteActiveEnemyGoal()
            self?.loadActiveGoal(animated: true)
        })
        present(alert, animated: true)
    }

    @objc private func animateButtonPress(_ sender: UIControl) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            sender.alpha = 0.8
        }
    }

    @objc private func animateButtonRelease(_ sender: UIControl) {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            sender.transform = .identity
            sender.alpha = 1.0
        }
    }

    // Анимация атаки игрока
    private func performPlayerAttack() {
        guard !isAnimating else { return }
        isAnimating = true
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

        // 1. Смена спрайта на атакующую позу
        UIView.transition(with: playerImageView, duration: 0.1, options: .transitionCrossDissolve) {
            self.playerImageView.image = UIImage(named: "player_attack")
        }

        // 2. Рывок вперёд
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn) {
            self.playerImageView.transform = CGAffineTransform(translationX: 55, y: -8).scaledBy(x: 1.12, y: 1.12)
        } completion: { _ in
            // Визуальный эффект удара
            self.flashSlash()

            // 3. Враг получает урон
            UIView.animate(withDuration: 0.08, animations: {
                self.enemyImageView.transform = CGAffineTransform(translationX: 30, y: -8).rotated(by: 0.2)
                self.enemyImageView.alpha = 0.3
            }) { _ in
                // 4. Возврат на исходную позицию
                UIView.animate(withDuration: 0.4, delay: 0.05, usingSpringWithDamping: 0.5,
                               initialSpringVelocity: 0.5, options: .curveEaseOut) {
                    self.playerImageView.transform = .identity
                    self.enemyImageView.transform = .identity
                    self.enemyImageView.alpha = 1.0
                } completion: { _ in
                    // Возврат спрайта покоя
                    UIView.transition(with: self.playerImageView, duration: 0.2, options: .transitionCrossDissolve) {
                        self.playerImageView.image = UIImage(named: "player_m")
                    }
                    self.refreshCard(animated: true)
                    self.isAnimating = false
                }
            }
        }
    }

    // Анимация атаки врага
    private func performEnemyAttack() {
        guard !isAnimating else { return }
        isAnimating = true
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

        // 1. Рывок врага
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn) {
            self.enemyImageView.transform = CGAffineTransform(translationX: -50, y: -5).scaledBy(x: 1.15, y: 1.15)
        } completion: { _ in
            self.flashSlash()

            // 2. Игрок получает урон
            UIView.animate(withDuration: 0.08, animations: {
                self.playerImageView.transform = CGAffineTransform(translationX: -30, y: -5).rotated(by: -0.2)
                self.playerImageView.alpha = 0.3
            }) { _ in
                // 3. Возврат на исходную позицию
                UIView.animate(withDuration: 0.4, delay: 0.05, usingSpringWithDamping: 0.5,
                               initialSpringVelocity: 0.5, options: .curveEaseOut) {
                    self.enemyImageView.transform = .identity
                    self.playerImageView.transform = .identity
                    self.playerImageView.alpha = 1.0
                } completion: { _ in
                    self.refreshCard(animated: true)
                    self.isAnimating = false
                }
            }
        }
    }

    // Белая вспышка
    private func flashSlash() {
        slashEffectView.alpha = 0.6
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.slashEffectView.alpha = 0
        }
    }
}
