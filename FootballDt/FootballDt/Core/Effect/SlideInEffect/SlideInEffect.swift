//
//  SlideInEffect.swift
//  FootballDt
//
//  Created by Macbook on 26/12/25.
//

import SwiftUI

enum AnimationDirection {
    case leftToRight, rightToLeft, topToBottom, bottomToTop
}

struct SlideInEffect_OldVersion: ViewModifier {
    @Binding var isVisible: Bool
    var delay: Double
    var direction: AnimationDirection
    
    func body(content: Content) -> some View {
        content
            .offset(x: xOffset, y: yOffset)
            .opacity(opacity)
            .animation(
                Animation.easeInOut(duration: 0.5)
                    .delay(delay), value: UUID()
            )
    }
    
    private var opacity: Double {
        return isVisible ? 1 : 0
    }
    
    private var xOffset: CGFloat {
        switch direction {
        case .leftToRight:
            return isVisible ? 0 : -UIScreen.main.bounds.width
        case .rightToLeft:
            return isVisible ? 0 : UIScreen.main.bounds.width
        case .topToBottom, .bottomToTop:
            return 0
        }
    }
    
    private var yOffset: CGFloat {
        switch direction {
        case .topToBottom:
            return isVisible ? 0 : -UIScreen.main.bounds.height
        case .bottomToTop:
            return isVisible ? 0 : UIScreen.main.bounds.height
        case .leftToRight, .rightToLeft:
            return 0
        }
    }
}




struct SlideInEffect: ViewModifier {
    @Binding var isVisible: Bool
    var delay: Double
    var direction: AnimationDirection
    
    // ✅ Use @State to track animation state
    @State private var hasAppeared = false
    
    func body(content: Content) -> some View {
        content
            .offset(x: xOffset, y: yOffset)
            .opacity(opacity)
            .onAppear {
                // ✅ Reset animation state on appear
                hasAppeared = false
                // ✅ Trigger animation after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        hasAppeared = true
                    }
                }
            }
            .onChange(of: isVisible) { newValue in
                // ✅ Sync with parent state
                if newValue {
                    withAnimation(.easeInOut(duration: 0.5).delay(delay)) {
                        hasAppeared = true
                    }
                }
            }
    }
    
    private var opacity: Double {
        return hasAppeared && isVisible ? 1 : 0
    }
    
    private var xOffset: CGFloat {
        // ✅ Use hasAppeared instead of isVisible for offset
        let shouldShow = hasAppeared && isVisible
        
        switch direction {
        case .leftToRight:
            return shouldShow ? 0 : -UIScreen.main.bounds.width
        case .rightToLeft:
            return shouldShow ? 0 : UIScreen.main.bounds.width
        case .topToBottom, .bottomToTop:
            return 0
        }
    }
    
    private var yOffset: CGFloat {
        let shouldShow = hasAppeared && isVisible
        
        switch direction {
        case .topToBottom:
            return shouldShow ? 0 : -UIScreen.main.bounds.height
        case .bottomToTop:
            return shouldShow ? 0 : UIScreen.main.bounds.height
        case .leftToRight, .rightToLeft:
            return 0
        }
    }
}

extension View {
    func slideInEffect(isVisible: Binding<Bool>, delay: Double, direction: AnimationDirection) -> some View {
        return self.modifier(SlideInEffect(isVisible: isVisible, delay: delay, direction: direction))
    }

    func slideInEffect_OldVersion(isVisible: Binding<Bool>, delay: Double, direction: AnimationDirection) -> some View {
        return self.modifier(SlideInEffect_OldVersion(isVisible: isVisible, delay: delay, direction: direction))
    }
}
