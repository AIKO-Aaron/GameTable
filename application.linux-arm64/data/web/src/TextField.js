function TextField(x, y, w, h, text, c1, c2, c3, deleteOnClick) {
	deleteOnClick = deleteOnClick || false;

	this.x = x;
	this.y = y;
	this.w = w;
	this.h = h;
	this.cornersize = 1 / 10;
	this.ar = Math.sqrt(this.w * this.w + this.h * this.h) / 2;
	this.text = text;
	this.textColor = c1;
	this.backColor = c2;
	this.mouseColor = c3;
	this.deleteOnClick = deleteOnClick;
	this.deleted = false;
	this.mouseOver = false;
	this.circles = [];
	this.textoffset = 0;
}

TextField.prototype.render = function(g2d) {
	var x = this.x * windowWidth;
	var y = this.y * windowHeight;
	var w = this.w * windowWidth;
	var h = this.h * windowHeight;

	var cornersize = Math.min(w,h) / 2;
	//var ar = Math.sqrt(w * w + h * h) / 5;
	var ar = Math.min(w,h) / 2 * 1.5;
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

TextField.prototype.setText = function(t) {
	this.textoffset = 0;
	this.text = t;
}

TextField.prototype.onClick = function(x) {
	if(!this.deleted && this.deleteOnClick && !isMobile) {
		console.log("clicked");
		this.deleted = true;
		this.text = "";
	}
	if(isMobile) {
		this.setText(prompt(this.text));
	}
	//var pos = this.x - x;
}

TextField.prototype.isInside = function (x, y) {
	return (x >= this.x * windowWidth && y >= this.y * windowHeight && x < (this.x + this.w) * windowWidth && y < (this.y + this.h) * windowHeight);
};

TextField.prototype.onKeyDown = function(e) {
	if(e.keyCode == 8) this.text = this.text.substring(0, this.text.length - 1);
};

TextField.prototype.onKeyPress = function(e) {
	if(e.key != "Enter") this.text += e.key;
};

TextField.prototype.onMouseMove = function(x, y) {
	mo = this.isInside(x, y);
	if(this.mouseOver === mo) return;
	this.mouseOver = mo;
	this.circles.push({x: x/windowWidth, y: y/windowHeight, size: 0, color: this.mouseOver ? this.mouseColor : this.backColor});
};

TextField.prototype.renderText = function(g2d, text) {
	if(g2d.measureText(text).width > this.w * windowWidth) {
		if(this.mouseOver) this.textoffset=(this.textoffset+1)%(g2d.measureText(text).width);
		else this.textoffset = 0;
		g2d.fillStyle = this.textColor;
		g2d.font = fontsize + "pt " + fontname;
		var off = 0;
		if(aiko_core_instance.selectedObject == this) off = g2d.measureText(text).width - this.w * windowWidth;
		else off = this.textoffset;
		g2d.fillText(text, this.x * windowWidth - off, this.y + (this.h+fontsize) / 2);
		g2d.fillText(text, this.x * windowWidth + g2d.measureText(text).width - off, this.y * windowHeight + (this.h * windowHeight + fontsize) / 2);
	} else {
		g2d.fillStyle = this.textColor;
		g2d.font = fontsize + "pt " + fontname;
		g2d.fillText(text, this.x * windowWidth + (this.w * windowWidth - g2d.measureText(text).width) / 2, this.y * windowHeight + (this.h * windowHeight + fontsize) / 2);
	}
}
