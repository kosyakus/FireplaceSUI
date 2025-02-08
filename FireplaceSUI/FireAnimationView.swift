//
//  FireAnimationView.swift
//  FireplaceSUI
//
//  Created by Natalia Sinitsyna on 05.12.2024.
//

import SwiftUI

struct CampfireView: View {
    
    @State private var stars: [Star] = (1...50).map { _ in Star.random() }
    
    var body: some View {
        
        ZStack {
            // Звёздное небо
            Color.black.edgesIgnoringSafeArea(.all)
                .overlay(
                    GeometryReader { geometry in
                        ForEach(Array(stars.enumerated()), id: \.1.id) { index, star in
                            Circle()
                                .fill(Color.white.opacity(star.opacity))
                                .frame(width: star.size, height: star.size)
                                .position(
                                    x: star.position.x * geometry.size.width,
                                    y: star.position.y * geometry.size.height
                                )
                                .onAppear {
                                    animateStar(at: index)
                                }
                        }
                    }
                )
            
            VStack {
                ZStack(alignment: .bottom) {
                    // Flames
                    FlameView()
                        .padding(.bottom, -20)
                    // Logs
                    LogsView()
                }
            }
            .padding(.top, 400)
        }
    }
    
    // Анимация звёзд
    func animateStar(at index: Int) {
        let duration = Double.random(in: 2...4)
        Timer.scheduledTimer(withTimeInterval: duration, repeats: true) { _ in
            withAnimation(Animation.easeInOut(duration: duration)) {
                stars[index].opacity = Double.random(in: 0.3...1.0)
            }
        }
    }
}

struct LogsView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color("BrownLight"))
                .frame(width: 300, height: 40)
                .rotationEffect(.degrees(-20))
            
            RoundedRectangle(cornerRadius: 5)
                .fill(Color("BrownDark"))
                .frame(width: 300, height: 40)
                .rotationEffect(.degrees(20))
        }
        .offset(y: 50)
    }
}


struct FlameView: View {
    @State private var flames: [Flame] = []
    let animationTime: Double = 2.5
    
    var body: some View {
        ZStack {
            ForEach(flames) { flame in
                RoundedRectangle(cornerRadius: flame.isCircle ? 50 : 10)
                    .fill(flame.color)
                    .frame(width: flame.size, height: flame.size)
                    .rotationEffect(.degrees(45))
                    .offset(flame.offset)
                    .opacity(flame.opacity)
            }
        }
        .onAppear {
            startFlameCycle()
        }
    }
    
    private func startFlameCycle() {
        // Добавляем ромб каждые 0.5 секунды
        Timer.scheduledTimer(withTimeInterval: animationTime / 4, repeats: true) { _ in
            addFlame()
        }
    }
    
    private func addFlame() {
        let id = UUID()
        let flame = Flame(id: id)
        
        // Начальная фаза
        flames.append(flame)
        
        // Рост ромба
        withAnimation(Animation.easeOut(duration: 0.3)) {
            if let index = flames.firstIndex(where: { $0.id == id }) {
                flames[index].size = 150
            }
        }
        
        // Движение вверх, уменьшение и изменение цвета
        withAnimation(Animation.easeInOut(duration: animationTime).delay(0.3)) {
            if let index = flames.firstIndex(where: { $0.id == id }) {
                flames[index].offset = CGSize(width: Double.random(in: -50...50), height: -150)
                flames[index].size = 0
                //                flames[index].opacity = 0
                flames[index].color = .red
                flames[index].isCircle = true
            }
        }
        
        // Удаление старого ромба
        DispatchQueue.main.asyncAfter(deadline: .now() + animationTime + 0.3) {
            flames.removeAll { $0.id == id }
        }
    }
}

struct Flame: Identifiable {
    let id: UUID
    var size: CGFloat = 0
    var offset: CGSize = .zero
    var opacity: Double = 1
    var color: Color = .yellow
    var isCircle: Bool = false
}

struct Star: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var opacity: Double
    
    static func random() -> Star {
        return Star(
            position: CGPoint(x: CGFloat.random(in: 0...1), y: CGFloat.random(in: 0...0.5)),
            size: CGFloat.random(in: 2...4),
            opacity: Double.random(in: 0.3...1.0)
        )
    }
}

#Preview {
    CampfireView()
}
