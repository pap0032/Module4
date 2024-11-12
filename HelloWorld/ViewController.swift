import UIKit
import AVFoundation

class ViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    // MARK: - Enum to Track State
    enum TimerState {
        case idle       // Default state, shows "Start/Stop Timer"
        case counting   // When the countdown timer is running, shows "Stop Timer"
        case playing    // When music is playing, shows "Stop Music"
    }
    
    // MARK: - Properties
    var countdownTimer: Timer?
    var timeRemaining: TimeInterval = 0
    var audioPlayer: AVAudioPlayer?
    var currentState: TimerState = .idle { // Track current state and update UI on change
        didSet { updateUI(for: currentState) }
    }
    //Calendar.current.component(.hour, from: Date())
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { [weak self] _ in self?.setBackgroundImage()
        }
        timeRemaining = datePicker.countDownDuration
        currentState = .idle  // Start in idle state
        startClock()
    }
    
    // MARK: - Check Time for Background Image
    func setBackgroundImage() {
        let currentHour = Calendar.current.component(.hour, from: Date())
        if currentHour > 12 {
            backgroundImage.image = UIImage(named: "daysky")
        }
        else {
            backgroundImage.image = UIImage(named: "night")
        }
    }
    
    
    // MARK: - Actions
    @IBAction func timePickerChanged(_ sender: UIDatePicker) {
        timeRemaining = sender.countDownDuration
    }
    
    @IBAction func startStopButtonTapped(_ sender: UIButton) {
        switch currentState {
        case .idle:
            startCountdown()
        case .counting:
            stopCountdown()
        case .playing:
            stopMusic()
        }
    }
    
    // MARK: - Countdown Timer
    func startCountdown() {
        currentState = .counting
        label2.text = formatTimeInterval(timeRemaining)
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.timeRemaining -= 1
            
            if self.timeRemaining <= 0 {
                self.endCountdown()
            } else {
                self.label2.text = self.formatTimeInterval(self.timeRemaining)
            }
        }
    }
    
    func stopCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        currentState = .idle  // Return to idle state
    }
    
    func endCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        timeRemaining = 0
        label2.text = formatTimeInterval(timeRemaining)
        playMusic()
        currentState = .playing  // Transition to playing state
    }
    
    // MARK: - Clock
    func startClock() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss"
            self.label1.text = formatter.string(from: Date())
        }
    }
    
    // MARK: - Helpers
    func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        return String(format: "Time Remaining: %02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func updateUI(for state: TimerState) {
        switch state {
        case .idle:
            startStopButton.setTitle("Start/Stop Timer", for: .normal)
            label2.text = "Time Remaining"
        case .counting:
            startStopButton.setTitle("Stop Timer", for: .normal)
        case .playing:
            startStopButton.setTitle("Stop Music", for: .normal)
        }
    }
    
    // MARK: - Music Player
    func playMusic() {
        guard let soundURL = Bundle.main.url(forResource: "alarmSound", withExtension: "mp3") else {
            print("Sound file not found.")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
    
    func stopMusic() {
        audioPlayer?.stop()
        audioPlayer = nil
        currentState = .idle  // Return to idle state after stopping music
    }
}

