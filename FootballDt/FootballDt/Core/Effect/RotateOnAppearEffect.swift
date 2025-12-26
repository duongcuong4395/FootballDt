//
//  RotateOnAppearEffect.swift
//  FootballDt
//
//  Created by Macbook on 26/12/25.
//

import SwiftUI

enum RotationAxis {
    case x, y
}


struct RotateOnAppearModifier: ViewModifier {
    @State private var isRotated = false
    @State private var hasAppeared = false
    let angle: Double
    let duration: Double
    let axis: RotationAxis
    
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(isRotated ? 0 : angle),
                axis: axis == .x ? (x: 1.0, y: 0.0, z: 0.0) : (x: 0.0, y: 1.0, z: 0.0)
            )
            .onAppear{
                withAnimation(.easeInOut(duration: duration)) {
                    isRotated = true
                }
            }
    }
}

struct RotateOnAppearModifier_New: ViewModifier {
    @State private var isRotated = false
    @State private var hasAppeared = false
    let angle: Double
    let duration: Double
    let direction: AnimationDirection

    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(isRotated ? 0 : angle),
                axis: axisVector(for: direction)
            )
            .onAppear {
                withAnimation(.easeInOut(duration: duration)) {
                    isRotated = true
                }
            }
    }

    private func axisVector(for direction: AnimationDirection) -> (x: CGFloat, y: CGFloat, z: CGFloat) {
        switch direction {
        case .leftToRight, .rightToLeft:
            return (x: 0.0, y: 1.0, z: 0.0) // Y-axis rotation (vertical flip)
        case .topToBottom, .bottomToTop:
            return (x: 1.0, y: 0.0, z: 0.0) // X-axis rotation (horizontal flip)
        }
    }
}

extension View {
    func rotateOnAppear(angle: Double = -70, duration: Double = 0.5, axis: RotationAxis = .x) -> some View {
        self.modifier(RotateOnAppearModifier(angle: angle, duration: duration, axis: axis))
    }
}

