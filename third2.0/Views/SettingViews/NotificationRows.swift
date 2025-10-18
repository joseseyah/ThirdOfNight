//
//  NotificationRows.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 18/10/2025.
//
import SwiftUI


struct NotificationRows: View {
    @State private var permission: UNAuthorizationStatus = .notDetermined

    @AppStorage("notif_daily_enabled") private var dailyEnabled = false
    @AppStorage("notif_daily_time") private var dailyTimeRaw: Double = Date().timeIntervalSinceReferenceDate

    @AppStorage("notif_prayer_enabled") private var prayerEnabled = false

    private var dailyTimeBinding: Binding<Date> {
            Binding(
                get: { Date(timeIntervalSinceReferenceDate: dailyTimeRaw) },
                set: { newValue in
                    dailyTimeRaw = newValue.timeIntervalSinceReferenceDate
                }
            )
        }

    var body: some View {
        VStack(spacing: 0) {
            Row(icon: "bell.badge", title: "Allow notifications", trailing: {
                PermissionBadge(status: permission)
            })
            .contentShape(Rectangle())
            .onTapGesture { openSystemSettings() }
            .task { permission = await currentPermission() }

            Divider().overlay(Color.stroke)

            ToggleRow(icon: "sun.max", title: "Daily reminder", isOn: $dailyEnabled)
                .onChange(of: dailyEnabled) { _, new in
                    if new { requestPermissionIfNeeded() }
                }

          if dailyEnabled {
                          TimePickerRow(title: "Reminder time", date: dailyTimeBinding) // ⬅️ use binding
                              .transition(.opacity.combined(with: .move(edge: .top)))
                              .padding(.top, 10)
                      }

            Divider().overlay(Color.stroke).padding(.top, dailyEnabled ? 10 : 0)

            ToggleRow(icon: "sparkles", title: "Prayer-time alerts", isOn: $prayerEnabled)
                .onChange(of: prayerEnabled) { _, new in
                    if new { requestPermissionIfNeeded() }
                }
        }
        .onAppear {
            Task { permission = await currentPermission() }
        }
    }

    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    private func requestPermissionIfNeeded() {
        Task {
            let status = await currentPermission()
            if status == .notDetermined {
                do {
                    let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
                    permission = granted ? .authorized : .denied
                } catch {
                    permission = .denied
                }
            }
        }
    }

    private func currentPermission() async -> UNAuthorizationStatus {
        await withCheckedContinuation { cont in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                cont.resume(returning: settings.authorizationStatus)
            }
        }
    }
}
