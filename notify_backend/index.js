const axios = require('axios');

var admin = require("firebase-admin");
var serviceAccount = require("./adminsdk");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

function sendNotification(token, title, body) {
  var payload = {
    notification: {
      title: title,
      body: body,
      sound: "default"
    },
  };

  admin.messaging().sendToDevice(token, payload)
    .then(function(response) {
      console.log("Successfully sent message:", response);
    })
    .catch(function(error) {
      console.log("Error sending message:", error);
    });
}

setInterval(() => {
  (async () => {
    const dluxRunners = await axios.get('https://token.dlux.io/runners');
    const dluxQueue = await axios.get('https://token.dlux.io/queue');
    const spkRunners = await axios.get('https://spkinstant.hivehoneycomb.com/runners');
    const spkQueue = await axios.get('https://spkinstant.hivehoneycomb.com/queue');
    const duatRunners = await axios.get('https://heyhey.hivehoneycomb.com/runners');
    const duatQueue = await axios.get('https://heyhey.hivehoneycomb.com/queue');
    const dluxRunnerAccounts = dluxRunners.data.result.map(runner => runner.account);
    const dluxQueueAccounts = Object.keys(dluxQueue.data.queue);
    const spkRunnerAccounts = spkRunners.data.result.map(runner => runner.account);
    const spkQueueAccounts = Object.keys(spkQueue.data.queue);
    const duatRunnerAccounts = duatRunners.data.result.map(runner => runner.account);
    const duatQueueAccounts = Object.keys(duatQueue.data.queue);
    const db = admin.firestore();
    var collection = db.collection('users');
    var snapshot = await collection.get();
    snapshot.forEach(doc => {
      doc.data().dlux.forEach(dluxN => {
        if (!(dluxRunnerAccounts.includes(dluxN) || dluxQueueAccounts.includes(dluxN))) {
          console.log(dluxN, 'is not in the queue or running');
          sendNotification(doc.data().token, 'Dlux Notifier', `Dlux node "${dluxN}" is not in the queue or running`);
        }
      });
      doc.data().spkcc.forEach(spkccN => {
        if (!(spkRunnerAccounts.includes(spkccN) || spkQueueAccounts.includes(spkccN))) {
          console.log(spkccN, 'is not in the queue or running');
          sendNotification(doc.data().token, 'SPKCC Notifier', `SPKCC node "${spkccN}" is not in the queue or running`);
        }
      });
      doc.data().duat.forEach(duatN => {
        if (!(duatRunnerAccounts.includes(duatN) || duatQueueAccounts.includes(duatN))) {
          console.log(duatN, 'is not in the queue or running');
          sendNotification(doc.data().token, 'DUAT Notifier', `DUAT node "${duatN}" is not in the queue or running`);
        }
      });
    });
  })();
}, 180000);