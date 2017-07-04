var core = null;
var menu1 = null;
var digital_menu = null;
var analog_menu = null;
var mainmenu = null;
var back = null;

var lm = 0;

const TEXT_LENGTH = 5; // In sekunden
const default_popup_size = 0.45;

const default_background_color = "#00A000";
const default_hover_color = "#4444FF";
const default_text_color = "#FFFFFF";
const default_text_hover_color = "#FFFFFF";

function moveUp() {
	for(var i = 0; i < core.texts.length; i++) core.texts[i].y -= fontsize;
}

function setup() {
	core = new AikoCore(document.getElementById("frame"));
	
	core.defaultTextCallbacks = moveUp;
	
	core.addButton(new Button(0.5 - default_popup_size / 4, default_popup_size / 2, default_popup_size / 2, default_popup_size / 4, "Home", default_text_color, default_background_color, default_hover_color, goHome));
	core.addButton(new Button(0.5 - default_popup_size / 2, default_popup_size / 4 * 3, default_popup_size / 2, default_popup_size / 4, "Left", default_text_color, default_background_color, default_hover_color, rotateLeft));
	core.addButton(new Button(0.5, default_popup_size / 4 * 3, default_popup_size / 2, default_popup_size / 4, "Right", default_text_color, default_background_color, default_hover_color, rotateRight));
	core.addButton(new Button(0.5 - default_popup_size / 4, default_popup_size, default_popup_size / 2, default_popup_size / 4, "Right", default_text_color, default_background_color, default_hover_color, rotateRight));


	postRequestAsync("!gc<" + getUrlVars().id + ",listener>", goHome);

	core.setTitle("Tetris");
}

function goHome() {
	postRequestAsync("!gc<" + getUrlVars().id + ",stop>", null);
	window.location.href = "http://" + window.location.host;
}

function goDown() {
	postRequestAsync("!gc<" + getUrlVars().id + ",down>", null);
}

function rotateLeft() {
	postRequestAsync("!gc<" + getUrlVars().id + ",left>", null);
}

function rotateRight() {
	postRequestAsync("!gc<" + getUrlVars().id + ",right>", null);
}