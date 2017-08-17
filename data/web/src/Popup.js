function Popup(text, backgroundColor, textColor, mouseColor, optionMouseColor, options, optionActions, w, h) {
	this.centered = true;
	this.backColor = backgroundColor;
	this.textColor = textColor;
	this.mouseColor = mouseColor;
	this.optionMouseColor = optionMouseColor;
	this.text = text;
	this.options = options;
	this.optionActions = optionActions;
	this.cornersize = fontsize / 500;

	this.circles = [];
	this.mouseOver = false;

	this.buttons = options.length;

	this.w = this.w || w || (function(g2d, text, options) {
		g2d.font = fontsize + "pt " + fontname;
		var width = g2d.measureText(text).width * 1.2;
		for(var i = 0; i < options.length; i++) width = Math.max(width, g2d.measureText(options[i]).width * 1.2);
		return width / windowWidth;
	}(aiko_core_instance.g2d, this.text, this.options));

	this.h = h || fontsize * 2 * (this.buttons + 1) / windowHeight;
	this.ar = Math.sqrt(this.w * this.w + this.h * this.h) / 2;
	this.buttonHeight = (this.h * windowHeight - fontsize - this.h * windowHeight / 10) / this.buttons;
}

Popup.prototype.render = function(g2d) {
	var w = this.w * windowWidth;
	var h = this.h * windowHeight + 10;
	
	var cornersize = Math.min(w, h) / 1000;
	var ar = Math.sqrt(w * w + h * h) / 8;

	var bc;
	for(var i = 0; i < this.circles.length; i++) if(bc == null || this.circles[i].size > bc.size) bc = this.circles[i];
	g2d.fillStyle = this.circles.length === 0 ? (this.mouseOver ? this.mouseColor : this.backColor) : (this.mouseColor === bc.color ? this.backColor : this.mouseColor);
	var x = (windowWidth - w) / 2;
	var y = (windowHeight - h) / 2;
	g2d.save();
	g2d.beginPath();
	//g2d.rect(x, y, w, h + 2);	
	g2d.moveTo(x, y + h * cornersize);
	g2d.arcTo(x, y, x + w * cornersize, y, ar * cornersize);
	g2d.lineTo(x + w * (1-cornersize), y);
	g2d.arcTo(x + w, y, x + w, y + h * cornersize, ar * cornersize);
	g2d.lineTo(x + w, y + h * (1-cornersize));
	g2d.arcTo(x + w, y + h, x + w * (1-cornersize), y + h, ar * cornersize);
	g2d.lineTo(x + w * cornersize, y + h);
	g2d.arcTo(x, y + h, x, y + h * (1-cornersize), ar * cornersize);
	g2d.clip();
	g2d.fillRect(0, 0, windowWidth, windowHeight);
	
	h -= 10;

	for(var i = 0; i < this.circles.length; i++) {
		g2d.fillStyle = this.circles[i].color;
		g2d.beginPath();
		g2d.arc(this.circles[i].x * windowWidth, this.circles[i].y * windowHeight, this.circles[i].size+=CIRCLE_SPEED, 0, 2 * Math.PI);
		g2d.fill();
		if(this.circles[i].size > Math.sqrt(w * w + h + h)) this.circles.splice(i--, 1);
	}

	g2d.fillStyle = this.textColor;
	g2d.font = fontsize + "pt " + fontname;
	g2d.fillText(this.text, x + w / 10, y + fontsize + h / 10);

	for(var i = 0; i < this.options.length; i++) {
		g2d.fillStyle = this.selectedButton === 1+i ? this.optionMouseColor : this.textColor;
		g2d.fillText(this.options[i], x + w / 10, y + i * this.buttonHeight + 75 + this.buttonHeight / 2);
	}

	g2d.restore();
};

Popup.prototype.onMousePress = function(e, parent) {
	var ypos = e.y - (windowHeight - this.h * windowHeight) / 2-75;
	var xpos = e.x - (windowWidth - this.w * windowWidth) / 2;
	if(ypos < 0 || ypos > this.h * windowHeight || xpos < 0 || xpos > this.w * windowWidth) return true;
	this.selectedButton = Math.floor(ypos / this.buttonHeight + 1); // TODO call action and close this
	if(this.selectedButton < 1 || this.selectedButton > this.optionActions.length) return true;
	this.optionActions[this.selectedButton - 1]();
	parent.removePopup(this);
	return true;
};

Popup.prototype.isInside = function (x, y) {
	var xx = (windowWidth - this.w * windowWidth) / 2;
	var yy = (windowHeight - this.h * windowHeight) / 2;
	return (x >= xx && y >= yy && x < xx + this.w * windowWidth && y < yy + this.h * windowHeight);
};

Popup.prototype.onMouseMove = function(x, y) {
	mo = this.isInside(x, y);
	if(this.mouseOver != mo) {
		this.mouseOver = mo;
		this.circles.push({x:x / windowWidth, y: y / windowHeight, size: 0, color: this.mouseOver ? this.mouseColor : this.backColor});
	}

	var ypos = y - (windowHeight - this.h * windowHeight) / 2-75;
	var xpos = x - (windowWidth - this.w * windowWidth) / 2;
	if(ypos < 0 || ypos > this.h * windowHeight || xpos < 0 || xpos > this.w * windowWidth) return this.selectedButton = 0;
	this.selectedButton = Math.floor(ypos / this.buttonHeight + 1);
};

Popup.prototype.setText = function(text) {
	this.text = text;
	this.w = this.w < 1 ? this.w : (function(g2d, text, options) {
		g2d.font = fontsize + "pt " + fontname;
		var width = g2d.measureText(text).width * 1.2;
		for(var i = 0; i < options.length; i++) width = Math.max(width, g2d.measureText(options[i]).width * 1.2);
		return width;
	}(aiko_core_instance.g2d, this.text, this.options));
	this.ar = Math.sqrt(this.w * this.w + this.h * this.h) / 2;
}
