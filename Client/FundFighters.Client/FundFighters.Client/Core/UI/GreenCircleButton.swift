/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: GreenCircleButton.swift
Расположение: FundFighters.Client/FundFighters.Client/Core/UI/
Назначение: Унифицированная круглая зеленая кнопка (часто для Назад).
===============================================================================
*/

import UIKit

final class GreenCircleButton: UIButton {
    private let shineLayer = CAGradientLayer()

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
        layer.borderWidth = 1.1
        layer.borderColor = UIColor.white.withAlphaComponent(0.62).cgColor
        layer.shadowColor = DT.accentGreen.cgColor
        layer.shadowOpacity = 0.18
        layer.shadowRadius = 16
        layer.shadowOffset = CGSize(width: 0, height: 9)
        shineLayer.colors = [
            UIColor.white.withAlphaComponent(0.34).cgColor,
            UIColor.white.withAlphaComponent(0.05).cgColor,
            UIColor.black.withAlphaComponent(0.08).cgColor
        ]
        shineLayer.locations = [0, 0.48, 1]
        shineLayer.startPoint = CGPoint(x: 0, y: 0)
        shineLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(shineLayer, at: 0)
    }
    required init?(coder: NSCoder) { fatalError() }
    override func layoutSubviews() {
        super.layoutSubviews()
        shineLayer.frame = bounds
        shineLayer.cornerRadius = bounds.height / 2
        if #unavailable(iOS 26.0) {
            layer.cornerRadius = bounds.height / 2
            layer.cornerCurve  = .continuous
        }
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: isHighlighted ? 0.12 : 0.32, delay: 0, usingSpringWithDamping: 0.58, initialSpringVelocity: 0.8) {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 1.12, y: 0.86) : .identity
                self.alpha = self.isHighlighted ? 0.88 : 1
            }
        }
    }
}
