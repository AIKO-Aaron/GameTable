function Button(x, y, w, h, text, c1, c2, c3, callback1, toggled) {
	callback1 = callback1 || null;
	this.x = x > 1 ? x / windowWidth : x;
	this.y = y > 1 ? y / windowHeight : y;
	this.w = w > 1 ? w / windowWidth : w;
	this.h = h > 1 ? h / windowHeight : h;
	this.toggled = toggled;
	this.setText(text);
	this.textColor = c1;
	this.backColor = c2;
	this.mouseColor = c3;
	this.mouseOver = false;
	this.pressed = false;
	this.circles = [];
	if(callback1 === null) this.callbacks = [];
	else this.callbacks = [callback1];
}

Button.prototype.toggle = function() {
	this.toggled = !this.toggled;
	bb = this.mouseColor;
	this.backColor = bb;
	this.mouseColor = this.backColor;
};

Button.prototype.set = function(b) {
	if(b != this.toggled) {
		this.toggled = !this.toggled;
		bb = this.mouseColor;
		this.backColor = bb;
		this.mouseColor = this.backColor;
	}
};

Button.prototype.render = function(g2d) {
	var x = this.x * windowWidth;
	var y = this.y * windowHeight;
	var w = this.w * windowWidth;
	var h = this.h * windowHeight;

	var cornersize = Math.min(w,h) / 2;
	//var ar = Math.sqrt(w * w + h * h) / 5;
	var ar = Math.min(w,h) / 100;
	//if(ar > 1) ar = 1;
	ar = 1;

	var bc;
	for(var i = 0; i < this.circles.length; i++) if(bc == null || this.circles[i].size > bc.size) bc = this.circles[i];
	g2d.fillStyle = this.circles.length === 0 ? (this.mouseOver ? this.mouseColor : this.backColor) : (this.mouseColor === bc.color ? this.backColor : this.mouseColor);
	g2d.save();
	g2d.beginPath();	
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

	for(var i = 0; i < this.circles.length; i++) {
		g2d.fillStyle = this.circles[i].color;
		g2d.beginPath();
		g2d.arc(this.circles[i].x * windowWidth, this.circles[i].y * windowHeight, this.circles[i].size+=CIRCLE_SPEED, 0, 2 * Math.PI);
		g2d.fill();
		if(this.circles[i].size > Math.sqrt(w * w + h + h)) this.circles.splice(i--, 1);
	}
	
	this.renderText(g2d, this.text);

	g2d.restore();
};

Button.prototype.isInside = function (x, y) {
	return (x >= this.x * windowWidth && y >= this.y * windowHeight && x < (this.x + this.w) * windowWidth && y < (this.y + this.h) * windowHeight);
};

Button.prototype.setMouseOver = function (x, y) {
	mo = this.isInside(x, y);
	if(this.mouseOver === mo) return;
	this.mouseOver = mo;
	this.circles.push({x:x/windowWidth, y: y/windowHeight, size: 0, color: this.mouseOver ? this.mouseColor : this.backColor});
};

Button.prototype.setPressed = function(pressed) {
	this.pressed = pressed;
	if(pressed) {
		for(var i = 0; i < this.callbacks.length; i++) {
			this.callbacks[i](this);
		}
	}
};

Button.prototype.setText = function(text) {
	this.text = text;
	this.textoffset = 0;
};

Button.prototype.renderText = function(g2d, text) {
	if(g2d.measureText(text).width > this.w * windowWidth) {
		if(this.mouseOver) this.textoffset=(this.textoffset+1)%(g2d.measureText(text).width);
		else this.textoffset = 0;
		g2d.fillStyle = this.textColor;
		g2d.font = fontsize + "pt " + fontname;
		g2d.fillText(text, this.x * windowWidth - this.textoffset, this.y * windowHeight + (this.h+fontsize) / 2);
		g2d.fillText(text, this.x * windowWidth + g2d.measureText(text).width - this.textoffset, this.y * windowHeight + (this.h * windowHeight + fontsize) / 2);
	} else {
		g2d.fillStyle = this.textColor;
		g2d.font = fontsize + "pt " + fontname;
		g2d.fillText(text, this.x * windowWidth + (this.w * windowWidth - g2d.measureText(text).width) / 2, this.y * windowHeight + (this.h * windowHeight + fontsize) / 2);
	}
}

Button.prototype.addCallback= function(callback){
	this.callbacks.push(callback);
};