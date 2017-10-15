#!/usr/bin/env perl
use Mojolicious::Lite;
app->config(hypnotoad => {listen => ['http://*:3004']});
# Documentation browser under "/perldoc"
plugin 'PODRenderer';

get '/' => sub {
  my $c = shift;
  $c->render(template => 'index', error => '');
};

get 'go' => sub {
    my $c = shift;
    my $err = '';
    my $temp = 'go';
    no strict 'refs';
    my $numberproducts = $c->req->params->to_hash->{'prods'};
    my @minnumbers = @{$c->req->params->to_hash->{'minnumfields[]'}}; #retrieves array of all entered minnumber fields in order
    my @prices = @{$c->req->params->to_hash->{'pricefields[]'}}; #retrieves array of all entered price fields in order
    use strict 'refs';
    #warn $#minnumbers;
    #warn $#prices;
    #warn @minnumbers;
    #warn @prices;
    #warn;
    my @minsort = sort { $a <=> $b } @minnumbers;
    my @pricesort = sort { $a <=> $b } @prices;
    warn @minsort;
    
   for(my $x = 0; $x < scalar @prices; $x++)  # validates prices are in order
   {
   		if($prices[-($x+1)] != $pricesort[$x]){
   			$err = '4';
   		}
   }
   for(my $x = 0; $x < scalar @minnumbers; $x++) #validates that minimum numbers are in order
   {
   		if($minnumbers[$x] != $minsort[$x]){
   			$err = '3';
   		}
   }
    if ($#minnumbers<1 ){ #validation for 2 or more tiers
    	warn 'the check works';
    	#$temp = index;
    	$err= 'Error: please add more fields';
    	$temp = 'index';
    	#$c->redirect_to('/', error => 'Error: add more fields scroob');
    }
    elsif($err == '3'){ # if mininmum numbers are not ordered creates error message 
    	$err = 'Error: minimum numbers not ordered from smallest at top to largest at bottom';
    	$temp = 'index';
    }
    elsif($err == '4'){ # if prices are not ordered creates error message
    	$err = 'Error: prices not ordered from largest at top to smallest at bottom';
    	$temp = 'index';
    }
    elsif($numberproducts < $minnumbers[0] || $numberproducts > $minnumbers[$#minnumbers]){ #validates number of products
    	$err = 'Error: number of products to purchase is out of bounds';
    	$temp = 'index';
    }
    my $i = 1;
    my $length = @minnumbers;
    my $maph = 0;
    while ($i < $length){
        if ($numberproducts < $minnumbers[$i]){
            $maph = $i;
            $i = $length
        }
        $i++;
    }

    my $p1 = $prices[($maph-1)] * $numberproducts;
   	my $p2 = $prices[$maph] * $minnumbers[$maph];
    my $resp = 'hey';
    my $resp2 = 'hey';
    if ($p1<$p2){
    	$resp = "Purchase $numberproducts products for the price of \$$p1.";
    	$resp2 = "It is more expensive to purchase $minnumbers[$maph] products for price of \$$p2."
    }
    
    else{
    	$resp = "Purchase $minnumbers[$maph] products for the price of \$$p2.";
    	$resp2 = "It is more expensive to purchase $numberproducts products for price of \$$p1."
    }
    

    $c->render(template => $temp, str => $resp, str2 => $resp2, error => $err);

};
app->secrets(['My very secret passphrase.']);
app->start;
__DATA__

@@ index.html.ep
<!DOCTYPE html>
    <html>
    <head>
    <title>Tier Calculator</title>
    <style>
      html {
        text-indent: 100px;
        font-family: Courier New;
    }
     
    #add_field_button {
        border-radius: 60px;
    padding: 10px 25px 10px 25px;
    position:fixed;
    top:0px;
    left:0px;
}
#minus_field_button {
    border-radius: 60px;
    padding: 10px 25px 10px 25px;
    position:fixed;
    top:50px;
    left:0px;
}

 

#submit_button {
    
    border-radius: 60px;
    padding: 10px 25px 10px 25px;
  display: inline-block;
  vertical-align: middle;
  -webkit-transform: perspective(1px) translateZ(0);
  transform: perspective(1px) translateZ(0);
  box-shadow: 0 0 1px transparent;
  overflow: hidden;
  -webkit-transition-duration: .3s;
  transition-duration: .3s;
  -webkit-transition-property: color, background-color;
  transition-property: color, background-color;
}
#submit_button:hover,  #submit_button:active {
    
    border-radius: 60px;
  background-color: #2098D1;
  color: white;
}

   
.hvr-shutter-in-vertical {
    border-radius: 60px;
  display: inline-block;
  vertical-align: middle;
  -webkit-transform: perspective(1px) translateZ(0);
  transform: perspective(1px) translateZ(0);
  box-shadow: 0 0 1px transparent;
  position: relative;
  background: #2098D1;
  -webkit-transition-property: color;
  transition-property: color;
  -webkit-transition-duration: 0.3s;
  transition-duration: 0.3s;
}
.hvr-shutter-in-vertical:before {
    border-radius: 60px;
  content: "";
  position: absolute;
  z-index: -1;
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
  background: #e1e1e1;
  -webkit-transform: scaleY(1);
  transform: scaleY(1);
  -webkit-transform-origin: 50%;
  transform-origin: 50%;
  -webkit-transition-property: transform;
  transition-property: transform;
  -webkit-transition-duration: 0.3s;
  transition-duration: 0.3s;
  -webkit-transition-timing-function: ease-out;
  transition-timing-function: ease-out;
}
.hvr-shutter-in-vertical:hover,  .hvr-shutter-in-vertical:active {
  color: white;
}
.hvr-shutter-in-vertical:hover:before,  .hvr-shutter-in-vertical:active:before {
  -webkit-transform: scaleY(0);
  transform: scaleY(0);
}
#top-image {
background:url('/bk.jpg') -25px -50px;
position:fixed ;
top:0;
width:100%;
z-index:-1;
  height:100%;
  background-size: calc(100% + 50px);
}
error {
	font-family: impact;
	color: red;
	font-size: 250%;

}

    </style>

        %= javascript 'http://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js'
        %= javascript begin
            $(document).ready(function() {

                var max_fields      = 10; //maximum input boxes allowed
                var wrapper         = $(".input_fields_wrap"); //Fields wrapper
                var add_button      = $("#add_field_button"); //Add button ID
                $(wrapper).append('<section><br>Number of products to purchase <input type="text" name="prods"/></section>'); //add input box
                $(wrapper).append('<div id = "container"'+x+' ><br>Minimum Number <input type="text" name="minnumfields[]"/>\
                     Price <input type="text" name="pricefields[]"/></div>'); //add input box
                $(wrapper).append('<div id = "container"'+x+' ><br>Minimum Number <input type="text" name="minnumfields[]"/>\
                     Price <input type="text" name="pricefields[]"/></div>'); //add input box
                var x = 0; //initial text box count
                var wrapd = $(".del");
                $(add_button).click(function(e){
                    e.preventDefault();
                    if(x < max_fields){ //max input box allowed
                    x++; //text box increment
                    $(wrapper).append('<div id = "container"'+x+' ><br>Minimum Number <input type="text" name="minnumfields[]"/>\
                     Price <input type="text" name="pricefields[]"/></div>'); //add input box
                    }
                });
    $('#minus_field_button').click(function(e){ //user click on remove text
        e.preventDefault(); $(this).parent().prev().children().last().remove('div'); x--;
    })
    
    var movementStrength = 25;
var height = movementStrength / $(window).height();
var width = movementStrength / $(window).width();
$("#top-image").mousemove(function(e){
          var pageX = e.pageX - ($(window).width() / 2);
          var pageY = e.pageY - ($(window).height() / 2);
          var newvalueX = width * pageX * -1 - 25;
          var newvalueY = height * pageY * -1 - 50;
          $('#top-image').css("background-position", newvalueX+"px     "+newvalueY+"px");
});
});


            % end
    </head>
    <body>
    <error><%=$error%></error>
    <h1>Tier Calculator</h1>
        %= form_for go => begin
        
    <section id="top-image"></section>
    <div class="input_fields_wrap">
    
    </div>
    <div class = "del">
    <button id="add_field_button", class = 'hvr-shutter-in-vertical'>+</button>
    <button id="minus_field_button", class='hvr-shutter-in-vertical'>-</button>
    %#<a href="#" class="remove_field">Remove</a>

    </div>
    <br><br>
        %= submit_button "Submit", id => 'submit_button';
        % end

    </body>
    </html>

@@ go.html.ep
<html>
<head>
<title>Tier Calculator</title>
<style>
* { margin: 0; padding: 0; }
html {
    font-family: "Courier";
    height: 100%;
}
body {
    color: #fff;
    font-size: 16px;
    font-family: "Courier New";
    background-image: url(/bg2.jpg);
    background-size: cover;
    background-position: 50% 0;
    height: 100%;
    text-align: center;
}
body:before {
    content: '';
    display: inline-block;
    vertical-align: middle;
    height: 100%;
}
main {
    display: inline-block;
    vertical-align: middle;
    background: url(/bg.jpg);
    border-radius: 30px;
    padding:  100px;
    max-width: 500px;
    text-shadow: 0 1px 2px rgba(0,0,0,0.5);
    box-shadow: 0 5px 15px rgba(0,0,0,0.5);
}
h1 {
    font-family: Courier;
   color:white;
    font-size: 32px;
    font-weight: bold;
    border-radius: 25px;
}
h2 {
	font-family: 'Courier';
    font-size: 18px;
    margin-top: 6px;
}
p {
    text-align: left;
    margin-top: 20px;
}
a {
    color: #ff6800;
}
pre {
    text-align: left;
    margin-top: 20px;
}
.error {
    display: none;
    position: fixed;
    bottom: 0;
    left: 0;
    background: #000;
    color: #f00;
    padding: 5px;
    max-width: 50%;
}
button {
    font-family: "Courier New";
    padding: 0 0.8em;
    line-height: 2em;
    border: none;
    background: url('/txtbk.png');
    color: #fff;
    text-shadow: 0 -1px 0 rgba(0,0,0,0.5);
    border-radius: 4px;
    cursor: pointer;
    margin-bottom: 0.5em;
    box-shadow: 0 2px 3px rgba(0,0,0,0.5);
}
button:hover {
    background: #888;
}
code { font-size: 1em; display: inline; color:white; font-family: "Courier New";}
.disable {
    position: fixed;
    bottom: 0;
    right: 0;
}
.code-string { color:#ec7600 }
.code-cbracket { font-weight:bold }
.code-number { color:#ffcd22 }


</style>
</head>
<body>

<main>
    <header>
        <h1><%=$str%></h1>
        <h2><%=$str2%></h2>
    </header>
 <br>
    

   
    <button class="js-ripples-pause" type="button">
        <code>Click to pause ripples</code>
    </button>

    <button class="js-ripples-play" type="button">
        <code>Click to play ripples</code>
    </button>
    
    
    <button class="js-ripples-disable disable">
    <code>Click to remove ripples</code>
</button>

</main>
<div class="error"></div>



<script src="https://ajax.googleapis.com/ajax/libs/jquery/2.0.0/jquery.min.js"></script>
<script src="../jquery.ripples.js"></script>
<script>
!function(e){"function"==typeof define&&define.amd?define(["jquery"],e):e("object"==typeof exports?require("jquery"):jQuery)}(function(e){"use strict";function t(e){return"%"==e[e.length-1]}function r(){function e(e,t){var i="OES_texture_"+e,o=i+"_linear",n=o in r,a=[i];return n&&a.push(o),{type:t,linearSupport:n,extensions:a}}var t=document.createElement("canvas");if(h=t.getContext("webgl")||t.getContext("experimental-webgl"),!h)return null;var r={};if(["OES_texture_float","OES_texture_half_float","OES_texture_float_linear","OES_texture_half_float_linear"].forEach(function(e){var t=h.getExtension(e);t&&(r[e]=t)}),!r.OES_texture_float)return null;var i=[];i.push(e("float",h.FLOAT)),r.OES_texture_half_float&&i.push(e("half_float",r.OES_texture_half_float.HALF_FLOAT_OES));var o=h.createTexture(),n=h.createFramebuffer();h.bindFramebuffer(h.FRAMEBUFFER,n),h.bindTexture(h.TEXTURE_2D,o),h.texParameteri(h.TEXTURE_2D,h.TEXTURE_MIN_FILTER,h.NEAREST),h.texParameteri(h.TEXTURE_2D,h.TEXTURE_MAG_FILTER,h.NEAREST),h.texParameteri(h.TEXTURE_2D,h.TEXTURE_WRAP_S,h.CLAMP_TO_EDGE),h.texParameteri(h.TEXTURE_2D,h.TEXTURE_WRAP_T,h.CLAMP_TO_EDGE);for(var a=null,s=0;s<i.length;s++)if(h.texImage2D(h.TEXTURE_2D,0,h.RGBA,32,32,0,h.RGBA,i[s].type,null),h.framebufferTexture2D(h.FRAMEBUFFER,h.COLOR_ATTACHMENT0,h.TEXTURE_2D,o,0),h.checkFramebufferStatus(h.FRAMEBUFFER)===h.FRAMEBUFFER_COMPLETE){a=i[s];break}return a}function i(e,t){try{return new ImageData(e,t)}catch(i){var r=document.createElement("canvas");return r.getContext("2d").createImageData(e,t)}}function o(e){var t=e.split(" ");if(1!==t.length)return t.map(function(t){switch(e){case"center":return"50%";case"top":case"left":return"0";case"right":case"bottom":return"100%";default:return t}});switch(e){case"center":return["50%","50%"];case"top":return["50%","0"];case"bottom":return["50%","100%"];case"left":return["0","50%"];case"right":return["100%","50%"];default:return[e,"50%"]}}function n(e,t,r){function i(e,t){var r=h.createShader(e);if(h.shaderSource(r,t),h.compileShader(r),!h.getShaderParameter(r,h.COMPILE_STATUS))throw new Error("compile error: "+h.getShaderInfoLog(r));return r}var o={};if(o.id=h.createProgram(),h.attachShader(o.id,i(h.VERTEX_SHADER,e)),h.attachShader(o.id,i(h.FRAGMENT_SHADER,t)),h.linkProgram(o.id),!h.getProgramParameter(o.id,h.LINK_STATUS))throw new Error("link error: "+h.getProgramInfoLog(o.id));o.uniforms={},o.locations={},h.useProgram(o.id),h.enableVertexAttribArray(0);for(var n,a,s=/uniform (\w+) (\w+)/g,u=e+t;null!=(n=s.exec(u));)a=n[2],o.locations[a]=h.getUniformLocation(o.id,a);return o}function a(e,t){h.activeTexture(h.TEXTURE0+(t||0)),h.bindTexture(h.TEXTURE_2D,e)}function s(e){var t=/url\(["']?([^"']*)["']?\)/.exec(e);return null==t?null:t[1]}function u(e){return e.match(/^data:/)}var h,c=e(window),d=r(),f=i(32,32);e("head").prepend("<style>.jquery-ripples { position: relative; z-index: 0; }</style>");var l=function(t,r){function i(){o.step(),requestAnimationFrame(i)}var o=this;this.$el=e(t),this.interactive=r.interactive,this.resolution=r.resolution,this.textureDelta=new Float32Array([1/this.resolution,1/this.resolution]),this.perturbance=r.perturbance,this.dropRadius=r.dropRadius,this.crossOrigin=r.crossOrigin,this.imageUrl=r.imageUrl;var n=document.createElement("canvas");n.width=this.$el.innerWidth(),n.height=this.$el.innerHeight(),this.canvas=n,this.$canvas=e(n),this.$canvas.css({position:"absolute",left:0,top:0,right:0,bottom:0,zIndex:-1}),this.$el.addClass("jquery-ripples").append(n),this.context=h=n.getContext("webgl")||n.getContext("experimental-webgl"),d.extensions.forEach(function(e){h.getExtension(e)}),e(window).on("resize",function(){var e=o.$el.innerWidth(),t=o.$el.innerHeight();e==o.canvas.width&&t==o.canvas.height||(n.width=e,n.height=t)}),this.textures=[],this.framebuffers=[],this.bufferWriteIndex=0,this.bufferReadIndex=1;for(var a=0;a<2;a++){var s=h.createTexture(),u=h.createFramebuffer();h.bindFramebuffer(h.FRAMEBUFFER,u),u.width=this.resolution,u.height=this.resolution,h.bindTexture(h.TEXTURE_2D,s),h.texParameteri(h.TEXTURE_2D,h.TEXTURE_MIN_FILTER,d.linearSupport?h.LINEAR:h.NEAREST),h.texParameteri(h.TEXTURE_2D,h.TEXTURE_MAG_FILTER,d.linearSupport?h.LINEAR:h.NEAREST),h.texParameteri(h.TEXTURE_2D,h.TEXTURE_WRAP_S,h.CLAMP_TO_EDGE),h.texParameteri(h.TEXTURE_2D,h.TEXTURE_WRAP_T,h.CLAMP_TO_EDGE),h.texImage2D(h.TEXTURE_2D,0,h.RGBA,this.resolution,this.resolution,0,h.RGBA,d.type,null),h.framebufferTexture2D(h.FRAMEBUFFER,h.COLOR_ATTACHMENT0,h.TEXTURE_2D,s,0),this.textures.push(s),this.framebuffers.push(u)}this.quad=h.createBuffer(),h.bindBuffer(h.ARRAY_BUFFER,this.quad),h.bufferData(h.ARRAY_BUFFER,new Float32Array([-1,-1,1,-1,1,1,-1,1]),h.STATIC_DRAW),this.initShaders(),this.initTexture(),this.setTransparentTexture(),this.loadImage(),h.clearColor(0,0,0,0),h.blendFunc(h.SRC_ALPHA,h.ONE_MINUS_SRC_ALPHA),this.visible=!0,this.running=!0,this.inited=!0,this.setupPointerEvents(),requestAnimationFrame(i)};l.DEFAULTS={imageUrl:null,resolution:256,dropRadius:20,perturbance:.03,interactive:!0,crossOrigin:""},l.prototype={setupPointerEvents:function(){function e(){return r.visible&&r.running&&r.interactive}function t(t,i){e()&&r.dropAtPointer(t,r.dropRadius*(i?1.5:1),i?.14:.01)}var r=this;this.$el.on("mousemove.ripples",function(e){t(e)}).on("touchmove.ripples, touchstart.ripples",function(e){for(var r=e.originalEvent.changedTouches,i=0;i<r.length;i++)t(r[i])}).on("mousedown.ripples",function(e){t(e,!0)})},loadImage:function(){var e=this;h=this.context;var t=this.imageUrl||s(this.originalCssBackgroundImage)||s(this.$el.css("backgroundImage"));if(t!=this.imageSource){if(this.imageSource=t,!this.imageSource)return void this.setTransparentTexture();var r=new Image;r.onload=function(){function t(e){return 0==(e&e-1)}h=e.context;var i=t(r.width)&&t(r.height)?h.REPEAT:h.CLAMP_TO_EDGE;h.bindTexture(h.TEXTURE_2D,e.backgroundTexture),h.texParameteri(h.TEXTURE_2D,h.TEXTURE_WRAP_S,i),h.texParameteri(h.TEXTURE_2D,h.TEXTURE_WRAP_T,i),h.texImage2D(h.TEXTURE_2D,0,h.RGBA,h.RGBA,h.UNSIGNED_BYTE,r),e.backgroundWidth=r.width,e.backgroundHeight=r.height,e.hideCssBackground()},r.onerror=function(){h=e.context,e.setTransparentTexture()},r.crossOrigin=u(this.imageSource)?null:this.crossOrigin,r.src=this.imageSource}},step:function(){h=this.context,this.visible&&(this.computeTextureBoundaries(),this.running&&this.update(),this.render())},drawQuad:function(){h.bindBuffer(h.ARRAY_BUFFER,this.quad),h.vertexAttribPointer(0,2,h.FLOAT,!1,0,0),h.drawArrays(h.TRIANGLE_FAN,0,4)},render:function(){h.bindFramebuffer(h.FRAMEBUFFER,null),h.viewport(0,0,this.canvas.width,this.canvas.height),h.enable(h.BLEND),h.clear(h.COLOR_BUFFER_BIT|h.DEPTH_BUFFER_BIT),h.useProgram(this.renderProgram.id),a(this.backgroundTexture,0),a(this.textures[0],1),h.uniform1f(this.renderProgram.locations.perturbance,this.perturbance),h.uniform2fv(this.renderProgram.locations.topLeft,this.renderProgram.uniforms.topLeft),h.uniform2fv(this.renderProgram.locations.bottomRight,this.renderProgram.uniforms.bottomRight),h.uniform2fv(this.renderProgram.locations.containerRatio,this.renderProgram.uniforms.containerRatio),h.uniform1i(this.renderProgram.locations.samplerBackground,0),h.uniform1i(this.renderProgram.locations.samplerRipples,1),this.drawQuad(),h.disable(h.BLEND)},update:function(){h.viewport(0,0,this.resolution,this.resolution),h.bindFramebuffer(h.FRAMEBUFFER,this.framebuffers[this.bufferWriteIndex]),a(this.textures[this.bufferReadIndex]),h.useProgram(this.updateProgram.id),this.drawQuad(),this.swapBufferIndices()},swapBufferIndices:function(){this.bufferWriteIndex=1-this.bufferWriteIndex,this.bufferReadIndex=1-this.bufferReadIndex},computeTextureBoundaries:function(){var e,r=this.$el.css("background-size"),i=this.$el.css("background-attachment"),n=o(this.$el.css("background-position"));if("fixed"==i?(e={left:window.pageXOffset,top:window.pageYOffset},e.width=c.width(),e.height=c.height()):(e=this.$el.offset(),e.width=this.$el.innerWidth(),e.height=this.$el.innerHeight()),"cover"==r)var a=Math.max(e.width/this.backgroundWidth,e.height/this.backgroundHeight),s=this.backgroundWidth*a,u=this.backgroundHeight*a;else if("contain"==r)var a=Math.min(e.width/this.backgroundWidth,e.height/this.backgroundHeight),s=this.backgroundWidth*a,u=this.backgroundHeight*a;else{r=r.split(" ");var s=r[0]||"",u=r[1]||s;t(s)?s=e.width*parseFloat(s)/100:"auto"!=s&&(s=parseFloat(s)),t(u)?u=e.height*parseFloat(u)/100:"auto"!=u&&(u=parseFloat(u)),"auto"==s&&"auto"==u?(s=this.backgroundWidth,u=this.backgroundHeight):("auto"==s&&(s=this.backgroundWidth*(u/this.backgroundHeight)),"auto"==u&&(u=this.backgroundHeight*(s/this.backgroundWidth)))}var h=n[0],d=n[1];h=t(h)?e.left+(e.width-s)*parseFloat(h)/100:e.left+parseFloat(h),d=t(d)?e.top+(e.height-u)*parseFloat(d)/100:e.top+parseFloat(d);var f=this.$el.offset();this.renderProgram.uniforms.topLeft=new Float32Array([(f.left-h)/s,(f.top-d)/u]),this.renderProgram.uniforms.bottomRight=new Float32Array([this.renderProgram.uniforms.topLeft[0]+this.$el.innerWidth()/s,this.renderProgram.uniforms.topLeft[1]+this.$el.innerHeight()/u]);var l=Math.max(this.canvas.width,this.canvas.height);this.renderProgram.uniforms.containerRatio=new Float32Array([this.canvas.width/l,this.canvas.height/l])},initShaders:function(){var e=["attribute vec2 vertex;","varying vec2 coord;","void main() {","coord = vertex * 0.5 + 0.5;","gl_Position = vec4(vertex, 0.0, 1.0);","}"].join("\n");this.dropProgram=n(e,["precision highp float;","const float PI = 3.141592653589793;","uniform sampler2D texture;","uniform vec2 center;","uniform float radius;","uniform float strength;","varying vec2 coord;","void main() {","vec4 info = texture2D(texture, coord);","float drop = max(0.0, 1.0 - length(center * 0.5 + 0.5 - coord) / radius);","drop = 0.5 - cos(drop * PI) * 0.5;","info.r += drop * strength;","gl_FragColor = info;","}"].join("\n")),this.updateProgram=n(e,["precision highp float;","uniform sampler2D texture;","uniform vec2 delta;","varying vec2 coord;","void main() {","vec4 info = texture2D(texture, coord);","vec2 dx = vec2(delta.x, 0.0);","vec2 dy = vec2(0.0, delta.y);","float average = (","texture2D(texture, coord - dx).r +","texture2D(texture, coord - dy).r +","texture2D(texture, coord + dx).r +","texture2D(texture, coord + dy).r",") * 0.25;","info.g += (average - info.r) * 2.0;","info.g *= 0.995;","info.r += info.g;","gl_FragColor = info;","}"].join("\n")),h.uniform2fv(this.updateProgram.locations.delta,this.textureDelta),this.renderProgram=n(["precision highp float;","attribute vec2 vertex;","uniform vec2 topLeft;","uniform vec2 bottomRight;","uniform vec2 containerRatio;","varying vec2 ripplesCoord;","varying vec2 backgroundCoord;","void main() {","backgroundCoord = mix(topLeft, bottomRight, vertex * 0.5 + 0.5);","backgroundCoord.y = 1.0 - backgroundCoord.y;","ripplesCoord = vec2(vertex.x, -vertex.y) * containerRatio * 0.5 + 0.5;","gl_Position = vec4(vertex.x, -vertex.y, 0.0, 1.0);","}"].join("\n"),["precision highp float;","uniform sampler2D samplerBackground;","uniform sampler2D samplerRipples;","uniform vec2 delta;","uniform float perturbance;","varying vec2 ripplesCoord;","varying vec2 backgroundCoord;","void main() {","float height = texture2D(samplerRipples, ripplesCoord).r;","float heightX = texture2D(samplerRipples, vec2(ripplesCoord.x + delta.x, ripplesCoord.y)).r;","float heightY = texture2D(samplerRipples, vec2(ripplesCoord.x, ripplesCoord.y + delta.y)).r;","vec3 dx = vec3(delta.x, heightX - height, 0.0);","vec3 dy = vec3(0.0, heightY - height, delta.y);","vec2 offset = -normalize(cross(dy, dx)).xz;","float specular = pow(max(0.0, dot(offset, normalize(vec2(-0.6, 1.0)))), 4.0);","gl_FragColor = texture2D(samplerBackground, backgroundCoord + offset * perturbance) + specular;","}"].join("\n")),h.uniform2fv(this.renderProgram.locations.delta,this.textureDelta)},initTexture:function(){this.backgroundTexture=h.createTexture(),h.bindTexture(h.TEXTURE_2D,this.backgroundTexture),h.pixelStorei(h.UNPACK_FLIP_Y_WEBGL,1),h.texParameteri(h.TEXTURE_2D,h.TEXTURE_MAG_FILTER,h.LINEAR),h.texParameteri(h.TEXTURE_2D,h.TEXTURE_MIN_FILTER,h.LINEAR)},setTransparentTexture:function(){h.bindTexture(h.TEXTURE_2D,this.backgroundTexture),h.texImage2D(h.TEXTURE_2D,0,h.RGBA,h.RGBA,h.UNSIGNED_BYTE,f)},hideCssBackground:function(){var e=this.$el[0].style.backgroundImage;"none"!=e&&(this.originalInlineCss=e,this.originalCssBackgroundImage=this.$el.css("backgroundImage"),this.$el.css("backgroundImage","none"))},restoreCssBackground:function(){this.$el.css("backgroundImage",this.originalInlineCss||"")},dropAtPointer:function(e,t,r){var i=parseInt(this.$el.css("border-left-width"))||0,o=parseInt(this.$el.css("border-top-width"))||0;this.drop(e.pageX-this.$el.offset().left-i,e.pageY-this.$el.offset().top-o,t,r)},drop:function(e,t,r,i){h=this.context;var o=this.$el.innerWidth(),n=this.$el.innerHeight(),s=Math.max(o,n);r/=s;var u=new Float32Array([(2*e-o)/s,(n-2*t)/s]);h.viewport(0,0,this.resolution,this.resolution),h.bindFramebuffer(h.FRAMEBUFFER,this.framebuffers[this.bufferWriteIndex]),a(this.textures[this.bufferReadIndex]),h.useProgram(this.dropProgram.id),h.uniform2fv(this.dropProgram.locations.center,u),h.uniform1f(this.dropProgram.locations.radius,r),h.uniform1f(this.dropProgram.locations.strength,i),this.drawQuad(),this.swapBufferIndices()},destroy:function(){this.$el.off(".ripples").removeClass("jquery-ripples").removeData("ripples"),this.$canvas.remove(),this.restoreCssBackground()},show:function(){this.visible=!0,this.$canvas.show(),this.hideCssBackground()},hide:function(){this.visible=!1,this.$canvas.hide(),this.restoreCssBackground()},pause:function(){this.running=!1},play:function(){this.running=!0},set:function(e,t){switch(e){case"dropRadius":case"perturbance":case"interactive":case"crossOrigin":this[e]=t;break;case"imageUrl":this.imageUrl=t,this.loadImage()}}};var g=e.fn.ripples;e.fn.ripples=function(t){if(!d)throw new Error("Your browser does not support WebGL, the OES_texture_float extension or rendering to floating point textures.");var r=arguments.length>1?Array.prototype.slice.call(arguments,1):void 0;return this.each(function(){var i=e(this),o=i.data("ripples"),n=e.extend({},l.DEFAULTS,i.data(),"object"==typeof t&&t);(o||"string"!=typeof t)&&(o?"string"==typeof t&&l.prototype[t].apply(o,r):i.data("ripples",o=new l(this,n)))})},e.fn.ripples.Constructor=l,e.fn.ripples.noConflict=function(){return e.fn.ripples=g,this}});



$(document).ready(function() {
    try {
        $('body').ripples({
            resolution: 512,
            dropRadius: 20, //px
            perturbance: 0.04,
        });
        
    }
    catch (e) {
        $('.error').show().text(e);
    }
    $('.js-ripples-disable').on('click', function() {
        $('body, main').ripples('destroy');
        $(this).hide();
    });
    $('.js-ripples-play').on('click', function() {
        $('body, main').ripples('play');
    });
    $('.js-ripples-pause').on('click', function() {
        $('body, main').ripples('pause');
    });
});
</script>
</body>
</html>
