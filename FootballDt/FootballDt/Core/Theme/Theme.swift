//
//  Theme.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import SwiftUI
import GlassEffect



enum ColorTheme {
    static func backgroundCard(for scheme: ColorScheme) -> Color {
        scheme == .dark
        ? Color(red: 0.839, green: 0.839, blue: 0.839)
        : .white
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - 1. Separate Concerns: Configuration Models

/// Glass effect configuration - reusable across themes
struct GlassConfiguration {
    let cornerRadius: CGFloat
    var intensity: Double
    let tintColor: Color
    let gradientType: GradientType
    var borderStyle: BorderStyle
    let effects: EffectConfiguration
    
    struct BorderStyle {
        let type: BorderType
        let color: Color
        let opacity: Double
        let width: Double
    }
    
    struct EffectConfiguration {
        let hasShimmer: Bool
        let hasGlow: Bool
        let blurRadius: CGFloat
        let enableAnimations: Bool
        let speeds: AnimationSpeeds
        
        struct AnimationSpeeds {
            let shimmer: Double
            let glow: Double
            let hover: Double
        }
    }
    
    // Gradient-specific configs
    var linearGradient: (start: UnitPoint, end: UnitPoint)?
    var radialGradient: (centerX: Double, centerY: Double, startRadius: CGFloat, endRadius: CGFloat)?
    
    // Convert to GlassEffect
    func toGlassEffect() -> GlassEffect {
        GlassEffect(
            cornerRadius: cornerRadius,
            intensity: intensity,
            tintColor: tintColor,
            isInteractive: false,
            hasShimmer: effects.hasShimmer,
            hasGlow: effects.hasGlow,
            gradientType: gradientType,
            gradientStart: linearGradient?.start ?? .topLeading,
            gradientEnd: linearGradient?.end ?? .bottomTrailing,
            gradientCenterX: radialGradient?.centerX ?? 0.5,
            gradientCenterY: radialGradient?.centerY ?? 0.5,
            gradientStartRadius: radialGradient?.startRadius ?? 54,
            gradientEndRadius: radialGradient?.endRadius ?? 168,
            borderType: borderStyle.type,
            borderColor: borderStyle.color,
            borderOpacity: borderStyle.opacity,
            borderWidth: borderStyle.width,
            blurRadius: effects.blurRadius,
            enableAnimations: effects.enableAnimations,
            shimmerSpeed: effects.speeds.shimmer,
            glowSpeed: effects.speeds.glow,
            hoverAnimationSpeed: effects.speeds.hover
        )
    }
}


// MARK: - 2. Theme Presets (Composition over Configuration)

struct ThemePresets {
    static let defaultBorder = GlassConfiguration.BorderStyle(
        type: .gradient,
        color: .white,
        opacity: 0.39,
        width: 0.5
    )
    
    static let defaultAnimations = GlassConfiguration.EffectConfiguration.AnimationSpeeds(
        shimmer: 2.0,
        glow: 1.5,
        hover: 0.2
    )
    
    static let subtleEffects = GlassConfiguration.EffectConfiguration(
        hasShimmer: false,
        hasGlow: false,
        blurRadius: 1,
        enableAnimations: false,
        speeds: defaultAnimations
    )
    
    static let animatedEffects = GlassConfiguration.EffectConfiguration(
        hasShimmer: true,
        hasGlow: true,
        blurRadius: 3,
        enableAnimations: true,
        speeds: defaultAnimations
    )
    
    // Preset configurations
    static func header(tintColor: Color) -> GlassConfiguration {
        GlassConfiguration(
            cornerRadius: 20,
            intensity: 6.15,
            tintColor: tintColor,
            gradientType: .linear,
            borderStyle: defaultBorder,
            effects: subtleEffects,
            linearGradient: (start: UnitPoint(x: 0, y: 0), end: UnitPoint(x: 0.53, y: 0))
        )
    }
    
    static func card(tintColor: Color, cornerRadius: CGFloat = 20) -> GlassConfiguration {
        GlassConfiguration(
            cornerRadius: cornerRadius,
            intensity: 4.5,
            tintColor: tintColor,
            gradientType: .linear,
            borderStyle: defaultBorder,
            effects: subtleEffects,
            linearGradient: (start: UnitPoint(x: 0, y: 0), end: UnitPoint(x: 0.53, y: 0))
        )
    }
    
    static func button(tintColor: Color = .orange, cornerRadius: CGFloat = 20) -> GlassConfiguration {
        GlassConfiguration(
            cornerRadius: cornerRadius,
            intensity: 0.8,
            tintColor: tintColor,
            gradientType: .radial,
            borderStyle: GlassConfiguration.BorderStyle(type: .gradient, color: .white, opacity: 0.5, width: 0),
            effects: animatedEffects,
            radialGradient: (centerX: 0.5, centerY: 0.5, startRadius: 54, endRadius: 168)
        )
    }
    
    static func itemSelected(tintColor: Color, cornerRadius: CGFloat = 20) -> GlassConfiguration {
        GlassConfiguration(
            cornerRadius: cornerRadius,
            intensity: 1.8,
            tintColor: tintColor,
            gradientType: .radial,
            borderStyle: GlassConfiguration.BorderStyle(type: .gradient, color: .white, opacity: 0.5, width: 0),
            effects: animatedEffects,
            radialGradient: (centerX: 0.5, centerY: 0.5, startRadius: 54, endRadius: 168)
        )
    }
}

// MARK: - 3. Simplified Theme (Data only, no logic)

enum ThemeStyle {
    case header
    case card
    case button
    case itemSelected
}

struct ThemeContext {
    let style: ThemeStyle
    let intensity: Double
    let tintColor: Color?
    let cornerRadius: CGFloat?
    let material: Material?
    let height: CGFloat? // For header
    let animationID: (namespace: Namespace.ID, name: String)? // For selection
    let isSelected: Bool? // For selection
    
    // Convenience initializers
    static func header(intensity: Double = 0.8, tintColor: Color? = nil, height: CGFloat) -> ThemeContext {
        ThemeContext(
            style: .header,
            intensity: intensity,
            tintColor: tintColor,
            cornerRadius: nil,
            material: nil,
            height: height,
            animationID: nil,
            isSelected: nil
        )
    }
    
    static func card(intensity: Double = 0.8, tintColor: Color? = nil, cornerRadius: CGFloat? = nil, material: Material? = .ultraThinMaterial) -> ThemeContext {
        ThemeContext(
            style: .card,
            intensity: intensity,
            tintColor: tintColor,
            cornerRadius: cornerRadius,
            material: material,
            height: nil,
            animationID: nil,
            isSelected: nil
        )
    }
    
    static func button(intensity: Double = 0.8, tintColor: Color? = nil, cornerRadius: CGFloat? = nil, material: Material? = .ultraThinMaterial) -> ThemeContext {
        ThemeContext(
            style: .button,
            intensity: intensity,
            tintColor: tintColor,
            cornerRadius: cornerRadius,
            material: material,
            height: nil,
            animationID: nil,
            isSelected: nil
        )
    }
    
    static func itemSelected(
        tintColor: Color,
        intensity: Double = 0.8,
        cornerRadius: CGFloat? = nil,
        isSelected: Bool,
        animationID: Namespace.ID,
        animationName: String
    ) -> ThemeContext {
        ThemeContext(
            style: .itemSelected,
            intensity: intensity,
            tintColor: tintColor,
            cornerRadius: cornerRadius,
            material: nil,
            height: nil,
            animationID: (animationID, animationName),
            isSelected: isSelected
        )
    }
}

// MARK: - 4. Theme Resolver (Single Responsibility)

struct ThemeResolver {
    static func glassConfiguration(for context: ThemeContext) -> GlassConfiguration {
        let tintColor = context.tintColor ?? .white
        let cornerRadius = context.cornerRadius ?? 20
        
        switch context.style {
        case .header:
            return ThemePresets.header(tintColor: tintColor)
        case .card:
            return ThemePresets.card(tintColor: tintColor, cornerRadius: cornerRadius)
        case .button:
            return ThemePresets.button(tintColor: tintColor, cornerRadius: cornerRadius)
        case .itemSelected:
            return ThemePresets.itemSelected(tintColor: tintColor, cornerRadius: cornerRadius)
        }
    }
}

// MARK: - 5. Specialized ViewModifiers (Composition)

struct GlassBackgroundModifier: ViewModifier {
    let configuration: GlassConfiguration
    let material: Material?
    
    func body(content: Content) -> some View {
        if let material = material {
            content
                .modifier(configuration.toGlassEffect())
                .background(
                    material.opacity(0.9),
                    in: RoundedRectangle(cornerRadius: configuration.cornerRadius, style: .continuous)
                )
        } else {
            content
                .modifier(configuration.toGlassEffect())
        }
    }
}

struct HeaderBackgroundModifier: ViewModifier {
    let configuration: GlassConfiguration
    let height: CGFloat
    
    func body(content: Content) -> some View {
        content
            .frame(height: height)
            .background {
                Color.clear
                    .modifier(configuration.toGlassEffect())
                    .ignoresSafeArea(.all)
            }
    }
}

struct SelectionBackgroundModifier: ViewModifier {
    let configuration: GlassConfiguration
    let isSelected: Bool
    let animationID: Namespace.ID
    let animationName: String
    
    func body(content: Content) -> some View {
        content
            .background {
                if isSelected {
                    Color.clear
                        .modifier(configuration.toGlassEffect())
                        .matchedGeometryEffect(id: animationName, in: animationID)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isSelected)
    }
}

// MARK: - 6. Unified View Extension (Facade)

extension View {
    func themedBackground(_ context: ThemeContext) -> some View {
        let config = ThemeResolver.glassConfiguration(for: context)
        
        switch context.style {
        case .header:
            return AnyView(
                self.modifier(HeaderBackgroundModifier(
                    configuration: config,
                    height: context.height ?? 100
                ))
            )
            
        case .card, .button:
            return AnyView(
                self.modifier(GlassBackgroundModifier(
                    configuration: config,
                    material: context.material
                ))
            )
            
        case .itemSelected:
            guard let animationID = context.animationID,
                  let isSelected = context.isSelected else {
                return AnyView(self)
            }
            return AnyView(
                self.modifier(SelectionBackgroundModifier(
                    configuration: config,
                    isSelected: isSelected,
                    animationID: animationID.namespace,
                    animationName: animationID.name
                ))
            )
        }
    }
}

// MARK: - 7. Usage Examples

struct RefactoredExamples: View {
    @Namespace private var animation
    @State private var selectedIndex = 0
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("Header")
                .themedBackground(.header(height: 60))
            
            // Card with custom material
            Text("Card")
                .padding()
                .themedBackground(.card(
                    tintColor: .blue,
                    cornerRadius: 16,
                    material: .ultraThinMaterial
                ))
            
            // Button
            Button("Button") { }
                .padding()
                .themedBackground(.button(
                    tintColor: .orange,
                    cornerRadius: 25
                ))
            
            // Item Selection
            HStack {
                ForEach(0..<3) { index in
                    Text("Item \(index)")
                        .padding()
                        .themedBackground(.itemSelected(
                            tintColor: .purple,
                            isSelected: selectedIndex == index,
                            animationID: animation,
                            animationName: "selection"
                        ))
                        .onTapGesture {
                            selectedIndex = index
                        }
                }
            }
        }
    }
}

// MARK: - 8. Dark Mode Support Extension

extension GlassConfiguration {
    func adjusted(for colorScheme: ColorScheme) -> GlassConfiguration {
        var adjusted = self
        
        // Adjust intensity based on color scheme
        adjusted.intensity = colorScheme == .dark ? intensity * 1.2 : intensity * 0.9
        
        // Adjust border opacity
        let borderOpacity = colorScheme == .dark ? borderStyle.opacity * 1.1 : borderStyle.opacity * 0.9
        adjusted.borderStyle = BorderStyle(
            type: borderStyle.type,
            color: borderStyle.color,
            opacity: borderOpacity,
            width: borderStyle.width
        )
        
        return adjusted
    }
}

// Dark mode aware modifier
struct DarkModeAwareThemeModifier: ViewModifier {
    let context: ThemeContext
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        let baseConfig = ThemeResolver.glassConfiguration(for: context)
        //let adjustedConfig = baseConfig.adjusted(for: colorScheme)
        let adjustedContext = context // Could create adjusted context if needed
        
        content.themedBackground(adjustedContext)
    }
}

extension View {
    func themedBackgroundWithDarkMode(_ context: ThemeContext) -> some View {
        self.modifier(DarkModeAwareThemeModifier(context: context))
    }
}
