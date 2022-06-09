importScripts("https://www.gstatic.com/firebasejs/7.15.5/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/7.15.5/firebase-messaging.js");



if ('serviceWorker' in navigator) {
navigator.serviceWorker.register('../firebase-messaging-sw.js')
  .then(function(registration) {
    console.log('Registration successful, scope is:', registration.scope);
  }).catch(function(err) {
    console.log('Service worker registration failed, error:', err);
  });
}
/*
firebase.initializeApp({
  apiKey: "AIzaSyCY1f4u3bOur9U4ERWBCkD5ZCk7bst0qF0",
  projectId: "fita-340610",
  messagingSenderId: "934356910219",
  authDomain: 'fita-340610.firebaseapp.com',
    databaseURL: 'https://fita-340610.firebaseio.com',
    storageBucket: 'fita-340610.appspot.com',
  appId: "1:934356910219:android:3b6560b627a9bde643148e"),
});
final _messaging = FBMessaging.instance;
_messaging.requestPermission().then((_) async {
  final _token = await _messaging.getToken();
  print('Token: $_token');
});
const messaging = firebase.messaging();
messaging.setBackgroundMessageHandler(function (payload) {
    const promiseChain = clients
        .matchAll({
            type: "window",
            includeUncontrolled: true
        })
        .then(windowClients => {
            for (let i = 0; i < windowClients.length; i++) {
                const windowClient = windowClients[i];
                windowClient.postMessage(payload);
            }
        })
        .then(() => {
            return registration.showNotification("New Message");
        });
    return promiseChain;
});
self.addEventListener('notificationclick', function (event) {
    console.log('notification received: ', event)
});
Stream<Map<String, dynamic>> onMessage()  async* {

    print('PlatformPushNotificationWeb.onMessage() started');
    handleData(Payload payload, EventSink<Map<String, dynamic>> sink) {
        Map<String,dynamic> message = {
          'notification': {
            'title': payload.notification.title,
            'body': payload.notification.body,
            'sound': true
          },
          'data': payload.data
        };
      sink.add(message);
    }

    final transformer = StreamTransformer<Payload, Map<String, dynamic>>.fromHandlers(
        handleData: handleData);

    yield* firebaseMessaging.onMessage.transform(transformer);
  }*/
