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

exports.sendAdminNotification = functions.database.ref('/pokestops/{pushId}').onWrite(event => {
         const payload = {
             notification: {
                title: `New Quest`,
                body: `Foo Foooooo`,
                sound: `default`
             }
         };
    admin.messaging().sendToTopic("pokestops", payload)
});