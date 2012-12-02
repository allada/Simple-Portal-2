BlueBamboo = function (printerId){
	var emptyFn = function (){};
	var emptyErrFn = emptyFn;
	this.sendRawData = function (data, callback, errorCallback){
		cordova.exec(callback || emptyFn, errorCallback || emptyErrFn, "BlueBamboo", "sendRawData", [printerId, data]);
	};
	this.printRawText = function (data, callback, errorCallback){
		cordova.exec(callback || emptyFn, errorCallback || emptyErrFn, "BlueBamboo", "printText", [printerId, data]);
	};
	var textModifiers = {
		u:{			// underline
			args: [
				'size'
			],
			fn: function (args, isStart){
				if(isStart){
					if(args.size == '2'){
						return "\x1B\x2D\x02";
					}
					return "\x1B\x2D\x01";
				}
				return "\x1B\x2D\x00";
			}
		},		
		size:{		// tall letters
			args: [
				'height',
				'width'
			],
			fn: function (args, isStart){
				var oByte = 0;
				if(isStart){
					if(args.height == '2'){
						oByte |= 0x02;
					}
					if(args.width == '2'){
						oByte |= 0x20;
					}
				}
				return "\x1D\x21"+String.fromCharCode(oByte);
			}
		},	
		inverse:{	// inverses black and white
			args: [],
			fn: function (args, isStart){
				if(isStart){
					return "\x1D\x42\x01";
				}
				return "\x1D\x42\x00";
			}
		},	
		sleep:{		// makes printer pause for x seconds (example "<sleep for="1"> sleeps for 1 second)
			args: [
				'for'
			],
			fn: function (args, isStart){
				if(!isStart){
					return '';
                }
				return "\x1B\x7C"+String.fromCharCode(parseInt(args['for'] || 1));
			}
		},	
		lf:{		// Prints a line feed x lines
			args: [
				'for'
			],
			fn: function (args, isStart){
				if(!isStart){
					return '';
                }
				return "\x1B\x64"+String.fromCharCode(parseInt(args['for'] || 1));
			}
		},
		br:{		// Prints a line feed x lines (alias of "lf")
			args: [
				'for'
			],
			fn: function (args, isStart){
				if(!isStart){
					return '';
                }
				return "\x1B\x64"+String.fromCharCode(parseInt(args['for'] || 1));
			}
		},
		feed:{		// Feeds paper x units (number of pixles/pts)
			args: [
				'for'
			],
			fn: function (args, isStart){
				if(!isStart){
					return '';
                }
				return "\x1B\x4A"+String.fromCharCode(parseInt(args['for'] || 1));
			}
		},
		absolute:{	// Set absolute position of text (x, y)
			args: [
				'x',
				'y'
			],
			fn: function (args, isStart){
				if(isStart){
					return "\x1B\x24"+String.fromCharCode(parseInt(args.x || 0))+String.fromCharCode(parseInt(args.y || 0));
                }
				return "\x1B\x24\x00\x00";
			}
		},
		center:{	// Centers text
			args: [],
			fn: function (args, isStart){
				if(isStart){
					return "\x1B\x61\x01";
                }
				return "\x1B\x61\x00";
			}
		},
		left:{		// Puts text to left (default)
			args: [],
			fn: function (args, isStart){
				if(isStart){
					return "\x1B\x61\x00";
                }
				return "\x1B\x61\x00";
			}
		},
		right:{		// Puts text to the right
			args: [],
			fn: function (args, isStart){
				if(isStart){
					return "\x1B\x61\x02";
                }
				return "\x1B\x61\x00";	
			}
		},
		off:{		// Powers printer off
			args: [
				'in' // seconds after command received to power off
			],
			fn: function (args, isStart){
				if(!isStart){
					return '';
                }
				return "\x1D\x48"+String.fromCharCode(parseInt(args['in'] || 0));
			}
		},
		barcode:{		// Powers printer off
			args: [
				'type', // barcode type
				'data'  // barcode data
			],
			fn: function (args, isStart){
				if(!isStart){
					return '';
                }
				args['data'] = args['data'] || '';
				switch(args['type'] || 'code128'){
					case 'upc-a':
						for(var i=0;i<12;i++){
							if(args['data'].substr(i, 1).length == 0){
								args['data'] = '0'+args['data'];
							}
						}
						return "\x1D\x6B\x00\x0C"+args['data'].substr(0, 12);
						break;
					case 'upc-e':
						for(var i=0;i<8;i++){
							if(args['data'].substr(i, 1).length == 0){
								args['data'] = '0'+args['data'];
							}
						}
						return "\x1D\x6B\x01\x08"+args['data'].substr(0, 8);
						break;
					case 'ean-13':
						for(var i=0;i<13;i++){
							if(args['data'].substr(i, 1).length == 0){
								args['data'] = '0'+args['data'];
							}
						}
						return "\x1D\x6B\x02\x0D"+args['data'].substr(0, 13);
						break;
					case 'ean-8':
						for(var i=0;i<8;i++){
							if(args['data'].substr(i, 1).length == 0){
								args['data'] = '0'+args['data'];
							}
						}
						return "\x1D\x6B\x03\x08"+args['data'].substr(0, 8);
						break;
					default: // everything else is code128
						return "\x1D\x6B\x49"+String.fromCharCode((args['data'].length > 255)?255:args['data'])+args['data'].substr(0, 255);
				}
			}
		},	// Prints barcode
		keypad:{	// Enable/Disable keypad
			args: [
				'on' // seconds after command received to power off
			],
			fn: function (args, isStart){
				if(!isStart){
					return '';
                }
				return "\x1B\x63\x35"+String.fromCharCode(parseInt(args['on'] || 0));
			}
		}
	};
	this.printText = function (data, callback, errorCallback){
		var tms = [], i;
		for(i in textModifiers){
			tms.push(i);
		}
		var regExp = new RegExp('<(?:(/?)('+tms.join('|')+')([^>]*)\\s*(/?)\\s*>|(\r\n|\n|\r))', 'igm');
		var activeModifiers = {};
		var positions = {};
		var curPos = null;
        var regExpFn = function (full, closeTag, tag, params, selfClosing, nl){
			if(nl){
				return textModifiers.lf.fn({}, false);
            }
			if(textModifiers[tag]){
				var args = textModifiers[tag].args;
				var retArgs = {};
				if(args.length){
					var matches = params.match(/(?:^|\s)([a-zA-Z]+)=(["']?)((?:[^\"']|\\.)*)(?:\2)(?=\s|$)/igm);
                    if(matches){
						for(var i=0;i<matches.length;i++){
							match = matches[i].match(/(?:^|\s)([a-zA-Z]+)=(["']?)((?:[^\"']|\\.)*)(?:\2)(?=\s|$)/im);
							if(args.indexOf(match[1]) != -1){
								retArgs[match[1]] = match[3].replace(/\\(.)/g, '$1');
							}
						}
                    }
				}
				return textModifiers[tag].fn(retArgs, !!closeTag);
			}
			return full;
		};
		data = data.replace(regExp, regExpFn);
		this.printRawText(data, callback, errorCallback);
	};
	this.printCanvas = function (canvasEl, callback, errorCallback){
		if(canvasEl.toDataURL){
			cordova.exec(callback || emptyFn, errorCallback || emptyErrFn, "BlueBamboo", "printImage", [printerId, canvasEl.toDataURL("image/png")]);
			return true;
		}
		return false;
	};
	this.printImage = function (imageEl, callback, errorCallback){
		if(imageEl instanceof Image){
			var canvas = document.createElement('canvas');
			canvas.height = imageEl.height;
			canvas.width = imageEl.width;
			var ctx = canvas.getContext('2d');
			ctx.drawImage(imageEl, 0, 0);
			return this.printCanvas(canvas, callback, errorCallback);
		}
		return false;
	};
};
BlueBamboo.factory = function (printerId){
	if(BlueBamboo._printers[printerId]){
		return BlueBamboo._printers[printerId];
	}
	return new BlueBamboo(printerId);
};
BlueBamboo._printers = {};
BlueBamboo.getPrinters = function (){
	return BlueBamboo._printers;
};
BlueBamboo._listeners = {};
BlueBamboo.addEventListener = function (type, listener){
	if(!BlueBamboo._listeners[type]){
		BlueBamboo._listeners[type] = [];
	}
	BlueBamboo._listeners[type].push(listener);
};
BlueBamboo.removeEventListener = function (type, listener){
	if(!BlueBamboo._listeners[type]){
		return false;
	}
	var i=0, len = BlueBamboo._listeners[type].length, found = false;
	for(;i<len;i++){
		if(BlueBamboo._listeners[type][i] === listener){
			found = true;
			BlueBamboo._listeners[type].splice(i, 1);
		}
	}
	return found;
}
BlueBamboo._event = function (args){
	// args[0] is the event type
	switch(args[0]){
		case 'PrinterConnected':
			// args[1] is the device id
			if(BlueBamboo._listeners.PrinterConnected){
				var i=0,len = BlueBamboo._listeners.PrinterConnected.length;
				for(;i<len;i++){
					BlueBamboo._listeners.PrinterConnected[i](args[1]);
				}
			}
			BlueBamboo._printers[args[1]] = BlueBamboo.factory(args[1]);
			break;
		case 'PrinterDisconnected':
			if(BlueBamboo._listeners.PrinterDisconnected){
				var i=0,len = BlueBamboo._listeners.PrinterDisconnected.length;
				for(;i<len;i++){
					BlueBamboo._listeners.PrinterDisconnected[i](args[1]);
				}
			}
			var j;
			for(j in BlueBamboo._printers){
				if(BlueBamboo._printers[j] == args[1]){
					delete BlueBamboo._printers[j];
				}
			}
			break;
		case 'PrintingDone':
			//args[1] is the printer id
			//args[2] is the print id
			if(BlueBamboo._listeners.PrintingDone){
				var i=0,len = BlueBamboo._listeners.PrintingDone.length;
				for(;i<len;i++){
					BlueBamboo._listeners.PrintingDone[i](args[1], args[2]);
				}
			}
			break;
        case 'PrinterList':
        	for(var i=0;i<args[1].length;i++){
                BlueBamboo._event(['PrinterConnected', args[1][i]]);
            }
			break;
	}
};
document.addEventListener('deviceready', function (){
	cordova.exec(BlueBamboo._event, function (){}, "BlueBamboo", "monitor", []);
}, false);