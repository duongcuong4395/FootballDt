//
//  RotateOnAppearEffect.swift
//  FootballDt
//
//  Created by Macbook on 26/12/25.
//

import SwiftUI

import SwiftUI

// MARK: - Animation Configuration
struct AnimationConfig {
    var angle: Double
    var duration: Double
    var delay: Double
    var timingCurve: Animation
    var axis: RotationAxis3D
    
    static let `default` = AnimationConfig(
        angle: -70,
        duration: 0.5,
        delay: 0,
        timingCurve: .easeInOut,
        axis: .y
    )
    
    // Preset animations
    static let subtle = AnimationConfig(
        angle: -30,
        duration: 0.4,
        delay: 0,
        timingCurve: .spring(response: 0.6, dampingFraction: 0.8),
        axis: .y
    )
    
    static let dramatic = AnimationConfig(
        angle: -90,
        duration: 0.8,
        delay: 0,
        timingCurve: .spring(response: 0.7, dampingFraction: 0.7),
        axis: .y
    )
}

// MARK: - Rotation Axis (Better than enum)
struct RotationAxis3D {
    let x: CGFloat
    let y: CGFloat
    let z: CGFloat
    
    static let x = RotationAxis3D(x: 1, y: 0, z: 0)
    static let y = RotationAxis3D(x: 0, y: 1, z: 0)
    static let z = RotationAxis3D(x: 0, y: 0, z: 1)
    
    // Custom axis
    static func custom(x: CGFloat, y: CGFloat, z: CGFloat) -> RotationAxis3D {
        RotationAxis3D(x: x, y: y, z: z)
    }
}

// MARK: - Main Modifier
struct RotateOnAppearModifier: ViewModifier {
    @State private var isVisible = false
    
    let config: AnimationConfig
    let repeatOnReappear: Bool
    let anchor: UnitPoint
    
    init(
        config: AnimationConfig = .default,
        repeatOnReappear: Bool = true,
        anchor: UnitPoint = .center
    ) {
        self.config = config
        self.repeatOnReappear = repeatOnReappear
        self.anchor = anchor
    }
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(isVisible ? 0 : config.angle),
                axis: (
                    x: config.axis.x,
                    y: config.axis.y,
                    z: config.axis.z
                ),
                anchor: anchor,
                perspective: 1.0 / 1000 // Tạo depth realistic
            )
            .opacity(isVisible ? 1 : 0) // Fade in kèm theo
            .onAppear {
                guard !isVisible || repeatOnReappear else { return }
                
                withAnimation(
                    config.timingCurve
                        .delay(config.delay)
                        .speed(1.0 / config.duration)
                ) {
                    isVisible = true
                }
            }
            .onDisappear {
                if repeatOnReappear {
                    isVisible = false
                }
            }
    }
}

// MARK: - View Extensions (Multiple APIs)
extension View {
    /// Simple API - Quick usage
    func rotateOnAppear(
        angle: Double = -70,
        duration: Double = 0.5,
        axis: RotationAxis3D = .y
    ) -> some View {
        modifier(RotateOnAppearModifier(
            config: AnimationConfig(
                angle: angle,
                duration: duration,
                delay: 0,
                timingCurve: .easeInOut,
                axis: axis
            )
        ))
    }
    
    /// Advanced API - Full control
    func rotateOnAppear(
        config: AnimationConfig,
        repeatOnReappear: Bool = true,
        anchor: UnitPoint = .center
    ) -> some View {
        modifier(RotateOnAppearModifier(
            config: config,
            repeatOnReappear: repeatOnReappear,
            anchor: anchor
        ))
    }
    
    /// Preset API - Common patterns
    func rotateOnAppearSubtle() -> some View {
        modifier(RotateOnAppearModifier(config: .subtle))
    }
    
    func rotateOnAppearDramatic() -> some View {
        modifier(RotateOnAppearModifier(config: .dramatic))
    }
}

// MARK: - Stagger Helper (cho multiple views)
struct StaggeredRotateContainer<Content: View>: View {
    let content: Content
    let itemCount: Int
    let staggerDelay: Double
    let baseConfig: AnimationConfig
    
    init(
        itemCount: Int,
        staggerDelay: Double = 0.1,
        config: AnimationConfig = .default,
        @ViewBuilder content: () -> Content
    ) {
        self.itemCount = itemCount
        self.staggerDelay = staggerDelay
        self.baseConfig = config
        self.content = content()
    }
    
    var body: some View {
        content
    }
}

extension View {
    /// Apply staggered animation to items in ForEach
    func staggeredRotation(
        index: Int,
        config: AnimationConfig = .default,
        staggerDelay: Double = 0.1
    ) -> some View {
        var adjustedConfig = config
        adjustedConfig.delay = Double(index) * staggerDelay
        
        return modifier(RotateOnAppearModifier(config: adjustedConfig))
    }
}


// MARK: - Transition Style
extension AnyTransition {
    static func rotate3D(
        angle: Double = -70,
        axis: RotationAxis3D = .y,
        duration: Double = 0.5
    ) -> AnyTransition {
        .modifier(
            active: RotationEffectModifier(angle: angle, axis: axis),
            identity: RotationEffectModifier(angle: 0, axis: axis)
        )
        .animation(.easeInOut(duration: duration))
    }
}

struct RotationEffectModifier: ViewModifier {
    let angle: Double
    let axis: RotationAxis3D
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(angle),
                axis: (x: axis.x, y: axis.y, z: axis.z),
                perspective: 1.0 / 1000
            )
    }
}
