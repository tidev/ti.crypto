var App = {
	controllers: {},
	crypto: null,

	loadObject: function (type, name, params) {
		if (App[type] == null) { // eslint-disable-line
			Ti.API.warn('Trying to load an object that does not exist in the App namespace');
			return false;
		} else if (App[type][name] == null) { //eslint-disable-line
			require(type.toLowerCase() + '/' + name);
			Ti.API.info(type + ' ' + name + ' loaded');
			return new App[type][name](params);
		} else {
			Ti.API.info(type + ' ' + name + ' already loaded');
			return new App[type][name](params);
		}
	}
};
global.App = App;

// Load the crypto modules
var Crypto = require('ti.crypto');
global.Crypto = Crypto;

require('./ui');
require('./test');

App.UI.createAppWindow().open();
