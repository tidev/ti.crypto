App.UI = (function() {
	var cryptos = [
		{ title: 'AES-128', subTitle: '128-bit key',  keySize: App.crypto.KEYSIZE_AES128,  algorithm: App.crypto.ALGORITHM_AES128, options: App.crypto.OPTION_PKCS7PADDING },
		{ title: 'AES-128', subTitle: '192-bit key',  keySize: App.crypto.KEYSIZE_AES192,  algorithm: App.crypto.ALGORITHM_AES128, options: App.crypto.OPTION_PKCS7PADDING },
		{ title: 'AES-128', subTitle: '256-bit key',  keySize: App.crypto.KEYSIZE_AES256,  algorithm: App.crypto.ALGORITHM_AES128, options: App.crypto.OPTION_PKCS7PADDING },
		{ title: 'DES',     subTitle: '64-bit key',   keySize: App.crypto.KEYSIZE_DES,     algorithm: App.crypto.ALGORITHM_DES,    options: App.crypto.OPTION_PKCS7PADDING },
		{ title: '3DES',    subTitle: '192-bit key',  keySize: App.crypto.KEYSIZE_3DES,    algorithm: App.crypto.ALGORITHM_3DES,   options: App.crypto.OPTION_PKCS7PADDING },
		{ title: 'CAST',    subTitle: '40-bit key',   keySize: App.crypto.KEYSIZE_MINCAST, algorithm: App.crypto.ALGORITHM_CAST,   options: App.crypto.OPTION_PKCS7PADDING },
		{ title: 'CAST',    subTitle: '128-bit key',  keySize: App.crypto.KEYSIZE_MAXCAST, algorithm: App.crypto.ALGORITHM_CAST,   options: App.crypto.OPTION_PKCS7PADDING },
		{ title: 'RC4',     subTitle: '8-bit key',    keySize: App.crypto.KEYSIZE_MINRC4,  algorithm: App.crypto.ALGORITHM_RC4,    options: 0 },
		{ title: 'RC4',     subTitle: '4096-bit key', keySize: App.crypto.KEYSIZE_MAXRC4,  algorithm: App.crypto.ALGORITHM_RC4,    options: 0 },
		{ title: 'RC2',     subTitle: '8-bit key',    keySize: App.crypto.KEYSIZE_MINRC2,  algorithm: App.crypto.ALGORITHM_RC2,    options: App.crypto.OPTION_PKCS7PADDING },
		{ title: 'RC2',     subTitle: '1024-bit key', keySize: App.crypto.KEYSIZE_MAXRC2,  algorithm: App.crypto.ALGORITHM_RC2,    options: App.crypto.OPTION_PKCS7PADDING }
	];
	
	var selectedIndex = 0;

	function createAppWindow() {
		var tabGroup = Ti.UI.createTabGroup();		
		var win = createCryptoWindow();

		App.UI.tab = Ti.UI.createTab({ title: 'Algorithms', window: win });
		tabGroup.addTab(App.UI.tab);
		return tabGroup;
	};
		
	function createCryptoWindow() {
		var win = Ti.UI.createWindow({
			title: 'Algorithms',
			backgroundColor: 'white',
			tabBarHidden: true
		});
		
		win.add(createCryptoTableView());
		
		return win;
	};
		
	function createCryptoTableView() {
		var tableView = Ti.UI.createTableView({});
		var cnt = cryptos.length;
		for (var index = 0; index < cnt; index++) {
			row = Ti.UI.createTableViewRow({ height: 'auto', layout: 'vertical', hasChild: true });
			row.add(Ti.UI.createLabel({ text: cryptos[index].title, top: 0, left: 4, height: 'auto', width: 'auto', font: { fontSize:16, fontWeight: 'bold' } }));
			row.add(Ti.UI.createLabel({ text: cryptos[index].subTitle, top:0, left:4, height: 'auto', width: 'auto', font: { fontSize:12 } }));
			tableView.appendRow(row);
		}
		tableView.addEventListener('click', openSelectionWindow);

		return tableView;
	};
	
	function openSelectionWindow(e) {
		var win = Ti.UI.createWindow({
			title: 'API Usage',
			backgroundColor: 'white',
			tabBarHidden: true
		});
		
		var data = [
			{ title: 'Single call',    hasChild: true },
			{ title: 'Multiple calls', hasChild: true }
		];
		
		var tableView = Ti.UI.createTableView({
			data: data
		});
		
		tableView.addEventListener('click', function(e) {
			switch (e.index) {
				case 0:
					openDemoWindow('cryptoSingle');
					break;
				case 1:
					openDemoWindow('cryptoMultiple');
					break;
			}
		});
		
		win.add(tableView);
		
		selectedIndex = e.index;
		
		App.UI.tab.open(win, { animated: true });
	}
	
	function openDemoWindow(controller) {
		var demoWindow = Ti.UI.createWindow({
			backgroundColor: 'white',
			layout: 'vertical'
		});
		
		var demo = App.loadObject('controllers', controller, {});
		
		demoWindow.addEventListener('close', demo.cleanup);
		
		demo.init(cryptos[selectedIndex]);
		
		demo.create(demoWindow);

		App.UI.tab.open(demoWindow, { animated: true });	
	};
	
	return {
		createAppWindow: createAppWindow
	};
})();


App.UI.createAppWindow().open();
