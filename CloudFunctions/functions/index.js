const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);


exports.sendRaidPush = functions.database.ref('/arenas/{geohash}/{uid}').onWrite((snapshot, context) => {

    const geohash = context.params.geohash;
    const arena = snapshot.after.val();
    const raid = arena.raid;

    return admin.database().ref('/registeredUsersArenas/' + geohash).once('value', (snapshot, context) => {
        snapshot.forEach((child) => {
            const userId = child.key
            console.log('Pushing to userID: ' + userId)

            admin.database().ref('/raidMeetups/' + raid.raidMeetupId).once('value', (snapshot, context) => {

                const raidMeetupTime = (snapshot.val() && snapshot.val().meetupTime) || '---'
                const raidBoss = raid.raidBoss || '---'

                admin.database().ref('/users/' + userId).once('value', (snapshot, context) => { 

                    const notificationToken = (snapshot.val() && snapshot.val().notificationToken) || 'No token'
                    const message = 'Level: ' + raid.level + '\nRaidboss: ' + raidBoss + '\nSchlüpft: ' + raid.hatchTime + '\nTreffpunkt: ' + raidMeetupTime

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
                    };
                
                    admin.messaging().sendToDevice(notificationToken, payload)
                    return true
                });
            });
        });
    })
    .catch(err => {
        console.error('ERROR:', err)
        return false
    })
});


exports.sendNewQuestPushNotification = functions.database.ref('/pokestops/{geohash}/{uid}').onWrite((snapshot, context) => {
    
    const geohash = context.params.geohash
    const uid = context.params.uid

    const pokestop = snapshot.after.val()
    const name = pokestop.name;
    const quest = pokestop.quest
    const questName = quest.name
    const questReward = quest.reward
        
    console.log('Pokestop name: ' + pokestop.name + ', with ID: ' + uid + ', in geohash: ' + geohash + ', has new quest: ' + quest.name + ', with reward: ' + quest.reward)

    return admin.database().ref('/registeredUsersPokestops/' + geohash).once('value', (snapshot, context) => {
        snapshot.forEach((child) => {
            const userId = child.key
            console.log('Pushing to userID: ' + userId)
            admin.database().ref('/users/' + userId).once('value', (snapshot, context) => { 

                const notificationToken = (snapshot.val() && snapshot.val().notificationToken) || 'No token'

                const payload = {
                    notification: {
                        title: 'Neue Feldforschung',
                        body: 'Pokéstop: ' + name + '\nQuest: ' + questName + '\nBelohnung: ' + questReward,
                        badge: '1',
                        sound: 'default',
                        mutable_content: '1',
                        category : 'Push'
                    },
                    data: {
                        latitude: String(pokestop.latitude),
                        longitude: String(pokestop.longitude),
                        imageUrl: 'foo.jpg'
                    }
                };
            
                admin.messaging().sendToDevice(notificationToken, payload)
                return true
            });
        });
    })
    .catch(err => {
        console.error('ERROR:', err)
        return false
    })
});
