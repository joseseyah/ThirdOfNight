//
//  TasbihCounterView.swift
//  Night Prayers
//
//  Full-screen Tasbih counter with animated beads
//
import SwiftUI

struct TasbihCounterView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var count: Int = 0
    @State private var loop: Int = 1
    @State private var target: Int = 33
    @State private var isEditingTarget: Bool = false
    @State private var hapticEnabled: Bool = true
    @State private var beadsOffset: CGFloat = 0
    @State private var showResetConfirmation: Bool = false
    
    @AppStorage("tasbih_haptic_enabled") private var savedHapticEnabled: Bool = true
    
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        ZStack {
            Color.appBg.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar with back button and settings
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.15))
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.textPrimaryLight)
                        }
                        .frame(width: 44, height: 44)
                        .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Text("Tasbih")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.textPrimaryLight)
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button {
                            showResetConfirmation = true
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(width: 36, height: 36)
                                
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.textPrimaryLight)
                            }
                            .frame(width: 44, height: 44)
                            .contentShape(Circle())
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            hapticEnabled.toggle()
                            savedHapticEnabled = hapticEnabled
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(width: 36, height: 36)
                                
                                Image(systemName: hapticEnabled ? "waveform" : "waveform.slash")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.textPrimaryLight)
                            }
                            .frame(width: 44, height: 44)
                            .contentShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 20)
                
                Spacer()
                
                // Main counter display
                VStack(spacing: 24) {
                    Text("\(count)")
                        .font(.system(size: 80, weight: .bold, design: .rounded))
                        .foregroundColor(.textPrimaryLight)
                        .shadow(color: Color.accentPurple.opacity(0.3), radius: 8, x: 0, y: 0)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: count)
                    
                    // Animated beads string
                    BeadsStringView(offset: beadsOffset, count: count, target: target)
                        .frame(height: 80)
                        .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // Loop progress
                VStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Text("Loop \(loop)")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.textPrimaryLight)
                        
                        Text("/\(target)")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.textSecondaryLight)
                        
                        Button {
                            isEditingTarget = true
                        } label: {
                            Image(systemName: "pencil")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.accentPurple)
                                .frame(width: 20, height: 20)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.bottom, 40)
                
                // Haptic counting button
                Button {
                    incrementCount()
                } label: {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.accentPurple.opacity(0.4), Color.accentPurple.opacity(0.25)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                        
                        Circle()
                            .stroke(Color.accentPurple.opacity(0.7), lineWidth: 2.5)
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.buttonText)
                    }
                    .shadow(color: Color.accentPurple.opacity(0.5), radius: 24, x: 0, y: 12)
                    .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 5)
                }
                .buttonStyle(TasbihButtonStyle())
                .padding(.bottom, 50)
            }
        }
        .sheet(isPresented: $isEditingTarget) {
            TargetEditSheet(target: $target)
        }
        .confirmationDialog("Reset Counter", isPresented: $showResetConfirmation, titleVisibility: .visible) {
            Button("Reset", role: .destructive) {
                resetCounter()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will reset your current count to 0.")
        }
        .onAppear {
            hapticEnabled = savedHapticEnabled
            hapticGenerator.prepare()
        }
    }
    
    private func incrementCount() {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
            count += 1
            
            // Update beads offset for visual feedback (not used for scrolling anymore)
            let progress = CGFloat(count % target) / CGFloat(target)
            beadsOffset = progress * 100
            
            // Check if loop completed
            if count % target == 0 && count > 0 {
                loop += 1
                // Reset beads position with animation
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    beadsOffset = 0
                }
            }
        }
        
        // Haptic feedback
        if hapticEnabled {
            hapticGenerator.impactOccurred()
        }
    }
    
    private func resetCounter() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            count = 0
            loop = 1
            beadsOffset = 0
        }
    }
}

// MARK: - Beads String View
struct BeadsStringView: View {
    let offset: CGFloat
    let count: Int
    let target: Int
    
    private let beadSize: CGFloat = 24
    private let beadSpacing: CGFloat = 8
    private let visibleBeads: Int = 9 // Number of beads visible on screen
    
    var body: some View {
        GeometryReader { geometry in
            let totalBeads = target // Show all beads up to target
            let currentBeadIndex = count % target // Current active bead (0-indexed)
            
            // Calculate offset to center the active bead
            let scrollOffset: CGFloat = {
                if totalBeads <= visibleBeads {
                    // If we have fewer beads than visible, center them
                    let totalWidth = CGFloat(totalBeads) * (beadSize + beadSpacing) - beadSpacing
                    return (geometry.size.width - totalWidth) / 2
                } else {
                    // Calculate how much to scroll to center the active bead
                    let centerPosition = geometry.size.width / 2
                    let activeBeadCenterX = CGFloat(currentBeadIndex) * (beadSize + beadSpacing) + beadSize / 2
                    let offset = centerPosition - activeBeadCenterX
                    
                    // Clamp to prevent scrolling past the edges
                    let totalWidth = CGFloat(totalBeads) * (beadSize + beadSpacing) - beadSpacing
                    let maxOffset: CGFloat = 0 // Can't scroll right past start
                    let minOffset = geometry.size.width - totalWidth // Can't scroll left past end
                    return max(minOffset, min(maxOffset, offset))
                }
            }()
            
            let baseX = scrollOffset + beadSize / 2
            let y = geometry.size.height / 2
            let curveHeight: CGFloat = 30
            
            ZStack {
                // String/thread - draw smooth curved path
                Path { path in
                    if totalBeads > 0 {
                        let firstX = baseX
                        let firstProgress: CGFloat = 0
                        let firstY = y - curveHeight * sin(firstProgress * .pi)
                        path.move(to: CGPoint(x: firstX, y: firstY))
                        
                        // Create a smooth curved path connecting all bead positions
                        for i in 1..<totalBeads {
                            let x = baseX + CGFloat(i) * (beadSize + beadSpacing)
                            let progress = totalBeads > 1 ? CGFloat(i) / CGFloat(totalBeads - 1) : 0
                            let controlY = y - curveHeight * sin(progress * .pi)
                            path.addLine(to: CGPoint(x: x, y: controlY))
                        }
                    }
                }
                .stroke(Color.accentPurple.opacity(0.6), lineWidth: 2.5)
                
                // Beads - draw all beads
                ForEach(0..<totalBeads, id: \.self) { index in
                    let x = baseX + CGFloat(index) * (beadSize + beadSpacing)
                    let progress = totalBeads > 1 ? CGFloat(index) / CGFloat(totalBeads - 1) : 0
                    let beadY = y - curveHeight * sin(progress * .pi)
                    
                    let isActive = index == currentBeadIndex
                    let isCompleted = index < currentBeadIndex
                    
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    isActive ? Color.accentPurple : (isCompleted ? Color.accentPurple.opacity(0.7) : Color.white.opacity(0.2)),
                                    isActive ? Color.accentPurple.opacity(0.9) : (isCompleted ? Color.accentPurple.opacity(0.5) : Color.white.opacity(0.1))
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: beadSize, height: beadSize)
                        .overlay(
                            Circle()
                                .stroke(
                                    isActive ? Color.buttonText.opacity(0.3) : (isCompleted ? Color.accentPurple.opacity(0.6) : Color.stroke.opacity(0.5)),
                                    lineWidth: isActive ? 2 : 1.5
                                )
                        )
                        .shadow(
                            color: isActive ? Color.accentPurple.opacity(0.6) : (isCompleted ? Color.accentPurple.opacity(0.3) : Color.clear),
                            radius: isActive ? 10 : (isCompleted ? 6 : 0)
                        )
                        .position(x: x, y: beadY)
                        .scaleEffect(isActive ? 1.25 : (isCompleted ? 1.1 : 1.0))
                }
            }
        }
    }
}

// MARK: - Button Style
struct TasbihButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Target Edit Sheet
struct TargetEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var target: Int
    @State private var tempTarget: String = ""
    
    var body: some View {
        ZStack {
            Color.cardBg.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Capsule()
                    .fill(Color.stroke)
                    .frame(width: 44, height: 5)
                    .padding(.top, 8)
                
                Text("Set Loop Target")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                    .padding(.top, 8)
                
                TextField("Target", text: $tempTarget)
                    .keyboardType(.numberPad)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.stroke, lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                
                Text("Enter the number of counts per loop (e.g., 33, 99)")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                Button {
                    if let newTarget = Int(tempTarget), newTarget > 0 {
                        target = newTarget
                        dismiss()
                    }
                } label: {
                    Text("Save")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.buttonText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                colors: [Color.accentPurple, Color.accentPurple.opacity(0.9)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: Color.accentPurple.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
            }
        }
        .presentationDetents([.fraction(0.5)])
        .presentationDragIndicator(.visible)
        .onAppear {
            tempTarget = "\(target)"
        }
    }
}

#Preview {
    TasbihCounterView()
}

