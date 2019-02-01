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

exports.sendRaidPush = functions.database.ref('/arenas/{geohash}/{uid}').onWrite((snapshot, context) => {

    const uid = context.params.uid;
    const geohash = context.params.geohash;
    
    const arena = snapshot.after.val();
    const name = arena.name;
    const raid = arena.raid;
    const level = raid.level;
    const raidBoss = raid.raidBoss;
    const hatchTime = raid.hatchTime;
    const startTime = raid.startTime;

    admin.database().ref('/arenas/' + geohash + '/registered_user').once('value', (snapshot, context) => { 
        snapshot.forEach(function(child) {
            const userId = child.val();
            admin.database().ref('/users/' + userId).once('value', (snapshot, context) => { 
                const notificationToken = (snapshot.val() && snapshot.val().notificationToken) || 'No token';
                const trainer = (snapshot.val() && snapshot.val().trainerName) || 'Unknown';

                const payload = {
                    notification: {
                       title: 'Neuer Raid',
                       body: name,
                       sound: 'default'
                    }
                };
            
                admin.messaging().sendToDevice(notificationToken, payload)
            });
        });
    });
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
    const questName = pokestop.quest.name;
    const questReward = pokestop.quest.reward;
    // const users = currentValue.registred_user;
    // const token = users.pushToken;
    // console.log(token);
    // var userId = admin.auth().currentUser.uid;
    // console.log("userId: " + userId);

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
                       body: questName + ": "+ questReward,
                       sound: 'default'
                    }
                };
            
                admin.messaging().sendToDevice(notificationToken, payload)
            });
        });
    });

    

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
