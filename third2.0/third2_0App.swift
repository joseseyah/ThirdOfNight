import SwiftUI
import SwiftData
import FirebaseCore
import UserNotifications
import BackgroundTasks
import AVFoundation
import FirebaseFirestore
import Network


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseHelper.shared.setupFireBase()

        configureAudioSession()
        // Set up background fetch interval
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)

        // Register the background task
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.yourapp.updatePrayerTimes", using: nil) { task in
            self.handleBackgroundTask(task: task as! BGAppRefreshTask)
        }

        return true
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
        FirebaseHelper.shared.updatePrayerTimes { result in
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
        
        FirebaseHelper.shared.updatePrayerTimes{ result in
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
}

@main
struct third2_0App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var audioPlayerViewModel = AudioPlayerViewModel()
    @StateObject private var networkMonitor = NetworkMonitor()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                ContentView()
                    .onChange(of: networkMonitor.isConnected) { isConnected in
                        setupMode(isConnected: isConnected)
                    }
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
    private func setupMode(isConnected: Bool? = nil) {
        if isConnected ?? false{
            FirebaseHelper.shared.enableOnlineMode(completion: { error in
                
            })
        }else{
            FirebaseHelper.shared.enableOfflineMode(completion: { error in
                
            })
        }
    }
}
class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published var isConnected: Bool = false
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
    
    
    

    
}
