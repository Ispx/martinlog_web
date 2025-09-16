importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: 'AIzaSyBojaKfglolWvClT-VwYW9QzU2RGKi_e9E',
  appId: '1:1062375327946:web:3ae61c6e184e8e75130c33',
  messagingSenderId: '1062375327946',
  projectId: 'martinlog-web',
  authDomain: 'martinlog-web.firebaseapp.com',
  databaseURL:
      '',
  storageBucket: 'martinlog-web.appspot.com',
  measurementId: 'G-CWVH9LC3GF',
});
// Necessary to receive background messages:
const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((m) => {
  console.log("onBackgroundMessage", m);
});