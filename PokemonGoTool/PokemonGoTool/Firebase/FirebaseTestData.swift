
import Firebase
import CodableFirebase

class FirebaseTestData {
 
    class func addDummyPokestops() {
        for _ in 0...1000 {
            let latitude = Double.random(in: 48.0...48.3)
            let longitude = Double.random(in: 11.4...11.7)
            let pokestop = Pokestop(name: "foobar", latitude: latitude, longitude: longitude, submitter: "Test")
            let data = try! FirebaseEncoder().encode(pokestop)
            let ref = Database.database().reference(withPath: "test_pokestops")
            ref.child(pokestop.geohash).childByAutoId().setValue(data)
        }
    }
    
    class func deleteDummyPokestops() {
        let ref = Database.database().reference(withPath: "test_pokestops")
        ref.removeValue()
    }
    
    class func addRaidBosses() {
        let palkia = ["name": "Palkia",
                      "level": "5",
                      "imageName" : "484"]
        let latias = ["name": "Latias",
                      "level": "5",
                      "imageName" : "380"]
        
        let knogga = ["name": "Alola Knogga",
                      "level": "4",
                      "imageName" : "105"]
        let togetic = ["name": "Togetic",
                       "level": "4",
                       "imageName" : "176"]
        let ursaring = ["name": "Ursaring",
                        "level": "4",
                        "imageName" : "217"]
        let despotar = ["name": "Despotar",
                        "level": "4",
                        "imageName" : "248"]
        let absol = ["name": "Absol",
                     "level": "4",
                     "imageName" : "359"]
        let simsala = ["name": "Simsala",
                       "level": "4",
                       "imageName" : "65"]
        
        
        
        
        let machomei = ["name": "Machomei",
                        "level": "3",
                        "imageName" : "68"]
        let azumarill = ["name": "Azumarill",
                         "level": "3",
                         "imageName" : "184"]
        let granbull = ["name": "Granbull",
                        "level": "3",
                        "imageName" : "210"]
        
        
        
        let kokowei = ["name": "Alola Kokowei",
                       "level": "2",
                       "imageName" : "103"]
        let kirilia = ["name": "Kirilia",
                       "level": "2",
                       "imageName" : "281"]
        let zobiris = ["name": "Zobiris",
                       "level": "2",
                       "imageName" : "302"]
        let flunkifer = ["name": "Flunkifer",
                         "level": "2",
                         "imageName" : "303"]
        
        let karpador = ["name": "Karpador",
                        "level": "1",
                        "imageName" : "129"]
        let dratini = ["name": "Dratini",
                       "level": "1",
                       "imageName" : "147"]
        let wablu = ["name": "Wablu",
                     "level": "1",
                     "imageName" : "333"]
        let barschwa = ["name": "Barschwa",
                        "level": "1",
                        "imageName" : "349"]
        let shinux = ["name": "Shinux",
                      "level": "1",
                      "imageName" : "403"]
        let bamelin = ["name": "Bamelin",
                       "level": "1",
                       "imageName" : "418"]
        
        let raidbosses = Database.database().reference(withPath: "raidBosses")
        raidbosses.childByAutoId().updateChildValues(palkia)
        raidbosses.childByAutoId().updateChildValues(latias)
        raidbosses.childByAutoId().updateChildValues(absol)
        raidbosses.childByAutoId().updateChildValues(azumarill)
        raidbosses.childByAutoId().updateChildValues(bamelin)
        raidbosses.childByAutoId().updateChildValues(barschwa)
        raidbosses.childByAutoId().updateChildValues(despotar)
        raidbosses.childByAutoId().updateChildValues(dratini)
        raidbosses.childByAutoId().updateChildValues(flunkifer)
        raidbosses.childByAutoId().updateChildValues(granbull)
        raidbosses.childByAutoId().updateChildValues(karpador)
        raidbosses.childByAutoId().updateChildValues(kirilia)
        raidbosses.childByAutoId().updateChildValues(knogga)
        raidbosses.childByAutoId().updateChildValues(kokowei)
        raidbosses.childByAutoId().updateChildValues(machomei)
        raidbosses.childByAutoId().updateChildValues(shinux)
        raidbosses.childByAutoId().updateChildValues(simsala)
        raidbosses.childByAutoId().updateChildValues(togetic)
        raidbosses.childByAutoId().updateChildValues(ursaring)
        raidbosses.childByAutoId().updateChildValues(wablu)
        raidbosses.childByAutoId().updateChildValues(zobiris)
    }
    
    class func addQuests() {
        
        let quest1 = ["quest" : "Tausche 10 Pokémon",
                      "reward" : "Panflam",
                      "imageName" : "390"]
        let quest2 = ["quest" : "Fange 10 Pokémon von Typ Boden",
                      "reward" : "Sandan ✨",
                      "imageName" : "27"]
        let quest3 = ["quest" : "Lande 5 großartige Curveball-Würfe hintereinander",
                      "reward" : "Pandir (Form 5)",
                      "imageName" : "327"]
        let quest4 = ["quest" : "Brüte 5 Eier aus",
                      "reward" : "3 x Sonderbonbon",
                      "imageName" : "candy"]
        let quest5 = ["quest" : "Lande 3 fabelhafte Würfe hintereinander",
                      "reward" : "Larvitar ✨",
                      "imageName" : "246"]
        let quest6 = ["quest" : "Fange ein Pokémon vom Typ Drache",
                      "reward" : "Dratini ✨",
                      "imageName" : "147"]
        let quest7 = ["quest" : "Lande 3 großartige Curveball-Würfe hintereinander",
                      "reward" : "Onix",
                      "imageName" : "95"]
        
        let quests = Database.database().reference(withPath: "quests")
        quests.childByAutoId().setValue(quest1)
        quests.childByAutoId().setValue(quest2)
        quests.childByAutoId().setValue(quest3)
        quests.childByAutoId().setValue(quest4)
        quests.childByAutoId().setValue(quest5)
        quests.childByAutoId().setValue(quest6)
        quests.childByAutoId().setValue(quest7)
    }
}
