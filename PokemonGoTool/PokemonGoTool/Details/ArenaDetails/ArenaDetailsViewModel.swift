
import MapKit
import Firebase
import CodableFirebase
import UserNotifications

enum ArenaDetailsUpdateType {
    case meetupInit
    case meetupChanged
    case timeLeftChanged(_ timeLeft: String)
    case hatchTimeLeftChanged(_ timeLeft: String)
    case goldArenaChanged(isGold: Bool)
    case eggHatched
    case raidbossChanged
    case changeMeetupTime
    case raidExpired
}

protocol ArenaDetailsDelegate: class {
    func update(of type: ArenaDetailsUpdateType)
}

class ArenaDetailsViewModel: MeetupTimeSelectable, HeaderProvidable {

    var firebaseConnector: FirebaseConnector
    weak var delegate: ArenaDetailsDelegate?
    var arena: Arena
    var meetup: RaidMeetup?
    var timeLeft: String?
    var hatchTimer: Timer?
    var timeLeftTimer: Timer?
    var timerIsOn = false
    var selectedMeetupTime: String?
    var meetupTimeSelectionType: MeetupTimeSelectionType = .change
    var participants = [String: PublicUserData]()
    var hasActiveRaid: Bool { get { return !(arena.raid?.isExpired ?? true) }}
    var isRaidbossActive: Bool {get { return arena.raid?.hasHatched ?? false }}
    var isRaidExpired: Bool { get { return arena.raid?.isExpired ?? true }}
    var isRaidBossSelected: Bool { get { return arena.raid?.raidBossId != nil }}
    var level: Int { get { return arena.raid?.level ?? 0 }}
    var isTimeSetForMeetup: Bool {get{return meetup?.meetupTime != "--:--" }}
    var isGoldArena: Bool { get { return arena.isGoldArena ?? false }}
    var hatchTime: String { get { return arena.raid?.hatchTime ?? "00:00" }}
    var endTime: String { get { return arena.raid?.endTime ?? "00:00" }}
    var coordinate: CLLocationCoordinate2D { get { return arena.coordinate }}
    var headerImage: UIImage { get { return isRaidExpired ? arena.image : arena.raid?.image ?? UIImage() }}
    var headerTitle: String { get { return arena.name }}

    var title: String {
        get {
            let raidboss = RaidbossManager.shared.raidboss(for: arena.raid?.raidBossId)
            return isRaidExpired ? (arena.isEX ? "EX Arena" : "Arena") : raidboss?.name ?? "Level \(arena.raid?.level ?? 0) Raid"
        }
    }


    var isUserParticipating: Bool {
        get {
            guard let userId = firebaseConnector.user?.id else {return false}
            return participants[userId] != nil
        }
    }
    
    
    init(arena: Arena, firebaseConnector: FirebaseConnector) {
        self.arena = arena
        self.firebaseConnector = firebaseConnector

        firebaseConnector.raidMeetupDelegate = self

        guard let raid = arena.raid else { return }
        guard !raid.isExpired else { return }

        if raid.isSubmittedBeforeHatchTime {
            startHatchTimer()
        } else {
            startTimeLeftTimer()
        }

        guard let meetupId = arena.raid?.raidMeetupId else { return }
        firebaseConnector.observeRaidMeetup(for: meetupId)
    }
        
    func userParticipates(_ isParticipating: Bool) {
        guard let meetup = meetup else { return }
        
        if isParticipating {
            guard let raid = arena.raid else { fatalError() }
            self.arena = firebaseConnector.userParticipates(in: raid, for: &arena)
            print("🏟 User participates in meetup")

            guard let userLocation = LocationManager.shared.currentUserLocation?.coordinate else { return }
            if let meetupDate = meetup.meetupDate {
                DepartureNotificationManager.notifyUserToDepartForRaid(pickupCoordinate: userLocation,
                                                                       destinationCoordinate: arena.coordinate,
                                                                       arenaName: arena.name,
                                                                       meetupDate: meetupDate,
                                                                       meetupId: meetup.id)
            }
        } else {
            firebaseConnector.userCanceled(in: meetup)
            DepartureNotificationManager.removeUserFromDepartForRaidNotification(for: meetup.id)
            print("🏟 User canceled meetup")
        }
    }
    
    private func submitMeetupTime() {
        guard let selectedMeetupTime = selectedMeetupTime, let meetup = meetup else { return }
        firebaseConnector.setMeetupTime(meetupTime: selectedMeetupTime, raidMeetup: meetup)
    }
    
    func changeGoldArena(isGold: Bool) {
        if isGold {
            firebaseConnector.user?.addGoldArena(arena.id, for: arena.geohash)
        } else {
            firebaseConnector.user?.removeGoldArena(arena.id)
        }
        arena.isGoldArena = isGold
        firebaseConnector.updateArena(arena)
        delegate?.update(of: .goldArenaChanged(isGold: isGold))
    }
    
    func startHatchTimer() { 
        guard let raid = arena.raid else { return }
        guard let date = raid.hatchDate else { return }
        hatchTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
            if self.isTimeUp(for: date) {
                self.startTimeLeftTimer()
                self.hatchTimer?.invalidate()
                return
            }
            
            DispatchQueue.main.async {
                self.delegate?.update(of: .hatchTimeLeftChanged("\(self.formattedCountDown(for: date))"))
            }
        })
        hatchTimer?.fire()
    }
    
    func startTimeLeftTimer() {
        guard let raid = arena.raid else { return }
        guard let date = raid.endDate else { return }
        timeLeftTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
            if self.isTimeUp(for: date) {
                self.showTimeUp()
                self.timeLeftTimer?.invalidate()
                return
            }
            
            DispatchQueue.main.async {
                self.delegate?.update(of: .timeLeftChanged("\(self.formattedCountDown(for: date))"))
            }
        })
        timeLeftTimer?.fire()
        
        #warning("Hacky")
        guard !isRaidbossActive else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.delegate?.update(of: .eggHatched)
        }
    }
    
    func showTimeUp() {
        DispatchQueue.main.async {
            self.delegate?.update(of: .raidExpired)
        }
    }
    
    func submitterName(_ completion: @escaping (String) -> ()) {
        if arena.submitter == "Bot" || arena.submitter == "System" {
            completion(arena.submitter)
        }
        firebaseConnector.userName(for: arena.submitter) { trainerName in
            completion(trainerName)
        }
    }
    
    func submitterNameForRaid(_ completion: @escaping (String) -> ()) {
        
        guard let raidSubmitter = arena.raid?.submitter else { completion("Fehler"); return }

        if raidSubmitter == "Bot" || raidSubmitter == "System" {
            completion(raidSubmitter)
        } else {
            firebaseConnector.userName(for: raidSubmitter) { trainerName in
                completion(trainerName)
            }
        }
    }
    
    func updateRaidboss(_ raidboss: RaidbossDefinition) {
        firebaseConnector.setRaidbossForRaid(in: &arena, raidboss: raidboss)
        delegate?.update(of: .raidbossChanged)
    }
    
    func changeMeetupTimeRequested() {
        delegate?.update(of: .changeMeetupTime)
    }
    
    func meetupTimeDidChange() {
        submitMeetupTime()
        delegate?.update(of: .changeMeetupTime)
    }
    
    func formattedRaidTextForSharing() -> String {
        var participantsString = ""
        participants.values.forEach { participantsString += ("• " + $0.trainerName! + "\n") }
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        let shareText = """
        🐲: \(RaidbossManager.shared.raidboss(for: arena.raid?.raidBossId)?.name ?? "---"), ⭐️: \(arena.raid?.level ?? 0)
        🏟: \(arena.name)
        ⌚️: \(dateFormatter.string(from: arena.raid?.hatchDate ?? Date())) - \(dateFormatter.string(from: arena.raid?.endDate ?? Date()))
        👫: \(meetup?.meetupTime ?? "")
        📍: https://maps.google.com/?q=\(arena.latitude),\(arena.longitude)\n
        \(participantsString)
        """
        return shareText
    }

    private func isTimeUp(for date: Date) -> Bool {
        let timerInterval = date.timeIntervalSince(Date())
        let time = NSInteger(timerInterval)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        return seconds <= 0 && minutes <= 0 && hours <= 0
    }
    
    private func formattedCountDown(for date: Date) -> String {
        let timerInterval = date.timeIntervalSince(Date())
        let time = NSInteger(timerInterval)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        
        return String(format: "%0.2d:%0.2d", minutes, seconds)
    }
    
    func DEBUGdeleteArena() {
        firebaseConnector.DEBUGdeleteArena(arena)
    }
}

extension ArenaDetailsViewModel: RaidMeetupDelegate {

    func didUpdateRaidMeetup(_ changedRaidMeetup: RaidMeetup) {
        
        if meetup == nil {
            self.meetup = changedRaidMeetup
            delegate?.update(of: .meetupInit)
        }
        
        let isMeetupTimeChange = changedRaidMeetup.meetupDate != meetup?.meetupDate
        
        if isMeetupTimeChange && meetup?.meetupDate == nil {
            self.delegate?.update(of: .changeMeetupTime)
        }
        
        if isMeetupTimeChange && isUserParticipating && !isRaidExpired {
            if let meetup = meetup,
                let meetupDate = changedRaidMeetup.meetupDate,
                let userLocation = LocationManager.shared.currentUserLocation?.coordinate {
                DepartureNotificationManager.removeUserFromDepartForRaidNotification(for: meetup.id)
                DepartureNotificationManager.notifyUserToDepartForRaid(pickupCoordinate: userLocation,
                                                                       destinationCoordinate: arena.coordinate,
                                                                       arenaName: arena.name,
                                                                       meetupDate: meetupDate,
                                                                       meetupId: meetup.id,
                                                                       timeChanged: true)
            }
        }
        
        self.participants.removeAll()
        self.meetup = changedRaidMeetup
        
        guard let userIds = changedRaidMeetup.participants else {
            DispatchQueue.main.async {
                self.delegate?.update(of: .meetupChanged)
            }
            return
        }
        
        userIds.keys.forEach { userId in
            firebaseConnector.loadPublicUserData(for: userId) { publicUserData in
                self.participants[userId] = publicUserData
                DispatchQueue.main.async {
                    self.delegate?.update(of: .meetupChanged)
                }
            }
        }
    }
}
