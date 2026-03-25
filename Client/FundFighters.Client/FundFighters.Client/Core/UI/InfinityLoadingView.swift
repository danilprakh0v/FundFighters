/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: InfinityLoadingView.swift
Расположение: FundFighters.Client/FundFighters.Client/Core/UI/
Назначение: Custom animated infinity loop loading indicator. //              Кастомный анимированный индикатор загрузки в виде бесконечности.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 04.02.2026
===============================================================================
*/

import UIKit

final class InfinityLoadingView: UIView {
    
    private let shapeLayer = CAShapeLayer()
    private let trackLayer = CAShapeLayer()
    private var isAnimating = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayer()
    }
    
    private func setupLayer() {
        self.backgroundColor = .clear
        
        let path = createInfinityPath()
        
        // Track layer (background) - Using a darker green for better integration
        trackLayer.path = path.cgPath
        trackLayer.strokeColor = UIColor(red: 15/255, green: 110/255, blue: 70/255, alpha: 0.45).cgColor
        trackLayer.lineWidth = 4
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = .round
        trackLayer.lineJoin = .round
        layer.addSublayer(trackLayer)
        
        // Shape layer (animated outline)
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 4
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round
        shapeLayer.strokeEnd = 0.0
        layer.addSublayer(shapeLayer)
    }
    
    private func createInfinityPath() -> UIBezierPath {
        // Use more of the available bounds for a "larger" look
        let w = self.bounds.width
        let h = self.bounds.height
        
        // Adjusted for a more elegant lemniscate-like look or just larger side-by-side loops
        let radius = (h / 2) * 0.9 
        let centerX1 = w * 0.3
        let centerX2 = w * 0.7
        
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: centerX1, y: h / 2),
                    radius: radius,
                    startAngle: 0,
                    endAngle: 2 * .pi,
                    clockwise: true)
        
        path.addArc(withCenter: CGPoint(x: centerX2, y: h / 2),
                    radius: radius,
                    startAngle: .pi,
                    endAngle: 3 * .pi,
                    clockwise: true)
        
        return path
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        trackLayer.path = createInfinityPath().cgPath
        shapeLayer.path = createInfinityPath().cgPath
    }
    
    func startAnimating() {
        guard !isAnimating else { return }
        isAnimating = true
        self.isHidden = false
        
        let strokeStartAnim = CABasicAnimation(keyPath: "strokeStart")
        strokeStartAnim.fromValue = 0
        strokeStartAnim.toValue = 1
        strokeStartAnim.duration = 1.5
        strokeStartAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        let strokeEndAnim = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnim.fromValue = 0.1
        strokeEndAnim.toValue = 1.1
        strokeEndAnim.duration = 1.5
        strokeEndAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        let strokeGroup = CAAnimationGroup()
        strokeGroup.animations = [strokeStartAnim, strokeEndAnim]
        strokeGroup.duration = 1.5
        strokeGroup.repeatCount = .infinity
        
        shapeLayer.add(strokeGroup, forKey: "infinityLoading")
    }
    
    func stopAnimating() {
        isAnimating = false
        shapeLayer.removeAllAnimations()
        self.isHidden = true
    }
}
