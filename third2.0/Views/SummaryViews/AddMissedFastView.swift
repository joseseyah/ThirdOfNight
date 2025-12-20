//
//  AddMissedFastView.swift
//  Night Prayers
//
//  Full-screen view for adding a missed fast with date picker
//

import SwiftUI
import SwiftData

struct AddMissedFastView: View {
    @Binding var isPresented: Bool
    @Environment(\.modelContext) private var modelContext
    @State private var selectedDate: Date = Date()
    @State private var showDatePicker: Bool = false
    @State private var isSaving: Bool = false
    
    init(isPresented: Binding<Bool> = .constant(false)) {
        _isPresented = isPresented
    }
    
    private func weekdayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    private func saveMissedFast() async {
        isSaving = true
        
        // Generate dayKey for the selected date
        let day = Calendar.autoupdatingCurrent.startOfDay(for: selectedDate)
        let c = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day], from: day)
        let y = c.year ?? 0, m = c.month ?? 0, d = c.day ?? 0
        let dayKey = String(format: "%04d-%02d-%02d", y, m, d)
        
        // Check Firebase first to see if this date already exists
        do {
            let existsInFirebase = try await MissedFastSyncService.shared.missedFastExists(dayKey: dayKey)
            
            if existsInFirebase {
                // Show error - date already exists in Firebase
                await MainActor.run {
                    print("⚠️ A missed fast for \(dayKey) already exists in Firebase")
                    isSaving = false
                    // TODO: Show user-friendly error message
                }
                return
            }
        } catch {
            // If we can't check Firebase (e.g., offline), continue with local check
            print("⚠️ Could not check Firebase (may be offline): \(error.localizedDescription)")
        }
        
        // Check if a missed fast already exists locally for this day
        let predicate = #Predicate<MissedFast> { $0.dayKey == dayKey }
        let descriptor = FetchDescriptor<MissedFast>(predicate: predicate)
        
        do {
            let existing = try modelContext.fetch(descriptor)
            
            if let existingFast = existing.first {
                // Update existing local record
                existingFast.date = day
                existingFast.createdAt = Date()
                existingFast.isSynced = false // Mark as needing sync
                
                try modelContext.save()
                print("✅ Updated existing missed fast for day: \(dayKey)")
                
                // Sync to Firebase
                do {
                    try await MissedFastSyncService.shared.syncMissedFast(existingFast)
                    existingFast.isSynced = true
                    try modelContext.save()
                    print("✅ Synced updated missed fast to Firebase")
                } catch {
                    print("⚠️ Failed to sync to Firebase (will retry when online): \(error.localizedDescription)")
                }
            } else {
                // Create new MissedFast model
                let missedFast = MissedFast(date: selectedDate)
                
                // Save to SwiftData
                modelContext.insert(missedFast)
                
                try modelContext.save()
                print("✅ Saved missed fast to SwiftData: \(missedFast.dayKey)")
                
                // Sync to Firebase (will work offline and sync when connection is restored)
                do {
                    try await MissedFastSyncService.shared.syncMissedFast(missedFast)
                    missedFast.isSynced = true
                    try modelContext.save()
                    print("✅ Synced missed fast to Firebase")
                } catch {
                    print("⚠️ Failed to sync to Firebase (will retry when online): \(error.localizedDescription)")
                    // Don't throw - Firestore will retry automatically when connection is restored
                }
            }
            
            // Dismiss view after successful save
            await MainActor.run {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    isPresented = false
                }
            }
        } catch {
            print("❌ Failed to save missed fast: \(error.localizedDescription)")
            isSaving = false
        }
    }
    
    var body: some View {
        ZStack {
            Color.appBg.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar with back button and header
                HStack {
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                            isPresented = false
                        }
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
                    
                    Text("Add Missed Fast")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.textPrimaryLight)
                    
                    Spacer()
                    
                    // Spacer to balance the back button
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 20)
                
                Spacer()
                
                // Main content
                VStack(spacing: 32) {
                    // Date display
                    VStack(spacing: 16) {
                        Text("Select Date")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.textSecondaryLight)
                        
                        Button {
                            showDatePicker = true
                        } label: {
                            VStack(spacing: 8) {
                                Text(selectedDate, style: .date)
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .foregroundColor(.textPrimaryLight)
                                
                                Text(weekdayString(from: selectedDate))
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                    .foregroundColor(.accentPurple)
                            }
                            .padding(.vertical, 24)
                            .padding(.horizontal, 32)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(Color.accentPurple.opacity(0.15))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                                            .stroke(Color.accentPurple.opacity(0.4), lineWidth: 2)
                                    )
                            )
                        }
                        .buttonStyle(DateButtonStyle())
                    }
                    
                    // Info text
                    Text("Select the date when you missed your fast")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.textSecondaryLight)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // Add button
                Button {
                    Task {
                        await saveMissedFast()
                    }
                } label: {
                    HStack(spacing: 10) {
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .buttonText))
                                .scaleEffect(0.9)
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        
                        Text(isSaving ? "Saving..." : "Add Fast")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.buttonText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        LinearGradient(
                            colors: [Color.accentPurple, Color.accentPurple.opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: Color.accentPurple.opacity(0.4), radius: 12, x: 0, y: 6)
                }
                .buttonStyle(AddFastButtonStyle())
                .disabled(isSaving)
                .padding(.horizontal, 20)
                .padding(.bottom, 50)
            }
        }
        .sheet(isPresented: $showDatePicker) {
            DatePickerSheet(selectedDate: $selectedDate)
        }
    }
}

// MARK: - Date Button Style
struct DateButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Add Fast Button Style
struct AddFastButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Date Picker Sheet
struct DatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date
    
    var body: some View {
        ZStack {
            // Use white/very light background for maximum contrast
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Drag indicator
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 44, height: 5)
                    .padding(.top, 12)
                
                // Title
                Text("Select Date")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                
                // Date Picker with better contrast - use accent color for selection
                // Restrict to dates up to today (no future dates)
                DatePicker(
                    "",
                    selection: $selectedDate,
                    in: ...Date(), // Only allow dates up to today
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .tint(.accentPurple) // Use purple for selected row highlight
                
                Spacer()
                
                // Done button
                Button {
                    dismiss()
                } label: {
                    Text("Done")
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
                .padding(.bottom, 34)
            }
        }
        .preferredColorScheme(.light) // Force light color scheme for dark text on white background
        .presentationDetents([.fraction(0.65)])
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled(false)
    }
}

#Preview {
    AddMissedFastView(isPresented: .constant(true))
}

