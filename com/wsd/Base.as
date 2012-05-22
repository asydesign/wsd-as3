﻿package com.wsd{	import com.hurlant.crypto.CryptoCode	import com.wsd.display.Overlay	import com.wsd.engine.AMF	import com.wsd.display.FPS		import flash.display.MovieClip	import flash.display.StageDisplayState	import flash.events.ContextMenuEvent	import flash.events.Event	import flash.events.ProgressEvent	import flash.external.ExternalInterface	import flash.net.URLLoader	import flash.net.URLLoaderDataFormat	import flash.net.URLRequest	import flash.net.URLRequestMethod	import flash.net.URLVariables	import flash.net.navigateToURL	import flash.system.Capabilities	import flash.system.System	import flash.text.TextField	import flash.ui.ContextMenu	import flash.ui.ContextMenuItem		public class Base extends MovieClip	{		public static var	version:String				= '0.1'				public static var 	TEST:Boolean				= false		public static var 	DEBUG:Boolean				= false		public static var 	LOG:Boolean					= false		public static var 	fps:Boolean					= false				public static var	app:Base		public static var	_stage:*		public static var	config:*		public static var 	lua:Object		public static var	overlay:*				public static var	constants:Object 			= new Object		public static var	platform:String				= null		public static var	status:Object				= new Object				public var 			container:MovieClip 		= new MovieClip		public var 			txtLog:TextField			= new TextField				private var			callback					= null		private var			xmlLoader:URLLoader 		= new URLLoader				public function Base(config:*, callback = null):void		{			Base.app = this;			Base.config = config;						Base.status.OK 		= AMF.OK;			Base.status.ERROR 	= AMF.ERROR;			Base.status.EXPIRED = AMF.EXPIRED;						this.callback = callback;						Base.platform = Capabilities.playerType.toLowerCase();			if (Base.platform == 'activex') 	Base.platform = 'plugin';						Base.log('==== WSD-AS3 v ' + Base.version + ' ====');			Base.log('Visit us on https://github.com/norman784/wsd-as3');			Base.log('=========================================');			Base.log('Base::Base(config: ' + config + ', callback: ' + callback + ', platform: ' + Base.platform + ')');						if (typeof(Base.config) != 'string') {				init();			} else {				xmlLoader.addEventListener(Event.COMPLETE, initXML, false, 0, true);				xmlLoader.load(new URLRequest(Base.config));			}		} // Base()				private function initXML( e:Event = null ):void		{			Base.log('Base::initXML()');						Base.config = new XML(e.target.data);						init();		} // initXML()				private function init():void		{			Base._stage = stage;			Base.log('Base::init()');						if (Base.config) {				if (Base.config.app != null) {					Base.TEST 	= Base.config.app.test	 	== 'true' ? true : false					Base.DEBUG 	= Base.config.app.debug 	== 'true' ? true : false					Base.LOG 	= Base.config.app.log 		== 'true' ? true : false					Base.fps 	= Base.config.app.fps 		== 'true' ? true : false					Base.config.app.fullscreen = Base.config.app.fullscreen == 'true' ? true : false				}								if (Base.config.copyright != null && Base.config.url != null) {					set_contextual_menu(Base.config.copyright, Base.config.url)				}			}						if (Base.config.app.fullscreen == true) {				stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE			}						Base.app.txtLog.visible = false;						if (Base.DEBUG == true) {				Base.app.txtLog.visible 	= true				Base.app.txtLog.width 		= Base._stage.width > 0 ? Base._stage.width : 100				Base.app.txtLog.height 		= 100				Base.app.txtLog.multiline 	= true				Base.app.txtLog.wordWrap 	= true				Base.app.txtLog.scrollV		= Base.app.txtLog.numLines - 8				//Base.app.txtLog.text		= Base.platform			}						if (Base.config.overlay == null) Base.config.overlay = new Object						Base.overlay = new Overlay(Base.config.overlay.text, Base.config.overlay)						addChild(container)			addChild(Base.overlay)			addChild(txtLog)			//if (Base.LOG == false) txtLog.visible = false						if (Base.fps) addChild(new FPS)						if (callback != null) callback()		} // init()				private function set_contextual_menu(author_copyright = null, author_url = null):void		{			/*			if (author_copyright == null || author_url == null) return						var contextual_menu:ContextMenu = new ContextMenu()			contextual_menu.hideBuiltInItems()						var copyright:ContextMenuItem = new ContextMenuItem(author_copyright)			copyright.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function(e:Event){				navigateToURL(new URLRequest(author_url), '_blank')			}, false, 0, true);			contextual_menu.customItems.push(copyright)			this.contextMenu = contextual_menu			*/		} // set_contextual_menu()				public static function AMFconnect(params, callbackSuccess = null, callbackError = null, method:String = "modules.Main.initialize"):void		{			Base.log('Base::AMFconnect(domain = ' + Base.config.proxy.domain + ', gateway = ' + Base.config.proxy.gateway + ')');						Base.constants.AMF = new Object;			Base.constants.AMF.domain = Base.config.proxy.domain;			Base.constants.AMF.gateway = Base.config.proxy.domain + '' + Base.config.proxy.gateway;						Base.log('Base::AMFconnect(domain = ' + Base.constants.AMF.domain + ', gateway = ' + Base.constants.AMF.gateway + ')');						if (callbackSuccess == null) callbackSuccess = function( e:Event ) {				Base.log('Base::AMFconnect(response = ' + e.target.response.status + ')');				if(e.target.response && e.target.response.status == this.AMF.OK) {					Base.overlay.show('Inicializado con exito');				} else {					Base.overlay.show('No se ha podido inicializar la aplicación, por favor inténtelo más tarde');				}								service.removeEventListener('success', callbackSuccess);			}						if (callbackError == null) callbackError = function( e:Event ) {				Base.overlay.show('No se ha podido inicializar la aplicación, por favor inténtelo más tarde');				service.removeEventListener('error', callbackError);			}						var service = AMF.service();			service.addEventListener('success', callbackSuccess, false, 0, true);			service.addEventListener('error', callbackError, false, 0, true);			service.call(method, params);		} // AMFconnect				public static function AMFcall(method, params, callbackSuccess = null, callbackError = null):void		{			Base.log('Base::AMFcall(method = ' + method + ')');						if (callbackSuccess == null) callbackSuccess = function( e:Event ) {				if(e.target.response && e.target.response.status == com.wsd.engine.AMF.OK) {					Base.log('AMF::callbackSuccess');					Base.overlay.show('Se ha realizado correctamente la conexión con el servidor');				} else {					Base.log('AMF::callbackSuccess ' + e.target.response.exception, 'ERROR');					Base.overlay.show('Se ha perdido la conexión con el servidor, por favor inténtelo más tarde');				}								service.removeEventListener('success', callbackSuccess);			}						if (callbackError == null) callbackError = function( e:Event ) {				Base.log('AMF::callbackError undefined');				Base.overlay.show('Se ha perdido la conexión con el servidor, por favor inténtelo más tarde');				service.removeEventListener('error', callbackError);			}						var service = AMF.service();			service.addEventListener('success', callbackSuccess, false, 0, true);			service.addEventListener('error', callbackError, false, 0, true);			service.call(method, params);		} // AMFcall()				public static function add(child:*, name = 'main', clearAll:Boolean = true):void		{			if (clearAll == true) Base.removeAll();						Base.log('Base::add(child = ' + child + ', name = ' + name + ', clearAll = ' + clearAll + ')');						Base.app.container.addChild(child);			child.name = name;		} // add()				public static function center(child:*, alignV:Boolean = true, alignH:Boolean = true):void		{			var mc:* = MovieClip(Base.app.container.getChildByName(child));						Base.log('Base::center(childName = ' + child + ', alignV = ' + alignV + ', alignH = ' + alignH + ')', (mc == null ? 'ERROR' : ''));			Base.log('Base::_stage = ' + Base._stage);						if (mc == null) return;			/*			if (alignV) {				mc.y = Base._stage.height / 2 - mc.height / 2;			}						if (alignH) {				mc.x = Base._stage.width / 2 - mc.width / 2;			}			*/		} // center()				public static function remove(name, from = null):void		{			Base.log('Base::remove(name = ' + name + ')');						if (from == null) from = Base.app.container						from.removeChild( Base.app.container.getChildByName(name) );						System.gc()			System.gc()		} // remove()				public static function removeAll(from = null):void		{			Base.overlay.hide();						if (from == null) from = Base.app.container						while(from.numChildren>0)			{				Base.log('Base::removeAll(removed ' + from.getChildAt(from.numChildren-1) + ')');				from.removeChildAt(from.numChildren-1);			}						System.gc()			System.gc()		} // removeAll()				public static function hide(name):void		{			Base.log('Base::hide(name = ' + name + ')');						Base.app.container.getChildByName(name).visible = false;		} // hide()				public static function show(name):void		{			Base.log('Base::show(name = ' + name + ')');						Base.app.container.getChildByName(name).visible = true;		} // show()				public static function navigateToURL(url, target:String = '_self'):void		{			Base.log('Base::navigateToURL(url = ' + url + ', target = ' + target + ')');						flash.net.navigateToURL(new URLRequest(url), target);		} // navigateToURL()				public static function post(url:String, data:*, param:* = null):void		{			Base.log('Base::post(url = ' + url + ', data = ' + data + ', encode = ' + encode + ')');						var request:URLRequest = new URLRequest (url); 			request.method = URLRequestMethod.POST; 						var variables:URLVariables = new URLVariables();			var i:*;			var hash:String = 'olm';			var encode:Boolean = false;			var callback:Function = function(e:Event = null){};						if (typeof param == 'boolean') encode = param;			if (typeof param == 'function') callback = param;						if (Base.config != null) {				if (Base.config.app != null) {					if (Base.config.app.hash != null) hash = Base.config.app.hash;				}			}						if (encode == true) {				var crypto = new CryptoCode(hash);				for (i in data)				{					variables[i] = crypto.encrypt(data[i]);					//Base.log('Base::post(data[' + i + '] = ' + variables[i] + ')');				}			} else {				for (i in data)				{					variables[i] = data[i];					//Base.log('Base::post(data[' + i + '] = ' + data[i] + ')');				}			}			     			request.data = variables;						var postCallback:Function = function( e:Event ):void			{				Base.log('Base::post response = ' + e.target.data);				loader.removeEventListener(Event.COMPLETE, postCallback);				callback(e);			}						var loader:URLLoader = new URLLoader (request);			loader.dataFormat = URLLoaderDataFormat.TEXT;			loader.addEventListener(Event.COMPLETE, postCallback, false, 0, true);			loader.load(request);		} // post()				public static function externalCall(method, params = null):void		{			if (Base.platform != 'plugin') {				//Base.log('Base::externalCall(method = ' + method + ', params = ' + params + ') palfform: ' + Base.platform, 'ERROR');				return;			}						Base.log('Base::externalCall(method = ' + method + ', params = ' + params + ')');			ExternalInterface.call(method, params);		} // externalCall()				public static function addExternalCall(method, callback):void		{			if (Base.platform != 'plugin') {				//Base.log('Base::addExternalCall(method = ' + method + ', callback = ' + callback + ') palfform: ' + Base.platform, 'ERROR');				return;			}						Base.log('Base::addExternalCall(method = ' + method + ', callback = ' + callback + ')');			ExternalInterface.addCallback(method, callback);		} // addExternalCall()				public static function log(string, type = 'INFO'):void		{			if (Base.LOG) {				if (Base.DEBUG) {					Base.constants.debug 		= type + "::" + string + "\n";					if (Base.app != null) {						if (Base.app.txtLog != null && Base._stage != null) {							Base.app.txtLog.appendText(Base.constants.debug);						}					}				}								trace(type + "::" + string);				//externalCall('console.log', type + "::" + string);			}		} // log()				public static function rand(low:Number=0, high:Number=1) :int		{			return Math.floor(Math.random() * (1+high-low)) + low;		} // rand()				public static function var_dump(object, tab:int = 0):void {			if (object == null) return;			var tabDeep:String = '';			for (var i:int = 0; i < tab; ++i) 	tabDeep += '	';						Base.log(tabDeep + '	' + typeof(object) + ' => ' + object, 'VAR_DUMP');						for (var key:String in object)			{				Base.log(tabDeep + '	' + key, 'VAR_DUMP');				Base.var_dump(object[key], tab+1);			}		} // var_dump()	}}