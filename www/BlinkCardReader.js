var exec = require('cordova/exec');

var Cvv = null;
var androidKey = null;
var iosKey = null;

function BlinkCard() {
}

var params = {
  Cvv: Cvv,
  androidKey: androidKey,
  iosKey: iosKey
};

/**
 * Read code from BlinkCard.
 * @param {function} successCallback This function will recieve a result object: {
 *        cardNumber:'xxxx xxxx xxxx xxxx',
 *        cardgetOwner:'USERNAME',
 *        cardExpDate:'12-12-2019',
 *        cardCvv: 'xxx' //OPTIONAL RESULT
 *    }
 * @param {function} errorCallback
 * @param options
 */


BlinkCard.prototype.read = function (successCallback, errorCallback, params) {

  var options = {};

  options.androidKey = params.androidKey;
  options.iosKey = params.iosKey;
  options.Cvv = params.Cvv || false;
  options.returnFullDocumentImage = params.returnFullDocumentImage || false;


  if (errorCallback == null) {
    errorCallback = function () {
    };
  }

  if (typeof errorCallback != "function") {
    console.log("BlinkCardReader.read failure: failure parameter not a function");
    return;
  }

  if (typeof successCallback != "function") {
    console.log("BlinkCardReader.read failure: success callback parameter must be a function");
    return;
  }

  exec(
      function (objResult) {
        successCallback(objResult);
      },
      function (error) {
        errorCallback(error);
      },
      'BlinkCardReader',
      'read',
      [options]
  );
}

module.exports = new BlinkCard();
