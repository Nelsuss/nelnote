import SwiftUI

// MARK: - 인트로: 캐릭터가 동그라미 안에서 쏙 올라오고, 로고가 한 획씩 그려진 뒤 O에 빨간 점이 찍힌다

struct IntroView: View {
    let onFinish: () -> Void

    @State private var badgeIn = false
    @State private var peek = false
    @State private var drawn = false
    @State private var dot = false
    @State private var hop = false
    @State private var fade = false
    @State private var finished = false

    private let size: CGFloat = 156

    private var characterOffset: CGFloat {
        var y: CGFloat = peek ? 0 : size * 1.5 * 0.62
        if hop {
            y -= size * 0.05
        }
        return y
    }

    var body: some View {
        ZStack {
            Theme.paper.ignoresSafeArea()
            VStack(spacing: 28) {
                CharacterBadge(size: size, imageOffsetY: characterOffset)
                    .shadow(color: Color.blue.opacity(0.25), radius: 16, x: 0, y: 10)
                    .scaleEffect(badgeIn ? 1 : 0.35)
                    .opacity(badgeIn ? 1 : 0)
                Wordmark(height: 32, drawn: drawn, dotShown: dot, animated: true)
            }
            .offset(y: -30)
        }
        .opacity(fade ? 0 : 1)
        .contentShape(Rectangle())
        .onTapGesture { finish() }
        .onAppear { play() }
    }

    private func play() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.6)) {
            badgeIn = true
        }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.16)) {
            peek = true
        }
        drawn = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.5)) {
                dot = true
            }
            withAnimation(.easeInOut(duration: 0.2)) {
                hop = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    hop = false
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
            finish()
        }
    }

    private func finish() {
        if finished {
            return
        }
        finished = true
        withAnimation(.easeOut(duration: 0.35)) {
            fade = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            onFinish()
        }
    }
}
