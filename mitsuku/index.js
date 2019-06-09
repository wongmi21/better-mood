const Promise = require('bluebird');
const superagent = require('superagent');

function getRawHtmlForMessage(message) {
  return new Promise((resolve, reject) => {
    const agent = superagent.agent();
    const endpoint = 'https://miapi.pandorabots.com/talk?botkey=n0M6dW2XZacnOgCWTp0FRYUuMjSfCkJGgobNpgPv9060_72eKnu3Yl-o1v2nFGtSXqfwJBG2Ros~&input=' + encodeURIComponent(message) + '&client_name=cw16b3a6b1646&sessionid=403366564&channel=6';
    let req;

    req = agent.post(endpoint);
    agent.attachCookies(req);
    req
      .set({ 'cache-control': 'no-cache', Connection: 'keep-alive', 'content-length': '', 'accept-encoding': 'gzip, deflate', Host: 'miapi.pandorabots.com', 'Cache-Control': 'no-cache', Accept: '*/*', Origin: 'https://www.pandorabots.com', Referer: 'https://www.pandorabots.com/mitsuku/', 'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.80 Safari/537.36' })
      .send({ message: message })
      .end(function(err, res) {
        if (err) {
          return reject(err);
        }
        agent.saveCookies(res);
        resolve(res.text);
      });
  });
}

function parseMessageFromJson(jsonStr) {
  const json = JSON.parse(jsonStr);
  return json.responses;
}

const firebase = require('firebase-admin');
firebase.initializeApp({
  credential: firebase.credential.cert({
    type: 'service_account',
    project_id: 'better-mood',
    private_key_id: 'c5abbb58e06d5a190396d5d332e9b79a3ea4d86d',
    private_key:
      '-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCtyeaLP5idRjmt\nfybHZ6SP9s26gMGCiqcYTASNKlTXm+WPCXEUHZnB51ARLJAKmr/2EEqD1ryeRsZf\n6VOTP6YZUMEILNQAASRcf5mYUyAsLZjgPX0WfeoXu5arsgvJ+dc8VxJs/tH/O09s\nLks2FUurTDzqsREmgdbZW4LTnsKZQaddCVEpkz2Bq/3TPXWMHi45Sg9dyoW5V80O\n4hTDyRiB9m3Fmnu/bL/XW/a8pwW+73K0e9iXa/4yOFDkan6XEaQNxQPloj8pbKup\nougItcb+gJ/elmbGylVWgHN+sVh7loHeyp46UsN+0yTsqaIFO4hudb9Ci3dJEi+c\nYb8c1lLRAgMBAAECggEADxXRPAGZdP9xRsDchB8YPwHgokGGapcwAXEpzPohcrS+\n1K9wYBtgqx7xyYfZef4sTwbjfPWxGjkRA6bMgSHbgGOM2fGQNm7i8d+GnN0MVCFi\nHYbg2oiz/vrizYUPNmlIOF3jhNAKuPG0R3LuRuPK1XPw7rtPfozzMhtaLBXiFOzk\nGf3XQ6yWX7ADtCgDQlExlMWJSmZQDN8OWnyXTdpdxSSgaSEyV2k4fFMpKZ3LqsV8\nWYM4aPtfkwiVO58FcXr+t+QJcUdSkEIw6+9i+4Ts+KEUJZl1g5tu9BPHNbBPKAFA\nE4hBtJqd0DNc5HK8Gr1pCY7/tcQvjmX8Qfa/j2d3lQKBgQDdPkYG7oEtzbVPluLT\n/FRnZ/IMhP9AtXsZjlFE+L/SHk1n0T7TCDcoAGbTeGO5tZmKta/xhSn7txtV4sRJ\nEjwCvYCtGFMQl1wBO4F4KOd9/PkJVIp+/avJU9KVldKJZvQUjOuL6Aq8ZZL6JADm\nswi6oJ/ojT8W9gPg3Fh5Ra673QKBgQDJFyYlVyWLbrB+urrY5e8FBab8OSukRi19\nk+Vpc65yKefusEzgosxuIgNHqPorMaNwC4GTVnG7F0KLXz13UliV7BJfc1Q05pxX\nTrecAIaWbYqRdRUdQVSz+JDlTXVMr+GX+rkXWGX1CfcAnXPL+9/au2T8gijG8haA\nhg1SY46NhQKBgE0/6C2Va491qyAeHBdOnJ36gl5ytbl/ZHsY4TGG9VtFb1uXiSsg\nTDnwYfbmq1N1oCX5qHRZPb6BQc8sPcMR1dhTGLHXs3EwmFRp1ZwCFEo+YSor1avf\noPLMDNRkGr4VL5ZZWglgvRbpFHe4yIPE8YBQg2UspGG9Br+l0FKPzSIVAoGBAJzD\nERe28ivaZHjG9PY1ebm+iEjEAMOVec0VyJgGeI3DIW2vvp64CwooNcpdbnjRv4mP\nTroff5XMMjIYUwB8D1cAq+oBLDn5NRPS58wTlNgcGRP/5C/kSDXspng7hB/+VK13\n5WbPoNv/orC2DhmNBxurTrSSe1tsSiJzXltGBVFJAoGBANICQ39DTKDd9iq3uaGN\n19DpaxHajKueWuvv0aN2Ty79tloiRR/KDOzhbusjcMvzgK0uPCcM09bu1pN9bBJe\njMbXXvsxqjrIixGfe/VMTqIMSDgGfMZypyFEVG88Ay9LU25oTnRJj1ejE88YqkYn\npiwYC/ZZ6cUhU3cCAoKDVOpR\n-----END PRIVATE KEY-----\n',
    client_email: 'firebase-adminsdk-4ahz2@better-mood.iam.gserviceaccount.com',
    client_id: '103314046100206627152',
    auth_uri: 'https://accounts.google.com/o/oauth2/auth',
    token_uri: 'https://oauth2.googleapis.com/token',
    auth_provider_x509_cert_url: 'https://www.googleapis.com/oauth2/v1/certs',
    client_x509_cert_url: 'https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-4ahz2%40better-mood.iam.gserviceaccount.com'
  })
});
const db = firebase.firestore();

db.collection('chats')
  .where('name', '==', 'MDU')
  .get()
  .then(snapshot => {
    const chatId = snapshot.docs[0].id;
    db.collection('chats/' + chatId + '/messages').onSnapshot(snapshot => {
      const docChanges = snapshot.docChanges();
      const docChangeData = docChanges[0].doc.data();
      if (docChanges.length === 1 && docChangeData['type'] === 0 && docChangeData['userId'] !== 'robot') {
        const text = docChanges[0].doc.data()['content'];
        getRawHtmlForMessage(text).then(json => {
          const responses = parseMessageFromJson(json);
          responses.forEach(response => {
            // tslint:disable-next-line: no-void-expression
            const extractImages = response.match(/.*<image>(.*)<\/image>.*/);
            if (extractImages) {
              respond(chatId, 1, extractImages[1]);
              // tslint:disable-next-line: no-void-expression
              const noImageText = response.replace(/ *<image>.*<\/image>[. ]*/g, '');
              // if (noImageText !== undefined && noImageText !== null) {
              respond(chatId, 0, noImageText);
              // }
            } else {
              respond(chatId, 0, response);
            }
          });
        });
      }
    });
  })
  .catch(e => console.log(e));
function respond(chatId, type, content) {
  db.collection('chats/' + chatId + '/messages')
    .add({
      userId: 'robot',
      userAvatar: 'robot',
      type: type,
      content: content,
      timestamp: String(new Date().getTime())
    })
    .catch(e => console.log(e));
}
