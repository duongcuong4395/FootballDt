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



struct SlideInEffect: ViewModifier {
    @Binding var isVisible: Bool
    var delay: Double
    var repeatAnimationOnApear: Bool
    var direction: AnimationDirection
    
    // ✅ Use @State to track animation state
    @State private var hasAppeared = false
    
    func body(content: Content) -> some View {
        content
            .offset(x: xOffset, y: yOffset)
            .opacity(opacity)
            .onAppear {
                
                if repeatAnimationOnApear {
                    // ✅ Reset animation state on appear
                    hasAppeared = false
                    // ✅ Trigger animation after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            hasAppeared = true
                        }
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
    func slideInEffect(isVisible: Binding<Bool>, delay: Double, repeatAnimationOnApear: Bool = true, direction: AnimationDirection) -> some View {
        return self.modifier(SlideInEffect(isVisible: isVisible, delay: delay, repeatAnimationOnApear: repeatAnimationOnApear, direction: direction))
    }

}



// MARK: New

@MainActor
final class AnimationStateManager: ObservableObject {
    @Published private(set) var visibleIndices: Set<Int> = []
    
    func setVisible(_ index: Int) {
        guard !visibleIndices.contains(index) else { return }
        visibleIndices.insert(index)
    }
    
    func reset(count: Int) {
        visibleIndices.removeAll()
    }
    
    func isVisible(_ index: Int) -> Bool {
        visibleIndices.contains(index)
    }
}

struct OptimizedSlideEffect: ViewModifier {
    let index: Int
    let delay: Double
    let direction: AnimationDirection
    
    @ObservedObject var animationManager: AnimationStateManager
    @State private var localAppeared = false
    
    func body(content: Content) -> some View {
        let isVisible = animationManager.isVisible(index)
        
        content
            .offset(x: xOffset(isVisible), y: yOffset(isVisible))
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                // ✅ Only trigger once per lifecycle
                guard !localAppeared else { return }
                localAppeared = true
                
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    animationManager.setVisible(index)
                }
            }
    }
    
    private func xOffset(_ isVisible: Bool) -> CGFloat {
        switch direction {
        case .leftToRight: return isVisible ? 0 : -50
        case .rightToLeft: return isVisible ? 0 : 50
        default: return 0
        }
    }
    
    private func yOffset(_ isVisible: Bool) -> CGFloat {
        switch direction {
        case .topToBottom: return isVisible ? 0 : -50
        case .bottomToTop: return isVisible ? 0 : 50
        default: return 0
        }
    }
}
