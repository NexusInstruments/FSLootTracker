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
	}
	buffer = {
		data = {},
		width = 0,
		height = 0
	}
	timer = {
		id = "",
		counter = 0,
		batchSize = 400,
		refresh = 0.01
	}
	activePixies = {},
}

------------------------------------------------------------------------------------------------
--  Seurat Functionality
------------------------------------------------------------------------------------------------
function Seurat:CreateCanvas(canvasId, canvasWnd, scale, quiet)
	local c = Canvas:new()
	c:Init(canvasId, wnd, scale, quietMode)
	return c
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
  self.state = deepcopy(tDefaultState)
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
	self.state.timer.id = "Seraut_Canvas_" .. self.state.canvas.id
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
	x = Canvas:TestXCoord(x)
	y = Canvas:TestYCoord(y)
	local loc = y * self.state.buffer.width + x
	self.state.buffer.data[loc + 1] = color
end

function Canvas:PlotHLine(x1,x2,y,color)
	x1 = Canvas:TestXCoord(x1)
	x2 = Canvas:TestXCoord(x2)
	y = Canvas:TestYCoord(y)
	for i=x1,x2 do
		local loc =  y * self.state.buffer.width + i
			self.state.buffer.data[loc + 1] = color
		end
	end
end

function Canvas:PlotVLine(x,y1,y2,color)
	x = Canvas:TestXCoord(x)
	y1 = Canvas:TestXCoord(y1)
	y2 = Canvas:TestYCoord(y2)
	for i=y1,y2 do
		local loc = i * self.state.buffer.width + x
			self.state.buffer.data[loc + 1] = color
		end
	end
end

function Canvas:GetHPixieCount()
	local count
	for y=0,self.state.buffer.height do
		local lastColor = ""
		for x=0,self.state.buffer.width do
			local loc = y * self.state.buffer.width + x
			local color = self.state.buffer.data[loc + 1]
			if lastColor ~= color then
				count = count + 1
			end
		end
	end
	return count
end

function Canvas:GetVPixieCount()
	local count
	for x=0,self.state.buffer.width do
		local lastColor = ""
		for y=0,self.state.buffer.height do
			local loc = y * self.state.buffer.width + x
			local color = self.state.buffer.data[loc + 1]
			if lastColor ~= color then
				count = count + 1
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
			strSprite = "WhiteFill",
			cr = lastColor
			loc = {
				fPoints = topleft,
				nOffsets = {x1, y1, x2, y2}
			}
		}
	}
	table.insert(self.state.activePixies, t)
end

function Canvas:RenderH()
	local active = true
	for y=0,self.state.buffer.height do
		local lastColor = ""
		local currentPixieX = nil
		for x=0,self.state.buffer.width do
			local loc = y * self.state.buffer.width + x
			local color = self.state.buffer.data[loc + 1]
			if lastColor ~= color then
				-- End previous pixie and insert, start next pixie
				if currentPixieX then
					-- Compare lastColor with background color -- if the same mark active false
					-- End previous
					self.AddPixie(currentPixieX * self.state.canvas.scale, y * self.state.canvas.scale, x * self.state.canvas.scale, (y+1) * self.state.canvas.scale, lastColor, active)
				end
				currentPixieX = x
			end
		end
		-- end last pixie and insert
		self.AddPixie(currentPixieX * self.state.canvas.scale, y * self.state.canvas.scale, self.state.buffer.width * self.state.canvas.scale, (y+1) * self.state.canvas.scale, lastColor, active)
	end
end

function Canvas:RenderV()
	local active = true
	for x=0,self.state.buffer.width do
		local lastColor = ""
		local currentPixieY = nil
		for y=0,self.state.buffer.height do
			local loc = y * self.state.buffer.width + x
			local color = self.state.buffer.data[loc + 1]
			if lastColor ~= color then
				-- End previous pixie and insert, start next pixie
				if currentPixieY then
					-- Compare lastColor with background color -- if the same mark active false
					-- End previous
					self.AddPixie(x * self.state.canvas.scale, currentPixieY * self.state.canvas.scale, (x+1) * self.state.canvas.scale, y * self.state.canvas.scale, lastColor, active)
				end
				currentPixieY = y
			end
		end
		-- end last pixie and insert
		self.AddPixie(x * self.state.canvas.scale, currentPixieY * self.state.canvas.scale), (x+1) * self.state.canvas.scale, self.state.canvas.height * self.state.canvas.scale), lastColor, active)
	end
end


function Canvas:Redraw()
	self.state.canvas.wnd:DestroyAllPixies()
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
end

function Canvas:TestXCoord(x)
	if x > self.state.buffer.width then
		x = self.state.buffer.width
	else if x < 0 then
		x = 0
	end
end

function Canvas:TestYCoord(y)
	if y > self.state.buffer.height then
		y = self.state.buffer.height
	else if y < 0 then
		y = 0
	end
end

function Canvas:SetBatchSize(size)
	self.state.timer.batchSize = size
end

function Canvas:SetRedrawRefreshTimer(time)
	self.state.timer.refresh = time
end

Apollo.RegisterPackage(Seurat, PkgMajor, PkgMinor, {"SimpleUtils"})
