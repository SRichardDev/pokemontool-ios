
import MapKit
import Firebase
import CodableFirebase
import UserNotifications

enum ArenaDetailsUpdateType {
    case meetupChanged
    case timeLeftChanged(_ timeLeft: String)
    case hatchTimeLeftChanged(_ timeLeft: String)
    case goldArenaChanged(isGold: Bool)
    case eggHatched
    case raidbossChanged
    case changeMeetupTime
    case updateMeetupTime
    case raidExpired
    case userParticipatesChanged(_ isParticipating: Bool)
}

protocol ArenaDetailsDelegate: class {
    func update(of type: ArenaDetailsUpdateType)
}

class ArenaDetailsViewModel: MeetupTimeSelectable, HeaderProvidable, RaidbossSelectable {

    var firebaseConnector: FirebaseConnector
    weak var delegate: ArenaDetailsDelegate?
    var arena: Arena
    var meetup: RaidMeetup? {
        return arena.raid?.meetup
    }
    var timeLeft: String?
    var hatchTimer: Timer?
    var timeLeftTimer: Timer?
    var timerIsOn = false
    var meetupDate: Date?
    var meetupTimeSelectionType: MeetupTimeSelectionType = .change
    var participants = [String: PublicUserData]()
    var hasActiveRaid: Bool { return !(arena.raid?.isExpired ?? true) }
    var isRaidbossActive: Bool { return arena.raid?.hasHatched ?? false }
    var isRaidExpired: Bool { return arena.raid?.isExpired ?? true }
    var isRaidBossSelected: Bool { return arena.raid?.raidboss != nil }
    var level: Int { return arena.raid?.level ?? 0 }
    var isTimeSetForMeetup: Bool {meetup?.isTimeSet ?? false }
    var isGoldArena: Bool { return arena.isGoldArena ?? false }
    var hatchDate: Date? { return arena.raid?.hatchDate }
    var endDate: Date? { return arena.raid?.endDate }
    var coordinate: CLLocationCoordinate2D { return arena.coordinate }
    var headerImage: UIImage { return isRaidExpired ? arena.image : arena.raid?.image ?? UIImage() }
    var headerTitle: String { return arena.name }
    var selectedRaidBoss: Int?

    var title: String {
        let standardName = arena.isEX ? "EX Arena" : "Arena"
        guard let raid = arena.raid else { return standardName }
        guard raid.isActive else { return standardName }
        guard let raidboss = raid.raidboss else { return "Level \(raid.level) Raid" }
        let raidbossName = RaidbossManager.shared.pokemon[raidboss - 1].name
        return raidbossName
    }

    var isUserParticipating: Bool {
        guard let userId = firebaseConnector.user?.id else {return false}
        return participants[userId] != nil
    }
    
    var isDepartureNotificationSet: Bool {
        guard let raidId = arena.raid?.raidId else { return false }
        return UserDefaults.standard.bool(forKey: raidId + "-departureNotification")
    }
    
    var departureNotificationTime: String? {
        guard let raidId = arena.raid?.raidId else { return "" }
        return UserDefaults.standard.string(forKey: raidId + "-meetupTime")
    }
    
    init(arena: Arena, firebaseConnector: FirebaseConnector) {
        self.arena = arena
        self.firebaseConnector = firebaseConnector

        guard let raid = arena.raid else { return }
        guard !raid.isExpired else { return }

        if raid.isSubmittedBeforeHatchTime {
            startHatchTimer()
        } else {
            startTimeLeftTimer()
        }
        
        selectedRaidBoss = arena.raid?.raidboss
        firebaseConnector.raidDelegate = self
        firebaseConnector.observeRaid(in: arena)
    }
    
    deinit {
        firebaseConnector.stopObservingRaid(in: arena)
    }
        
    func userParticipates(_ isParticipating: Bool) {
        if isParticipating {
            self.arena = firebaseConnector.userParticipatesInRaid(in: &arena)
            print("🏟 User participates in meetup")
        } else {
            firebaseConnector.userCanceledInRaid(in: &arena)
            removeDepartureNotification()
            print("🏟 User canceled meetup")
        }
        delegate?.update(of: .userParticipatesChanged(isParticipating))
    }
    
    private func submitMeetupTime() {
        guard let selectedMeetupTime = meetupDate else { return }
        firebaseConnector.setMeetupTime(selectedMeetupTime.timestamp, in: arena)
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
        hatchTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] timer in
            guard let self = self else { return }
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
        timeLeftTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] timer in
            guard let self = self else { return }
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
    
    func changeMeetupTimeRequested() {
        delegate?.update(of: .changeMeetupTime)
    }
    
    func meetupTimeDidChange() {
        submitMeetupTime()
        delegate?.update(of: .changeMeetupTime)
    }
    
    func addDepartureNotification(departureTimeStringCompletion: @escaping (_ time: String, _ error: CustomError?) -> ()) {
        guard let raidId = arena.raid?.raidId,
            let meetupDate = meetup?.meetupDate else { return }
        guard let userLocation = LocationManager.shared.currentUserLocation?.coordinate else {
            let error = CustomError(type: .userLocationNotFound)
            departureTimeStringCompletion("", error)
            return
        }


        DepartureNotificationManager.notifyUserToDepartForRaid(pickupCoordinate: userLocation,
                                                               destinationCoordinate: arena.coordinate,
                                                               destinationName: arena.name,
                                                               meetupDate: meetupDate,
                                                               identifier: raidId) { time in
                                                                UserDefaults.standard.set(true, forKey: raidId + "-departureNotification")
                                                                UserDefaults.standard.set(time, forKey: raidId + "-meetupTime")
                                                                departureTimeStringCompletion(time, nil)
        }
    }
    
    func removeDepartureNotification() {
        guard let raidId = arena.raid?.raidId else { return }
        DepartureNotificationManager.removeUserFromDepartForRaidNotification(for: raidId)
        UserDefaults.standard.removeObject(forKey: raidId + "-departureNotification")
        UserDefaults.standard.removeObject(forKey: raidId + "-meetupTime")
    }
    
    func formattedRaidTextForSharing() -> String? {
        guard let raid = arena.raid,
            let hatchDate = raid.hatchDate,
            let endDate = raid.endDate else { return nil }
        
        var participantsString = ""
        participants.values.forEach { participantsString += ("- " + $0.trainerName! + "\n") }
        
        let shareText = """
        🐲: \(RaidbossManager.shared.pokemonNameFor(dexNumber: raid.raidboss)), ⭐️: \(raid.level)
        🏟: \(arena.name)
        ⌚️: \(DateUtility.timeString(for: hatchDate)) - \(DateUtility.timeString(for: endDate))
        👫: \(DateUtility.timeString(for: meetup?.meetupDate))
        📍: https://maps.google.com/?q=\(arena.latitude),\(arena.longitude)\n
        \(participantsString)
        """
        return shareText
    }
    
    func updateRaidboss(dexNumber: Int) {
        selectedRaidBoss = dexNumber
        firebaseConnector.updateRaidboss(in: &arena, dexNumber: dexNumber)
        delegate?.update(of: .raidbossChanged)
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

extension ArenaDetailsViewModel: RaidDelegate {
    
    func didUpdateRaid(_ changedRaid: Raid) {
        guard let meetup = changedRaid.meetup else { return }
        updateParticipants(in: meetup)
        updateMeetupTime(in: meetup)
        
        arena.raid = changedRaid
    }
    
    private func updateMeetupTime(in meetup: RaidMeetup) {
        let meetupTimeWasSet = meetup.meetupDate != self.meetup?.meetupDate
        let meetupTimeWasNotSetBefore = self.meetup?.meetupDate == nil

        if meetupTimeWasSet && meetupTimeWasNotSetBefore {
            self.delegate?.update(of: .changeMeetupTime)
        }

        if meetupTimeWasSet && !meetupTimeWasNotSetBefore {
            removeDepartureNotification()
            self.delegate?.update(of: .updateMeetupTime)
        }
    }
    
    private func updateParticipants(in meetup: RaidMeetup) {
        participants.removeAll()
        guard let userIds = meetup.participants else {
            DispatchQueue.main.async {
                self.delegate?.update(of: .meetupChanged)
            }
            return
        }

        userIds.keys.forEach { userId in
            firebaseConnector.loadPublicUserData(for: userId) { [weak self] publicUserData in
                self?.participants[userId] = publicUserData
                DispatchQueue.main.async {
                    self?.delegate?.update(of: .meetupChanged)
                    
                    if self?.isUserParticipating ?? false {
                        self?.delegate?.update(of: .userParticipatesChanged(true))
                    }
                }
            }
        }
    }
}

enum CustomErrorType {
    case userLocationNotFound
}

public struct CustomError: Error {
    let type: CustomErrorType
}
