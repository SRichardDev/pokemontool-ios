import * as functions from 'firebase-functions'
import * as admin from 'firebase-admin'

admin.initializeApp()

export const onWriteArenas = functions.region('europe-west1').database.ref('/arenas/{geohash}/{uid}').onWrite( async (snapshot, context) => {

    const geohash = context.params.geohash
    const arena = snapshot.after.val()
    const raid = arena.raid
    const raidBossId = raid.raidBossId || '---'
    console.log(geohash)

    try {
        const raidBossSnapshot = await admin.database().ref('/raidBosses/' + raidBossId).once('value') 
        const meetupSnapshot = await admin.database().ref('/raidMeetups/' + raid.raidMeetupId).once('value')

        const raidBossName = (raidBossSnapshot.val() && raidBossSnapshot.val().name) || '---'
        const raidMeetupTime = (meetupSnapshot.val() && meetupSnapshot.val().meetupTime) || '---'
        const hatchTime = raid.hatchTime || "---"
        const endTime = raid.endTime || "---"
        const level = raid.level
        const message = '⭐️: ' + level + '\n🐲: ' + raidBossName + '\n⌚️: ' + hatchTime + "-" + endTime + '\n👫: ' + raidMeetupTime

        const condition = "'raids' in topics && '" + geohash + "' in topics && 'level-" + level + "' in topics"
        console.log(condition)

        const payload = {
            notification: {
                title: 'Neuer Raid bei: ' + arena.name,
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