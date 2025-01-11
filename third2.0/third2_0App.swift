import SwiftUI
import SwiftData
import FirebaseCore
import UserNotifications
import BackgroundTasks
import AVFoundation
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        requestNotificationPermission()
        configureAudioSession()

        // Set up background fetch interval
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)

        // Register the background task
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.yourapp.updatePrayerTimes", using: nil) { task in
            self.handleBackgroundTask(task: task as! BGAppRefreshTask)
        }

        return true
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else if let error = error {
                print("Notification permission denied: \(error.localizedDescription ?? "Unknown error")")
            }
        }
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
            print("Audio session configured for background playback.")
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }

    // Handle background fetch for prayer times
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        updatePrayerTimes { result in
            switch result {
            case .success:
                completionHandler(.newData)
            case .failure:
                completionHandler(.failed)
            }
        }
    }

    // Handle Background Task for updating prayer times
    private func handleBackgroundTask(task: BGAppRefreshTask) {
        scheduleBackgroundTask() // Reschedule for the next day
        
        updatePrayerTimes { result in
            switch result {
            case .success:
                task.setTaskCompleted(success: true)
            case .failure:
                task.setTaskCompleted(success: false)
            }
        }
    }

    // Schedule the next background task
    public func scheduleBackgroundTask() {
        let request = BGAppRefreshTaskRequest(identifier: "com.yourapp.updatePrayerTimes")
        request.earliestBeginDate = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400)) // Midnight of the next day

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Failed to schedule background task: \(error.localizedDescription)")
        }
    }

    // Function to fetch and update prayer times
    private func updatePrayerTimes(completion: @escaping (Result<Void, Error>) -> Void) {
        let useMosqueTimetable = UserDefaults.standard.bool(forKey: "useMosqueTimetable")
        let selectedMosque = UserDefaults.standard.string(forKey: "selectedMosque") ?? ""
        let selectedCity = UserDefaults.standard.string(forKey: "selectedCity") ?? ""

        let db = Firestore.firestore()

        if useMosqueTimetable {
            // Fetch prayer times for the selected mosque
            let docRef = db.collection("Mosques").document(selectedMosque)
            docRef.getDocument { document, error in
                if let document = document, document.exists {
                    if let prayerTimes = document.data()?["data"] as? [[String: String]] {
                        // Save updated prayer times
                        UserDefaults.standard.set(prayerTimes, forKey: "prayerTimes")
                        completion(.success(()))
                    } else {
                        completion(.failure(NSError(domain: "No data found", code: 1, userInfo: nil)))
                    }
                } else {
                    completion(.failure(error ?? NSError(domain: "Failed to fetch", code: 1, userInfo: nil)))
                }
            }
        } else {
            // Fetch prayer times for the selected city
            let docRef = db.collection("prayerTimes").document(selectedCity)
            docRef.getDocument { document, error in
                if let document = document, document.exists {
                    if let prayerTimes = document.data()?["prayerTimes"] as? [[String: Any]] {
                        // Save updated prayer times
                        UserDefaults.standard.set(prayerTimes, forKey: "prayerTimes")
                        completion(.success(()))
                    } else {
                        completion(.failure(NSError(domain: "No data found", code: 1, userInfo: nil)))
                    }
                } else {
                    completion(.failure(error ?? NSError(domain: "Failed to fetch", code: 1, userInfo: nil)))
                }
            }
        }
    }
}

@main
struct third2_0App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var audioPlayerViewModel = AudioPlayerViewModel()

    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                ContentView()
                    .environmentObject(audioPlayerViewModel)
                    .onAppear {
                        scheduleBackgroundTask()
                    }
            } else {
                OnboardingView()
            }
        }
    }

    public func scheduleBackgroundTask() {
        if UIApplication.shared.backgroundRefreshStatus == .available {
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.scheduleBackgroundTask()
        }
    }
}



