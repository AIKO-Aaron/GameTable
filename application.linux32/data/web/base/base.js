var core = null;
var t1 = null;
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
	core.setTitle("GameTable v0.1");
	
	core.addText("Pin eingeben: ", 0, 0, "#FF00FF", 60, null)
	
	t1 = new TextField((1 - default_popup_size) / 2, default_popup_size / 2, 1 * default_popup_size, 0.5 * default_popup_size, "Pin", default_text_color, default_background_color, default_hover_color, true);
	core.addTextField(t1);
	core.addButton(new Button((1 - default_popup_size) / 2,  default_popup_size, 1 * default_popup_size, 0.5 * default_popup_size, "Verbinden", default_text_color, default_background_color, default_hover_color, function(){postRequestAsync("!cg<" + t1.text + ">", setGame); }));
}

function setGame(response) {
	window.location.href = response + "?id=" + t1.text;
}
