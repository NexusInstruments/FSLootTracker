------------------------------------------------------------------------------------------------
--	Seurat ver. @project-version@
--	by Chrono Syz--Entity-US
--	Build @project-hash@
--	Copyright (c) Chronosis. All rights reserved
--
--	https://github.com/NexusInstruments/Seurat
------------------------------------------------------------------------------------------------
--  Seurat.lua
--	Seurat - WildstarLUA Pixie Canvas and Drawing Library
------------------------------------------------------------------------------------------------
require "Apollo"

local PackageName, Major, Minor, Patch = "Seurat", 1, 0, 0
local PkgMajor, PkgMinor = PackageName, tonumber(string.format("%02d%02d%02d", Major, Minor, Patch))
local Pkg = Apollo.GetPackage(PkgMajor)
if Pkg and (Pkg.nVersion or 0) >= PkgMinor then
  return -- no upgrade needed
end

-- Set a reference to the actual package or create an empty table
local Seurat = Pkg and Pkg.tPackage or {}
local Canvas = {}

local tCanvasDefaultState = {
	quietMode = false,
	canvas = {
		id = "",
		wnd = nil,
		bgColor = "00000000",
		scale = 1,
		width = 0,
		height = 0
	},
	buffer = {
		data = {},
		width = 0,
		height = 0
	},
	timer = {
		id = "",
		counter = 0,
		batchSize = 400,
		refresh = 0.01
	},
	activePixies = {},
}

------------------------------------------------------------------------------------------------
--  Seurat Functionality
------------------------------------------------------------------------------------------------
function Seurat:CreateCanvas(canvasId, canvasWnd, scale, quiet)
	local c = Canvas:new()
	c:Init(canvasId, canvasWnd, scale, quietMode)
	if not self.canvases then
		self.canvases = {}
	end
	self.canvases[canvasId] = c
	return c
end

function Seurat:GetCanvas(canvasId)
	return self.canvases[canvasId]
end

function Seurat:DestroyCanvas(canvasId)
	if self.canvases[canvasId] then
		self.canvases[canvasId]:Destroy()
		self.canvases[canvasId] = nil
	end
end

------------------------------------------------------------------------------------------------
--  Canvas Functionality
------------------------------------------------------------------------------------------------
-- Copy Constructor
function Canvas:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  return o
end

-- Initialize
function Canvas:Init(canvasId, canvasWnd, scale, quietMode)
  -- Volatile values are stored here. These are impermenant and not saved between sessions
  self.state = deepcopy(tCanvasDefaultState)
	if not canvasId then
		Print("Seurat ERROR: Seurat Canvas MUST be initialized with a Canvas ID")
		return
	end
	if not canvasWnd then
		Print("Seurat ERROR: Seurat Canvas MUST be initialized with a Canvas Window")
		return
	end
	-- Adjust for optional parameters
	if scale then
		-- don't allow for 0 or negative scales
		if scale < 1 then
			scale = 1
		end
		self.state.canvas.scale = scale
	end
	if quietMode then
		self.state.quietMode = quietMode
	end
	self.state.canvas.id = canvasId
	self.state.canvas.wnd = canvasWnd
	self.state.canvas.width = self.state.canvas.wnd:GetWidth()
	self.state.canvas.height = self.state.canvas.wnd:GetHeight()
	self.state.buffer.width = math.ceil(self.state.canvas.width / self.state.canvas.scale)
	self.state.buffer.height = math.ceil(self.state.canvas.height / self.state.canvas.scale)

	if self.state.canvas.scale == 1 then
		if not self.state.quietMode then
			Print("Seurat WARNING: Seurat Canvas has been initialized with a Canvas Scale of 1.")
			Print("Seurat WARNING: For large canvases, this can cause very poor performance and is not recommended.")
		end
	end

	-- Initialize the buffer
	self:ClearBuffer()
	self.state.timer.id = "Seurat_Canvas_" .. self.state.canvas.id
	-- Setup Redraw Timer
	Apollo.RegisterTimerHandler(self.state.timer.id, "RedrawTimer", self)
end

function Canvas:Clear()
	self.state.canvas.wnd:DestroyAllPixies()
	self.state.activePixies = {}
	self:ClearBuffer()
	-- No need to redraw
end

function Canvas:ClearBuffer()
	self.state.buffer.data = {}
	for y=0,self.state.buffer.height do
		for x=0,self.state.buffer.width do
			table.insert(self.state.buffer.data, -1)
		end
	end
end

function Canvas:SetBGColor()

end

function Canvas:PlotPoint(x,y,color)
  if self:CheckClipping(x,y) then
    local loc = y * self.state.buffer.width + x
  	self.state.buffer.data[loc + 1] = color
  end
end

function Canvas:PlotHLine(x1,x2,y,color)
	x1,x2 = math.minswap(x1,x2)
	x1 = self:BoundXToBuffer(x1)
	x2 = self:BoundXToBuffer(x2)
	if self:CheckClipping(x1,y) then
    for i=x1,x2 do
      local loc =  y * self.state.buffer.width + i
      self.state.buffer.data[loc + 1] = color
    end
  end
end

function Canvas:PlotVLine(x,y1,y2,color)
	y1,y2 = math.minswap(y1,y2)
	y1 = self:BoundYToBuffer(y1)
	y2 = self:BoundYToBuffer(y2)
	if self:CheckClipping(x,y1) then
    for i=y1,y2 do
      local loc = i * self.state.buffer.width + x
      self.state.buffer.data[loc + 1] = color
    end
  end
end

function Canvas:PlotLine(x1,y1,x2,y2,color)
	local y = y1
	local dx = x2-x1
	local dy = y2-y1
	local m = dy / dx
	for c=x1,x2 do
		self:PlotPoint(c,math.round(y),color)
		y = y + m
	end
end

function Canvas:PlotRectFilled(x1,y1,x2,y2,color)
	y1,y2 = math.minswap(y1,y2)
	for c=y1,y2 do
		self:PlotHLine(x1, x2, c, color)
	end
end

function Canvas:PlotRect(x1,y1,x2,y2,color)
	self:PlotHLine(x1, x2, y1, color)
	self:PlotHLine(x1, x2, y2, color)
	self:PlotVLine(x1, y1, y2, color)
	self:PlotVLine(x2, y1, y2, color)
end

function Canvas:PlotCircleFilled(xc,yc,r,color)
	local xn, yn, rs, ys
	local xb, xe, yb, ye

	rs = r ^ 2
	for yn=r,0,-1 do
		yb = -yn + yc
		ye = yn + yc
		ys = yn ^ 2
		xn = math.round(math.sqrt(rs - ys))
		xb = -xn + xc
		xe = xn + xc
		self:PlotHLine(xb, xe, yb, color)
    self:PlotHLine(xb, xe, ye, color)
	end
	self:PlotHLine(-r+xc, r+xc, yc, color)
end

function Canvas:PlotCircle(xc,yc,r,color)
	local xn, yn, rs, ys
	local xb, xe, yb, ye
	local lastx = 0

	rs = r ^ 2
	for yn=r,0,-1 do
		yb = -yn + yc
		ye = yn + yc
		ys = yn ^ 2
		xn = math.round(math.sqrt(rs - ys))
		if lastx > xn then
			lastx = xn
		end
		for c=lastx,xn do
			self:PlotPoint(c + xc, yb, color)
			self:PlotPoint(-c + xc, yb, color)
      self:PlotPoint(c + xc, ye, color)
			self:PlotPoint(-c + xc, ye, color)
		end
		lastx = xn + 1
	end
	self:PlotPoint(-r + xc, yc, color)
	self:PlotPoint(r + xc, yc, color)
end

function Canvas:PlotCircleWedge(xc,yc,r,color,start,finish)
	local xn, yn, rs, ys
	local xb, xe, yb, ye

  start,finish = math.minswap(start,finish)
	rs = r ^ 2
	for yn=r,0,-1 do
		yb = -yn + yc
		ye = yn + yc
		ys = yn ^ 2
		xn = math.round(math.sqrt(rs - ys))
		xb = -xn + xc
		xe = xn + xc
    for x=-xn,xn do
      c1 = math.atan2(x,-yn) + math.pi
      c2 = math.atan2(x,yn) + math.pi
      if c1 >= start and c1 <= finish then
        self:PlotPoint(x + xc, yb, color)
      end
      if c2 >= start and c2 <= finish then
        self:PlotPoint(x + xc, ye, color)
      end
    end
	end
end

function Canvas:PlotCircleArc(xc,yc,r,color,start,finish)
	local xn, yn, rs, ys
	local xb, xe, yb, ye
	local lastx = 0

  start,finish = math.minswap(start,finish)
	rs = r ^ 2
	for yn=r,0,-1 do
		yb = -yn + yc
		ye = yn + yc
		ys = yn ^ 2
		xn = math.round(math.sqrt(rs - ys))
		if lastx > xn then
			lastx = xn
		end
		for c=lastx,xn do
      c1 = math.atan2(c,-yn) + math.pi
      c2 = math.atan2(-c,-yn) + math.pi
      c3 = math.atan2(c,yn) + math.pi
      c4 = math.atan2(-c,yn) + math.pi
      if c1 >= start and c1 <= finish then
        self:PlotPoint(c + xc, yb, color)
      end
      if c2 >= start and c2 <= finish then
        self:PlotPoint(-c + xc, yb, color)
      end
      if c3 >= start and c3 <= finish then
        self:PlotPoint(c + xc, ye, color)
      end
      if c4 >= start and c4 <= finish then
        self:PlotPoint(-c + xc, ye, color)
      end
		end
		lastx = xn + 1
	end
  c1 = math.atan2(-r,0) + math.pi
  c2 = math.atan2(r,0) + math.pi
  if c1 >= start and c1 <= finish then
    self:PlotPoint(-r + xc, yc, color)
  end
  if c2 >= start and c2 <= finish then
    self:PlotPoint(r + xc, yc, color)
  end
end

function Canvas:PlotTriFilled(x1,y1,x2,y2,x3,y3,color)
	local m1, m2, m3, dx, dy
	local xb, xe
	x1,y1,x2,y2 = math.pointswap(x1,y1,x2,y2)
	x1,y1,x3,y3 = math.pointswap(x1,y1,x3,y3)
	x2,y2,x3,y3 = math.pointswap(x2,y2,x3,y3)

	dy = y2 - y1
	dx = x2 - x1
	if dy == 0 then
		m1 = 0
	else
		m1 = dy / dx
	end

	dy = y3 - y1
	dx = x3 - x1
	if dy == 0 then
		m2 = 0
	else
		m2 = dy / dx
	end

	dy = y3 - y2
	dx = x3 - x2
	if dy == 0 then
		m3 = 0
	else
		m3 = dy / dx
	end

	xb = x1
	xe = x1
	for y=y1,y2 do
		self:PlotHLine(xb, xe, y, color)
		xb = xb + m1
		xe = xe + m2
	end
	for y=y2,y3 do
		self:PlotHLine(xb, xe, y, color)
		xb = xb + m3
		xe = xe + m2
	end
end

function Canvas:PlotTri(x1,y1,x2,y2,x3,y3,color)
	self:PlotLine(x1,y1,x2,y2,color)
	self:PlotLine(x1,y1,x3,y3,color)
	self:PlotLine(x2,y2,x3,y3,color)
end

--------------------------------------------------------------------------------
--- Rendering Methods
--------------------------------------------------------------------------------
function Canvas:GetHPixieCount()
	local count = 0
	for y=0,self.state.buffer.height do
		local lastColor = -1
		for x=0,self.state.buffer.width do
			local loc = y * self.state.buffer.width + x
			local color = self.state.buffer.data[loc + 1]
			if lastColor ~= color then
				count = count + 1
				lastColor = color
			end
		end
	end
	return count
end

function Canvas:GetVPixieCount()
	local count = 0
	for x=0,self.state.buffer.width do
		local lastColor = -1
		for y=0,self.state.buffer.height do
			local loc = y * self.state.buffer.width + x
			local color = self.state.buffer.data[loc + 1]
			if lastColor ~= color then
				count = count + 1
				lastColor = color
			end
		end
	end
	return count
end

function Canvas:Render()
	-- Determine if H or V lines will be best optimized -- if tied use H lines.
	local vcount = self:GetVPixieCount()
	local hcount = self:GetHPixieCount()
	if vcount < hcount then
		self:RenderV()
	else
		self:RenderH()
	end
end

function Canvas:AddPixie(x1,y1,x2,y2,color,active)
	local topleft = {0,0,0,0}
	local t = {
		active = active,
		pixie = {
      bLine = false,
			strSprite = "WhiteFill",
			cr = color,
		  loc = {
				fPoints = topleft,
				nOffsets = {x1, y1, x2, y2}
			},
      flagsText = {
  			DT_VCENTER = true
  		},
  		fRotation = 0
		}
	}
	table.insert(self.state.activePixies, t)
end

function Canvas:RenderH()
	local active = true
	for y=0,self.state.buffer.height do
		local lastColor = -1
		local currentPixieX = nil
		for x=0,self.state.buffer.width do
			local loc = y * self.state.buffer.width + x
			local color = self.state.buffer.data[loc + 1]
			if lastColor ~= color then
				-- End previous pixie and insert, start next pixie
				if currentPixieX then
					-- Compare lastColor with background color -- if the same mark active false
					-- End previous
          if lastColor ~= -1 then
						self:AddPixie(currentPixieX * self.state.canvas.scale, y * self.state.canvas.scale, x * self.state.canvas.scale, (y+1) * self.state.canvas.scale, lastColor, active)
					end
				end
				lastColor = color
				currentPixieX = x
			end
		end
		-- end last pixie and insert
    if lastColor ~= -1 then
			self:AddPixie(currentPixieX * self.state.canvas.scale, y * self.state.canvas.scale, self.state.buffer.width * self.state.canvas.scale, (y+1) * self.state.canvas.scale, lastColor, active)
		end
	end
end

function Canvas:RenderV()
	local active = true
	for x=0,self.state.buffer.width do
		local lastColor = -1
		local currentPixieY = nil
		for y=0,self.state.buffer.height do
			local loc = y * self.state.buffer.width + x
			local color = self.state.buffer.data[loc + 1]
			if lastColor ~= color then
				-- End previous pixie and insert, start next pixie
				if currentPixieY then
					-- Compare lastColor with background color -- if the same mark active false
					-- End previous
          if lastColor ~= -1 then
						self:AddPixie(x * self.state.canvas.scale, currentPixieY * self.state.canvas.scale, (x+1) * self.state.canvas.scale, y * self.state.canvas.scale, lastColor, active)
					end
				end
				lastColor = color
				currentPixieY = y
			end
		end
		-- end last pixie and insert
    if lastColor ~= -1 then
			self:AddPixie(x * self.state.canvas.scale, currentPixieY * self.state.canvas.scale, (x+1) * self.state.canvas.scale, self.state.canvas.height * self.state.canvas.scale, lastColor, active)
		end
	end
end


function Canvas:Redraw()
	self.state.canvas.wnd:DestroyAllPixies()
	self.state.timer.counter = 1
	-- Do analysis and render to active Pixies
	self:Render()

	-- Start Canvas Redraw
	Apollo.CreateTimer(self.state.timer.id, 0.001, false)
	Apollo.StartTimer(self.state.timer.id)
end

function Canvas:RedrawTimer()
	-- if not at the end then do this
  local totalPoints = #self.state.activePixies
  if self.state.timer.counter < totalPoints then
    local max = self.state.timer.counter + self.state.timer.batchSize
    if max > totalPoints then
      max = totalPoints
    end
    for i=self.state.timer.counter, max do
      local t = self.state.activePixies[i]
      if t.active then
        pix = self.state.canvas.wnd:AddPixie(t.pixie)
        --table.insert(self.state.windows.plotter, pix)
      end
    end
    self.state.timer.counter = max + 1
    Apollo.CreateTimer(self.state.timer.id, self.state.timer.refresh, false)
    Apollo.StartTimer(self.state.timer.id)
	end
end

function Canvas:CheckClipping(x,y)
  if x > self.state.buffer.width or x < 0 then
		return false
	elseif y > self.state.buffer.height or y < 0 then
		return false
	end
	return true
end

function Canvas:TestXCoord(x)
	if x > self.state.buffer.width then
		x = self.state.buffer.width
	elseif x < 0 then
		x = 0
	end
	return x
end

function Canvas:TestYCoord(y)
	if y > self.state.buffer.height then
		y = self.state.buffer.height
	elseif y < 0 then
		y = 0
	end
	return y
end

function Canvas:BoundXToBuffer(x)
	if x > self.state.buffer.width then
		x = self.state.buffer.width
	elseif x < 0 then
		x = 0
	end
	return x
end

function Canvas:BoundYToBuffer(y)
	if y > self.state.buffer.height then
		y = self.state.buffer.height
	elseif y < 0 then
		y = 0
	end
	return y
end

function Canvas:SetBatchSize(size)
	self.state.timer.batchSize = size
end

function Canvas:SetRedrawRefreshTimer(time)
	self.state.timer.refresh = time
end

function Canvas:Destroy()
	self.state.canvas.wnd:DestroyAllPixies()
	self.state.activePixies = {}
	self.state.buffer.data = {}
	self = nil
end

------------------------------------------------------------------------------------------------
--- Math Utilites
------------------------------------------------------------------------------------------------
function math.minswap(a,b)
	if (a >= b) then
		return b,a
	else
		return a,b
	end
end

function math.maxswap(a,b)
	if (a >= b) then
		return a,b
	else
		return b,a
	end
end

function math.pointswap(x1,y1,x2,y2)
	if y1 > y2 then
		return x2,y2,x1,y1
	end
	return x1,y1,x2,y2
end

function math.round(f)
	local g = math.floor(f)
	local r = f - g
	if r >= 0.5 then
		return math.ceil(f)
	else
		return math.floor(f)
	end
end

Apollo.RegisterPackage(Seurat, PkgMajor, PkgMinor, {"SimpleUtils"})
