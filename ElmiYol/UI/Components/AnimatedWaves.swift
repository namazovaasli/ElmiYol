//
//  AnimatedWaves.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 22.10.26.
//

import SwiftUI

struct AnimatedWaves: View {
    var body: some View {
        TimelineView(.animation) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            ZStack {
                WaveShape(amplitude: 22, baseline: 0.25, phase: t / 6 * 2 * .pi)
                    .fill(Color(red: 0.85, green: 0.91, blue: 0.99).opacity(0.5))
                WaveShape(amplitude: 18, baseline: 0.42, phase: t / 8 * 2 * .pi + 1.5)
                    .fill(Color(red: 0.72, green: 0.84, blue: 0.98).opacity(0.7))
                WaveShape(amplitude: 25, baseline: 0.60, phase: t / 10 * 2 * .pi + 3)
                    .fill(Color(red: 0.55, green: 0.74, blue: 0.96))
            }
        }
        .allowsHitTesting(false)
    }
}

struct WaveShape: Shape {
    var amplitude: CGFloat
    var baseline: CGFloat
    var phase: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard rect.width > 0 else { return path }

        let baseY = rect.height * baseline
        path.move(to: CGPoint(x: 0, y: baseY))

        var x: CGFloat = 0
        while x <= rect.width {
            let angle = Double(x / rect.width) * 2 * .pi + phase
            path.addLine(to: CGPoint(x: x, y: baseY + amplitude * CGFloat(sin(angle))))
            x += 6
        }

        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}
