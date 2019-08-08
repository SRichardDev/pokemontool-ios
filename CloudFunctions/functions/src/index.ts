import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'

admin.initializeApp()

export const onWriteRaid = functions.region('europe-west1')
.database.ref('/arenas/{geohash}/{arenaId}/raid').onWrite( async (snapshot, context) => {

    const geohash = context.params.geohash
    const arenaId = context.params.arenaId
    
    const raid = snapshot.after.val()
    // const raidBossId = raid.raidBossId || ""

    try {
        const arenaSnapshot = await admin.database().ref('/arenas/' + geohash + '/' + arenaId).once('value')
        // const raidBossSnapshot = await admin.database().ref('/raidBosses/' + raidBossId).once('value') 
        const meetupSnapshot = await admin.database().ref('/raidMeetups/' + raid.raidMeetupId).once('value')

        const arena = arenaSnapshot.val()
        const raidBossName = /*(raidBossSnapshot.val() && raidBossSnapshot.val().name) ||*/ 'Unbekannt'
        const raidMeetupTime = (meetupSnapshot.val() && meetupSnapshot.val().meetupTime) || '--:--'
        const hatchTime = raid.hatchTime || "--:--"
        const endTime = raid.endTime || "--:--"
        const level = raid.level
        const message = '⌚️: ' + hatchTime + "-" + endTime + '\n🐲: ' + raidBossName + '\n👫: ' + raidMeetupTime

        const condition = "'raids' in topics && '" + geohash + "' in topics && 'level-" + level + "' in topics"

        console.log('Sending Condition: ' + condition)
        console.log('Geohash: ' + geohash +  ' Arena: ' + arena.name + ' Raidboss: ' + raidBossName + ' HatchTime: ' + hatchTime + ' EndTime: ' + endTime + ' Level: ' + level + ' MeetupTime: ' + raidMeetupTime)


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

        const payload = {
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
        const meetupTimeBefore = meetupBefore.meetupTime
        const meetupTimeAfter = meetupAfter.meetupTime

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

        } else if (meetupTimeBefore !== meetupTimeAfter) {
            const payload = {
                notification: {
                    title: 'Der Treffpunkt wurde geändert',
                    body: 'Treffpunkt: ' + meetupTimeAfter,
                    badge: '1',
                    sound: 'default'
                }
            }
            return admin.messaging().sendToCondition(condition, payload)
        }  
    }

    return false
})