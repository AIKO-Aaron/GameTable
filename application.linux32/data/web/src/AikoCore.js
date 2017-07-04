const CIRCLE_SPEED = 20;

const fontsize = 20;
const fontname = "ComicSans";
const fadeout_speed = 5;

function AikoCore(frame) {
	aiko_core_instance = this;

	this.selectedObject = null;

	// Frame Setup
	this.frame = frame;
	this.g2d = frame.getContext("2d");
	frame.style.backgroundColor = "#FFFFFF";
	frame.oncontextmenu = function(e){e.preventDefault();}
	frame.addEventListener("mousemove", this.onMouseMove);
	frame.addEventListener("mousedown", this.onMousePress);
	frame.addEventListener("keydown", this.onkeyDown);
	frame.addEventListener("keypress", this.onKeyPress);
	//frame.addEventListener("keyup", this.onKeyUp);
	this.windowResized();
	this.defaultTextCallbacks = null;

	// Set up the objects in the frame
	this.buttons = [];
	this.textfields = [];
	this.popups = [];
	this.texts = [];

	// Utilities?
	// Setup the window stuff
	window.addEventListener("resize", this.windowResized);
	window.addEventListener("keydown", this.onKeyDown);
	window.addEventListener("keypress", this.onKeyPress);
	//window.addEventListener("keyup", this.onKeyUp);
	document.body.style.margin = "0px";

	// Start the clock to render every 60th of a second (60 FPS)
	this.interval = window.setInterval(this.renderAll, 1000 / 60);
}

AikoCore.prototype.onMousePress = function(e) {
	for(var i = 0; i < aiko_core_instance.popups.length; i++) aiko_core_instance.popups[i].onMousePress(e, aiko_core_instance)
	if(e.button === left) {
		var clicked = null;
		for(var i = 0; i < aiko_core_instance.textfields.length; i++) {if(aiko_core_instance.textfields[i].isInside(e.x, e.y)) {if(clicked == aiko_core_instance.textfields[i] || isMobile) {aiko_core_instance.textfields[i].onClick(e.x);clicked = aiko_core_instance.textfields[i];} else clicked = aiko_core_instance.textfields[i];}}
		
		for(var i = 0; i < aiko_core_instance.buttons.length; i++) if(aiko_core_instance.buttons[i].isInside(e.x, e.y)) {aiko_core_instance.buttons[i].setPressed(true);}
		aiko_core_instance.selectedObject = clicked;
	} else if(e.button === right) {
		for(var i = 0; i < aiko_core_instance.textfields.length; i++) if(aiko_core_instance.textfields[i].isInside(e.x, e.y)) {aiko_core_instance.textfields[i].setText("");clicked = aiko_core_instance.textfields[i];}
	}
};

AikoCore.prototype.windowResized = function(e) {
	windowWidth = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
	windowHeight = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;

	frame.width = windowWidth;
	frame.height = windowHeight;
};

AikoCore.prototype.onMouseMove = function(e) {
	for(var i = 0; i < aiko_core_instance.popups.length; i++) aiko_core_instance.popups[i].onMouseMove(e.x, e.y);
	for(var i = 0; i < aiko_core_instance.buttons.length; i++) aiko_core_instance.buttons[i].setMouseOver(e.x, e.y);
	for(var i = 0; i < aiko_core_instance.textfields.length; i++) aiko_core_instance.textfields[i].onMouseMove(e.x, e.y);
};

AikoCore.prototype.onKeyDown = function(e) {
	if(aiko_core_instance.selectedObject != null) aiko_core_instance.selectedObject.onKeyDown(e);
};

AikoCore.prototype.onKeyPress = function(e) {
	if(aiko_core_instance.selectedObject != null) aiko_core_instance.selectedObject.onKeyPress(e);
};

/**AikoCore.prototype.onKeyUp = function(e) {
	if(aiko_core_instance.selectedObject != null) aiko_core_instance.selectedObject.onKeyUp(e);
};*/

AikoCore.prototype.renderAll = function() {
	aiko_core_instance.g2d.fillStyle = "#FFFFFF";
	aiko_core_instance.g2d.fillRect(0, 0, windowWidth, windowHeight);

	for(var i = 0; i < aiko_core_instance.buttons.length; i++) aiko_core_instance.buttons[i].render(aiko_core_instance.g2d);
	for(var i = 0; i < aiko_core_instance.textfields.length; i++) aiko_core_instance.textfields[i].render(aiko_core_instance.g2d);
	for(var i = 0; i < aiko_core_instance.popups.length; i++) aiko_core_instance.popups[i].render(aiko_core_instance.g2d);
	for(var i = 0; i < aiko_core_instance.texts.length; i++) {aiko_core_instance.renderText(i);}
};

AikoCore.prototype.renderText = function(i) {
	this.g2d.font = fontsize + "pt " + fontname;
	this.g2d.fillStyle = this.texts[i].color;
	if(this.texts[i].time === -1) this.g2d.fillText(this.texts[i].text, this.texts[i].x, this.texts[i].y + fontsize);
	else if(this.texts[i].time === 0 && (this.texts[i].fadeout+=fadeout_speed) < 0xFF) {
		var opacity = (1.0 - this.texts[i].fadeout / 0xFF);
		this.g2d.save();
		this.g2d.globalAlpha = opacity;
		this.g2d.fillText(this.texts[i].text, this.texts[i].x, this.texts[i].y + fontsize);
		this.g2d.restore();
	}
	else if(this.texts[i].fadeout >= 0xFF) {
		var callback = this.texts[i].callback;
		this.texts.splice(i, 1);
		if(callback) callback();
	}
	else if(this.texts[i].time-- > 0) this.g2d.fillText(this.texts[i].text, this.texts[i].x, this.texts[i].y + fontsize);
}

AikoCore.prototype.clear = function() {
	this.buttons = [];
	this.textfields = [];
	// this.texts = [];
	this.popups = [];
};

AikoCore.prototype.addButton = function(b) {
	this.buttons.push(b);
};

AikoCore.prototype.addTextField = function(b) {
	this.textfields.push(b);
};

AikoCore.prototype.removeButton = function(b) {
	this.buttons.splice(this.buttons.indexOf(b), 1);
};

AikoCore.prototype.openPopup = function(p) {
	this.popups.push(p);
};

AikoCore.prototype.closePopup = function(p) {
	this.popups.splice(this.popups.indexOf(p), 1);
};

AikoCore.prototype.addText = function(text, x, y, color, time, callback) {
	this.texts.push({x: x, y: y, text: text, color: color, time: time || -1, fadeout: 0, callback: callback || this.defaultTextCallbacks});
}

AikoCore.prototype.removePopup = function(p) {
	this.popups.splice(this.popups.indexOf(p), 1);
};

AikoCore.prototype.setTitle = function(title) {
	document.title = title;
}

function getUrlVars() {
	var vars = {};
	var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
		vars[key] = value;
	});
	return vars;
}

var windowWidth = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
var windowHeight = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;

const mie = (function(){

    var undef,
        v = 3,
        div = document.createElement('div'),
        all = div.getElementsByTagName('i');

    while (
        div.innerHTML = '<!--[if gt IE ' + (++v) + ']><i></i><![endif]-->',
        all[0]
    );

    return v > 4 ? v : undef;

}());
const left = mie ? 1 : 0, right = 2;

function iOS() {

  var iDevices = [
    'iPad Simulator',
    'iPhone Simulator',
    'iPod Simulator',
    'iPad',
    'iPhone',
    'iPod'
  ];

  if (!!navigator.platform) {
    while (iDevices.length) {
      if (navigator.platform === iDevices.pop()){ return true; }
    }
  } else console.log("no navigator.platform!!!");

  return false;
}

var isMobile = false; //initiate as false
// device detection
if(/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|ipad|iris|kindle|Android|Silk|lge |maemo|midp|mmp|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino/i.test(navigator.userAgent)
    || /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(navigator.userAgent.substr(0,4))) isMobile = true;
