const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);


exports.sendRaidPush = functions.region('europe-west1').database.ref('/arenas/{geohash}/{uid}').onWrite((snapshot, context) => {

    const geohash = context.params.geohash
    const arena = snapshot.after.val()
    const raid = arena.raid
    const raidBossId = raid.raidBossId || '---'

    //Get registered users
    return admin.database().ref('/registeredUsersArenas/' + geohash).once('value', (registeredUsersSnapshot, context) => {

        //Get Raidboss
        return admin.database().ref('/raidBosses/' + raidBossId).once('value', (raidBossSnapshot, context) => { 
            const raidBossName = (raidBossSnapshot.val() && raidBossSnapshot.val().name) || '---'

            //Get Meetup
            return admin.database().ref('/raidMeetups/' + raid.raidMeetupId).once('value', (meetupSnapshot, context) => {
                const raidMeetupTime = (meetupSnapshot.val() && meetupSnapshot.val().meetupTime) || '---'
                const hatchTime = raid.hatchTime || "---"
                const message = 'Level: ' + raid.level + '\nRaidboss: ' + raidBossName + '\nSchlüpft: ' + hatchTime + '\nTreffpunkt: ' + raidMeetupTime
                console.log('Message: ' + message)

                var promises = []

                //Loop through users
                registeredUsersSnapshot.forEach((child) => {
                    const userId = child.key
        
                    const p = admin.database().ref('/users/' + userId).once('value', (usersSnapshot, context) => { 

                        const notificationToken = (usersSnapshot.val() && usersSnapshot.val().notificationToken) || 'No token'
                        const platform = usersSnapshot.val().platform || "fallback"
                        console.log('Pushing to userID: ' + userId)
                        console.log('Platform: ' + platform)

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
                            }
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
                            }
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
                            }
                        }

                        if (usersSnapshot.val().isPushActive) {
                            admin.messaging().sendToDevice(notificationToken, payload)
                            .then((response) => {
                                console.log("Successfully sent message: ", response)
                                return true
                            })
                        } else {
                            console.log('Push not active... continuing')
                            return true
                        }
                    })
                    promises.push(p)
                })
                return Promise.all(promises)
            })
        })
    })
})


exports.sendNewQuestPushNotification = functions.region('europe-west1').database.ref('/pokestops/{geohash}/{uid}').onWrite((snapshot, context) => {
    
    const geohash = context.params.geohash
    const uid = context.params.uid

    const pokestop = snapshot.after.val()
    const name = pokestop.name
    const quest = pokestop.quest
    const questId = quest.definitionId

    return admin.database().ref('/quests/' + questId).once('value', (questDefinitionSnapshot) => { 
        const questName = questDefinitionSnapshot.val().quest
        const questReward = questDefinitionSnapshot.val().reward
    
        console.log('Pokestop name: ' + pokestop.name + ', with ID: ' + uid + ', in geohash: ' + geohash + ', has new quest: ' + quest.name + ', with reward: ' + quest.reward)

        return admin.database().ref('/registeredUsersPokestops/' + geohash).once('value', (snapshot, context) => {
            snapshot.forEach((child) => {
                const userId = child.key
                console.log('Pushing to userID: ' + userId)
                admin.database().ref('/users/' + userId).once('value', (snapshot, context) => { 
                    
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
                                longitude: String(pokestop.longitude)
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
    
                    return admin.messaging().sendToDevice(notificationToken, payload)
                });
            });
        })
    })
})


exports.sendRaidMeetupChatPush = functions.region('europe-west1').database.ref('/raidMeetups/{meetupId}/chat/{messageId}').onWrite((snapshot, context) => {
    const meetupId = context.params.meetupId
    const messageContainer = snapshot.after.val()
    const message = messageContainer.message
    const senderId = messageContainer.senderId

    //Get participants
    return admin.database().ref('/raidMeetups/' + meetupId + '/participants').once('value', (participantSnapshot, context) => { 

        //Get sender
        return admin.database().ref('/users/' + senderId).once('value', (senderSnapshot, context) => {

            const publicData = senderSnapshot.val().publicData
            const senderName = publicData.trainerName

            //Loop through userIds
            participantSnapshot.forEach((participant) => {
                const userId = participant.key
                console.log('Sending push to UserId: ' + userId)            

                //Get user to push to
                admin.database().ref('/users/' + userId).once('value', (userSnapshot, context) => { 

                    const notificationToken = (userSnapshot.val() && userSnapshot.val().notificationToken) || 'No token'
                    const platform = userSnapshot.val().platform || "fallback"

                    // fallback
                    var payload = {
                        notification: {
                            title: 'Neue Nachricht von: ' + senderName,
                            body: message,
                            badge: '1',
                            sound: 'default'
                        }
                    }

                    if (platform === "iOS") {
                        payload = {
                            notification: {
                                title: 'Neue Nachricht von: ' + senderName,
                                body: message,
                                badge: '1',
                                sound: 'default'
                            }
                        };
                    }
    
                    if (platform === "android") {
                        payload = {
                            data: {
                                title: 'Neue Nachricht von: ' + senderName,
                                body: message
                            }
                        };    
                    }

                    return admin.messaging().sendToDevice(notificationToken, payload)
                })
            })
        })
    })
})