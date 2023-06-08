document.addEventListener("deviceready", onDeviceReady, false);
function onDeviceReady() {
    checkConnection();
}

function checkConnection() {
    var networkState = navigator.connection.type;

    var states = {};
    states[Connection.UNKNOWN]  = 'Unknown connection';
    states[Connection.ETHERNET] = 'Ethernet connection';
    states[Connection.WIFI]     = 'WiFi connection';
    states[Connection.CELL_2G]  = 'Cell 2G connection';
    states[Connection.CELL_3G]  = 'Cell 3G connection';
    states[Connection.CELL_4G]  = 'Cell 4G connection';
    states[Connection.CELL]     = 'Cell generic connection';
    states[Connection.NONE]     = 'No network connection';

    alert('Connection type: ' + states[networkState]);
}


//     alert('Connection type: ' + states[networkState]);
// }
// function checkOffLine(minutes) {
//     if (window.lastCheckTime == null) {
//         window.lastCheckTime = 0;
//     }
//     var currentTime = (new Date()).getTime();
//     if (currentTime < (window.lastCheckTime + minutes * 60000)) return;
//     window.lastCheckTime = currentTime;

//     // ios does not allow you to exit the application so just warn
//     // ios also require you to warn or your app get rejected
//     if (window.isIOS) {
//         navigator.notification.alert('This application may not function properly without an internet connection.');
//     } else {
//         navigator.notification.confirm(
//             'This application may not function properly without an internet connection.  Continue working offline?', // message
//             function(button)      // callback to invoke with index of button pressed
//             {
//                 if (button == 1) {
//                     navigator.app.exitApp();
//                 }  
//             },
//             'Warning', // title
//             'Exit,Continue'                     // buttonLabels
//         );
//     }
// }
// function checkConnection() {
//     // your check connection type code here or just use navigator.onLine
//     if (!navigator.onLine) {
//         // don't be annoying, only confirm for once every every 5 minutes
//         checkOffLine(5);
//     }
// }
// // initial phonegap deviceready handler
// function onDeviceReady() {
//     console.log('Application started');
//     //angular.bootstrap(document, ['assetsApp']);
//     if (window.isPhoneGap) {
//         document.addEventListener("offline", checkConnection, false);
//         checkConnection();
//     }
// };
// function onBodyLoad() {
//     // these are useful later in the app, might as well set early
//     window.isRipple = (window.tinyHippos != null);
//     window.isPhoneGap = /^file:\/{3}[^\/]/i.test(window.location.href);
//     window.isIOS = !window.isRipple && navigator.userAgent.match(/(ios|iphone|ipod|ipad)/gi) != null;
//     window.isAndroid = !window.isRipple && navigator.userAgent.match(/(android)/gi) != null;

//     // stuff I use for debugging in chrome
//     if (window.isPhoneGap) {
//         document.addEventListener("deviceready", onDeviceReady, false);
//     } else {
//         onDeviceReady();
//     }
// }