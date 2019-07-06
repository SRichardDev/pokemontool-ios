const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);


exports.sendRaidPush = functions.database.ref('/arenas/{geohash}/{uid}').onWrite((snapshot, context) => {

    const geohash = context.params.geohash;
    const arena = snapshot.after.val();
    const raid = arena.raid;
    const raidBossId = raid.raidBossId || '---'

    //Get registred users
    return admin.database().ref('/registeredUsersArenas/' + geohash).once('value', (registeredUsersSnapshot, context) => {

        //Get Raidboss
        admin.database().ref('/raidBosses/' + raidBossId).once('value', (raidBossSnapshot, context) => { 
            const raidBossName = (raidBossSnapshot.val() && raidBossSnapshot.val().name) || '---'

            //Get Meetup
            admin.database().ref('/raidMeetups/' + raid.raidMeetupId).once('value', (meetupSnapshot, context) => {
                const raidMeetupTime = (meetupSnapshot.val() && meetupSnapshot.val().meetupTime) || '---'

                //Loop through users
                registeredUsersSnapshot.forEach((child) => {
                    const userId = child.key
                    console.log('Pushing to userID: ' + userId)
        
                    admin.database().ref('/users/' + userId).once('value', (usersSnapshot, context) => { 

                        if (!usersSnapshot.val().isPushActive) {
                            return false
                        }

                        const notificationToken = (usersSnapshot.val() && usersSnapshot.val().notificationToken) || 'No token'
                        const message = 'Level: ' + raid.level + '\nRaidboss: ' + raidBossName + '\nSchlüpft: ' + raid.hatchTime + '\nTreffpunkt: ' + raidMeetupTime
                        const platform = usersSnapshot.val().platform || "fallback"

                        var payload

                        if (platform === "iOS") {
                            //iOS
                            payload = {
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
                        }

                        if (platform === "android") {
                            //Android
                            payload = {
                                data: {
                                    title: 'Neuer Raid bei: ' + arena.name,
                                    body: message,
                                    latitude: String(arena.latitude),
                                    longitude: String(arena.longitude)
                                }
                            };
                        }

                        if (platform === "fallback") {
                            //Fallback
                            payload = {
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
                        }

                        admin.messaging().sendToDevice(notificationToken, payload)
                        return true
                    });
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
    const name = pokestop.name
    const quest = pokestop.quest
    const questId = quest.definitionId

    admin.database().ref('/quests/' + questId).once('value', (questDefinitionSnapshot) => { 
        const questName = questDefinitionSnapshot.val().quest
        const questReward = questDefinitionSnapshot.val().reward
    
        console.log('Pokestop name: ' + pokestop.name + ', with ID: ' + uid + ', in geohash: ' + geohash + ', has new quest: ' + quest.name + ', with reward: ' + quest.reward)

        return admin.database().ref('/registeredUsersPokestops/' + geohash).once('value', (snapshot, context) => {
            snapshot.forEach((child) => {
                const userId = child.key
                console.log('Pushing to userID: ' + userId)
                admin.database().ref('/users/' + userId).once('value', (snapshot, context) => { 
    
                    if (!snapshot.val().isPushActive) {
                        return false
                    }
                    
                    const notificationToken = (snapshot.val() && snapshot.val().notificationToken) || 'No token'
                    const platform = snapshot.val().platform || "fallback"
                    var payload
    
                    if (platform === "iOS") {
                        payload = {
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
                            }
                        };
                    }
    
                    if (platform === "android") {
                        payload = {
                            data: {
                                title: 'Neue Feldforschung',
                                body: 'Pokéstop: ' + name + '\nQuest: ' + questName + '\nBelohnung: ' + questReward,
                                latitude: String(pokestop.latitude),
                                longitude: String(pokestop.longitude),
                            }
                        };    
                    }
    
                    if (platform === "fallback") {
                        payload = {
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
                            }
                        };
                    }
    
                    admin.messaging().sendToDevice(notificationToken, payload)
                    return true
                });
            });
        })
        .catch(err => {
            console.error('ERROR:', err)
            return false
        })
    })
});
