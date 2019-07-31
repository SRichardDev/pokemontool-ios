import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'

admin.initializeApp()

export const onWriteArenas = functions.region('europe-west1')
.database.ref('/arenas/{geohash}/{uid}').onWrite( async (snapshot, context) => {

    const geohash = context.params.geohash
    const arena = snapshot.after.val()
    const raid = arena.raid
    const raidBossId = raid.raidBossId
    console.log(geohash)

    try {
        const raidBossSnapshot = await admin.database().ref('/raidBosses/' + raidBossId).once('value') 
        const meetupSnapshot = await admin.database().ref('/raidMeetups/' + raid.raidMeetupId).once('value')

        const raidBossName = (raidBossSnapshot.val() && raidBossSnapshot.val().name) || 'Unbekannt'
        const raidMeetupTime = (meetupSnapshot.val() && meetupSnapshot.val().meetupTime) || '--:--'
        const hatchTime = raid.hatchTime || "--:--"
        const endTime = raid.endTime || "--:--"
        const level = raid.level
        const message = '⌚️: ' + hatchTime + "-" + endTime + '\n🐲: ' + raidBossName + '\n👫: ' + raidMeetupTime

        const condition = "'raids' in topics && '" + geohash + "' in topics && 'level-" + level + "' in topics"
        console.log(condition)

        const payload = {
            notification: {
                title: '⭐️'.repeat(level) + " @ " + arena.name,
                body: message,
                sound: 'default'
            },
            data: {
                latitude: String(arena.latitude),
                longitude: String(arena.longitude)
            }
        }

        return admin.messaging().sendToCondition(condition, payload)
            
    } catch (error) {
        console.log(error)
        return false
    }
})

export const onWriteRaidMeetupChat = functions.region('europe-west1')
.database.ref('/raidMeetups/{meetupId}/chat/{messageId}').onWrite( async (snapshot, context) => {

    const meetupId = context.params.meetupId
    const messageContainer = snapshot.after.val()
    const message = messageContainer.message
    const senderId = messageContainer.senderId

    try {
        const senderSnapshot = await admin.database().ref('/users/' + senderId).once('value')
        const publicData = senderSnapshot.val().publicData
        const senderName = publicData.trainerName

        const condition = "'" + meetupId + "' in topics" 

        var payload = {
            notification: {
                title: 'Neue Nachricht von: ' + senderName,
                body: message,
                badge: '1',
                sound: 'default'
            }
        }

        return admin.messaging().sendToCondition(condition, payload)

    } catch (error) {
        console.log(error)
        return false
    }
})

export const onWriteRaidMeetup = functions.region('europe-west1')
.database.ref('/raidMeetups/{meetupId}').onWrite( async (snapshot, context) => {

    if (snapshot.before.hasChild("participants") && snapshot.after.hasChild("participants")) {
        
        const meetupId = context.params.meetupId
        const meetupBefore = snapshot.before.val()
        const meetupAfter = snapshot.after.val()
    
        const participantsBefore = meetupBefore.participants
        const participantsAfter = meetupAfter.participants
        const participantsBeforeCount = Object.keys(participantsBefore).length;
        const participantsAfterCount = Object.keys(participantsAfter).length;
    
        const condition = "'" + meetupId + "' in topics" 
    
        if (participantsAfterCount > participantsBeforeCount) {
            
            const payload = {
                notification: {
                    title: 'Ein Spieler nimmt beim Raid teil',
                    body: 'Neue Anzahl: ' + participantsAfterCount,
                    badge: '1',
                    sound: 'default'
                }
            }
            return admin.messaging().sendToCondition(condition, payload)
    
        } else if (participantsAfterCount < participantsBeforeCount) {
    
            const payload = {
                notification: {
                    title: 'Ein Spieler hat beim Raid abgesagt',
                    body: 'Neue Anzahl: ' + participantsAfterCount,
                    badge: '1',
                    sound: 'default'
                }
            }
            return admin.messaging().sendToCondition(condition, payload)
        }    
    }

    return false
})