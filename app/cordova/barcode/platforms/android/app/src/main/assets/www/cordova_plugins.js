cordova.define('cordova/plugin_list', function(require, exports, module) {
  module.exports = [
    {
      "id": "cordova-plugin-barcodescanner.BarcodeScanner",
      "file": "plugins/cordova-plugin-barcodescanner/www/barcodescanner.js",
      "pluginId": "cordova-plugin-barcodescanner",
      "clobbers": [
        "cordova.plugins.barcodeScanner"
      ]
    }
  ];
  module.exports.metadata = {
    "cordova-plugin-whitelist": "1.3.4",
    "cordova-plugin-barcodescanner": "0.7.4"
  };
});