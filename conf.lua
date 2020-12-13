function love.conf(w)
	local W=w.window
	W.title="loveChat V0.1"
	W.width,W.height=800,600
	W.minwidth,W.minheight=800,600
	W.borderless=false
	W.resizable=false
	W.fullscreen=false
	W.vsync=0--0:∞fps
	W.msaa=false--num of samples to use with multi-sampled antialiasing
	W.depth=0--bits/samp of depth buffer
	W.stencil=1--bits/samp of stencil buffer
	W.display=1--Monitor ID
	W.highdpi=false--High-dpi mode for the window on a Retina display
	W.x,W.y=nil

	local M=w.modules
	M.timer,M.graphics,M.font=1,1,1
	M.mouse,M.keyboard=1,1
	M.window,M.system,M.event=1,1,1
	M.image,M.touch,M.joystick=nil
	M.audio,M.sound=nil
	M.math,M.data=nil
	M.physics,M.thread,M.video=nil
end