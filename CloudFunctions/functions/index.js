const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);

// exports.sendNewQuestNotification = functions.database.ref('/quests').onWrite(event=>{

//     var ref = admin.database().ref(`users/notificationToken`);
//     return ref.once("value", function(snapshot){
//          const payload = {
//               notification: {
//                   title: 'New Quest nearby',
//                   body: 'Tap here to check it out!'
//               }
//          };

//          admin.messaging().sendToDevice(snapshot.val(), payload)

//     }, function (errorObject) {
//         console.log("The read failed: " + errorObject.code);
//     });
// })

// exports.sendNotification = functions.database.ref('/pokestops/{pushId}').onWrite(event => {
//          const payload = {
//              notification: {
//                 title: `New Quest`,
//                 body: `Foo Foooooo`,
//                 sound: `default`
//              }
//          };
//     admin.messaging().sendToTopic("pokestops", payload)
// });

// exports.sendFollowerNotification = functions.database.ref('/followers/{followedUid}/{followerUid}')
//     .onWrite((change, context) => {
//       const followerUid = context.params.followerUid;
//       const followedUid = context.params.followedUid;
//       // If un-follow we exit the function.
//       if (!change.after.val()) {
//         return console.log('User ', followerUid, 'un-followed user', followedUid);
//       }
//       console.log('We have a new follower UID:', followerUid, 'for user:', followerUid);

//       // Get the list of device notification tokens.
//       const getDeviceTokensPromise = admin.database()
//           .ref(`/users/${followedUid}/notificationTokens`).once('value');

//       // Get the follower profile.
//       const getFollowerProfilePromise = admin.auth().getUser(followerUid);

//       // The snapshot to the user's tokens.
//       let tokensSnapshot;

//       // The array containing all the user's tokens.
//       let tokens;

//       return Promise.all([getDeviceTokensPromise, getFollowerProfilePromise]).then(results => {
//         tokensSnapshot = results[0];
//         const follower = results[1];

//         // Check if there are any device tokens.
//         if (!tokensSnapshot.hasChildren()) {
//           return console.log('There are no notification tokens to send to.');
//         }
//         console.log('There are', tokensSnapshot.numChildren(), 'tokens to send notifications to.');
//         console.log('Fetched follower profile', follower);

//         // Notification details.
//         const payload = {
//           notification: {
//             title: 'You have a new follower!',
//             body: `${follower.displayName} is now following you.`,
//             icon: follower.photoURL
//           }
//         };

//         // Listing all tokens as an array.
//         tokens = Object.keys(tokensSnapshot.val());
//         // Send notifications to all tokens.
//         return admin.messaging().sendToDevice(tokens, payload);
//       }).then((response) => {
//         // For each message check if there was an error.
//         const tokensToRemove = [];
//         response.results.forEach((result, index) => {
//           const error = result.error;
//           if (error) {
//             console.error('Failure sending notification to', tokens[index], error);
//             // Cleanup the tokens who are not registered anymore.
//             if (error.code === 'messaging/invalid-registration-token' ||
//                 error.code === 'messaging/registration-token-not-registered') {
//               tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
//             }
//           }
//         });
//         return Promise.all(tokensToRemove);
//       });
// });

exports.sendRaidPush = functions.database.ref('/arenas/{geohash}/{uid}').onWrite((snapshot, context) => {

    const uid = context.params.uid;
    const geohash = context.params.geohash;
    const snapshotKey = snapshot.after.key;
    const snapshotVal = snapshot.after.val();

    if (snapshotKey === 'registered_user') {
        return console.log("Neuer User registriert")
    }

    const arena = snapshot.after.val();
    const raid = arena.raid;

    console.log(snapshotVal);
    // const name = arena.name;
    // const raid = arena.raid;
    // const level = raid.level;
    // const raidBoss = raid.raidBoss;
    // const hatchTime = raid.hatchTime;
    // const startTime = raid.startTime;

    const getDeviceTokensPromise = admin.database().ref('/arenas/' + geohash + '/registered_user').once('value');
    console.log(getDeviceTokensPromise);

    // The snapshot to the user's tokens.
    let tokensSnapshot;

    // The array containing all the user's tokens.
    let tokens;

    return Promise.all([getDeviceTokensPromise, snapshotVal]).then(results => {
        tokensSnapshot = results[0];
        const arena = results[1];

        // Check if there are any device tokens.
        if (!tokensSnapshot.hasChildren()) {
            return console.log('There are no notification tokens to send to.');
        }
        console.log('There are', tokensSnapshot.numChildren(), 'tokens to send notifications to.');

        // Notification details.
        const payload = {
            notification: {
                title: 'Neuer Raid bei: ' + arena.name,
                body: 'Level: ' + raid.level + '\nRaidboss: ' + raid.raidBoss + '\nSchlüpft: ' + raid.hatchTime + '\nTreffpunkt: ' + raid.raidMeetup.meetupTime,
                sound: 'default'
            },
            data: {
                latitude: String(arena.latitude),
                longitude: String(arena.longitude)
            }
        };

        // Listing all tokens as an array.
        console.log(tokensSnapshot.val())
        tokens = Object.keys(tokensSnapshot.val());
        // console.log('Tokens: ' + tokensSnapshot.val());
        // Send notifications to all tokens.
        return admin.messaging().sendToDevice(tokens, payload);
        }).then((response) => {
            // For each message check if there was an error.
            const tokensToRemove = [];
            response.results.forEach((result, index) => {
                const error = result.error;
                if (error) {
                    console.error('Failure sending notification to', tokens[index], error);
                    // Cleanup the tokens who are not registered anymore.
                    if (error.code === 'messaging/invalid-registration-token' ||
                        error.code === 'messaging/registration-token-not-registered') {
                        tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
                    }
                }
        });
    return Promise.all(tokensToRemove);
    });



      //////////


    // admin.database().ref( '/arenas/' + geohash + "/raid").once("value", snapshot => {
    //     if (snapshot.exists()){
    //        console.log("raid exists!");
    //     }
    //  });


    // admin.database().ref('/arenas/' + geohash + '/registered_user').once('value', (snapshot, context) => { 
    //     snapshot.forEach(function(child) {
    //         const userId = child.val();
    //         admin.database().ref('/users/' + userId).once('value', (snapshot, context) => { 
    //             const notificationToken = (snapshot.val() && snapshot.val().notificationToken) || 'No token';
    //             const trainer = (snapshot.val() && snapshot.val().trainerName) || 'Unknown';

    //             const payload = {
    //                 notification: {
    //                    title: 'Neuer Raid',
    //                    body: name,
    //                    sound: 'default'
    //                 }
    //             };
            
    //             admin.messaging().sendToDevice(notificationToken, payload)
    //         });
    //     });
    // });
});


exports.sendPush = functions.database.ref('/pokestops/{geohash}/{uid}').onWrite((snapshot, context) => {
    // const path = context.params;
    // console.log(path);
    const geohash = context.params.geohash;
    const uid = context.params.uid;
    console.log("geohash: " + geohash);
    console.log("uid: " + uid);
    console.log("snapshot: " + snapshot);

    const currentKey = snapshot.after.key;
    console.log("currentKey: " + currentKey);

    const pokestop = snapshot.after.val(); //Message Data
    console.log("Pokestop name: " + pokestop.name);

    const name = pokestop.name;
    // const hasQuest = (snapshot.val() && snapshot.val().quest);
    
    // if (hasQuest) {
        const quest = pokestop.quest
        const questName = quest.name;
        const questReward = quest.reward;
        
        admin.database().ref('/pokestops/' + geohash + '/registered_user').once('value', (snapshot, context) => { 
            // var notificationToken = (snapshot.val() && snapshot.val().pushToken) || 'No token';
            // console.log("notificationToken: " + notificationToken);
            // console.log("new snapshot");
            // console.log(snapshot.val());
            // console.log("new context");
            // console.log(context);
    
            snapshot.forEach(function(child) {
                const userId = child.val();
                console.log("userId: " + userId);
                admin.database().ref('/users/' + userId).once('value', (snapshot, context) => { 
                    const notificationToken = (snapshot.val() && snapshot.val().notificationToken) || 'No token';
                    const trainer = (snapshot.val() && snapshot.val().trainerName) || 'Unknown';
    
                    const payload = {
                        notification: {
                           title: 'Neue Feldforschung',
                           body: 'Pokestop: ' + name + '\nQuest: ' + questName + '\nBelohnung: ' + questReward,
                           sound: 'default',
                           mutable_content: 'true',
                           category : 'MEETING_INVITATION'

                        },
                        data: {
                            latitude: String(pokestop.latitude),
                            longitude: String(pokestop.longitude),
                            imageUrl: 'foo.jpg'
                        }
                    };
                
                    admin.messaging().sendToDevice(notificationToken, payload)
                });
            });
        });
    // }
    // const users = currentValue.registred_user;
    // const token = users.pushToken;
    // console.log(token);
    // var userId = admin.auth().currentUser.uid;
    // console.log("userId: " + userId);

    

    

    // currentValue.name
    // currentValue.type
    // currentValue.color

//   admin.database.ref('/pokestops/${path}/registred_users').once('value', (snapshot) => { 
//         const user = snapshot.val();
//         console.log(user);
//   });
//     var subscriber = snapshot.val();

//     subscriber.pushToken
//     subscriber.filters

//     if (filters.contains(currentValue.type)) {
//       tokens.push(subscriber.token);

//       // send push
//       admin.messaging().sendToDevice(tokens, payload).then(response => {
//         // For each message check if there was an error.
//       });
//     }
});
