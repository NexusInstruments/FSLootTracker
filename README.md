# Seurat

<img src="https://www.hilookonline.com/sites/default/files/styles/medium/public/images/artist/seurat.jpg?itok=tIGNDd8v" alt="Self-Portrait of Georges Seurat" style="float: left; display: inline-block;" width="80"/>
A Canvas and Point Drawing library for WildstarLUA using "Pixies".  Named after the 18th Century, French Impressionist artist [Georges Seurat](https://en.wikipedia.org/wiki/Georges_Seurat) who gained fame after his death for the unique art style he developed during his life called "[Pointillism](https://en.wikipedia.org/wiki/Pointillism)".

Seurat can be used to draw to pixels, line, circles, triangles, and rectangles to a "canvas" with interesting effect:
<img src="http://i.imgur.com/3nHd6cr.gif" alt="Seurat Test Pattern"/>

## Usage
### Including the Library
```lua
  local Seurat = Apollo.GetPackage("Seurat").tPackage

  -- CanvasID, CanvasWindow, PixelScale, QuietMode
  local canvas = Seurat:CreateCanvas("main", mainWnd, 3, false)
	canvas:SetBGColor("Blue")
```

## Challenges
* Wildstar does provide a methods which allow drawing directly to the windows or the screen.
* Wildstar sets a maximum timeout on event handlers of 2507ms (2.5s).  When the code of an event handler takes longer than this, Wildstar halts further execution of the handler and presents an error message to the user. This creates a problem if the library attempts to do too much at once.
* Because of how Wildstar LUA added each pixie to the screen, each additional pixie require more processing overhead as the Window XML-DOM grows in size.  This creates problems with large grids of pixels because if every pixel is drawn it takes longer and longer to add the additional pixels to the screen which exacerbates the first issue.

## Solutions
To overcome these challenges a number of inventive solutions had to be used.
* So that we can draw directly to the screen with "pixels", Pixies are used.
* Instead of adding Pixies directly to the canvas, Seurat maintains a "draw buffer" which it optimizes into horizontal or vertical lines (picking the method which results in the fewest draw calls) and then renders into Pixie data for the redraw timer. Seurat also allows for a pixel scale factor to be used to shrink the number of needed data to a maintainable level for the "pixels".  This is especially important
* The optimization method attempts to discard unnecessary pixels which match the background color of the canvas.
* To prevent event timeouts, Seraut utilizes a redraw timer which batches adding pixies to the canvas from the rendered pixie data.

## Recommendations
* Use a pixel scale of 2 or higher for large canvas areas.
* Try to limit the number of pixels needed to under 100k, Wildstar will start to get VERY sluggish beyond this limit. You can easily calculate how many pixels are needed using the following formula:
```
  pixelCount = (canvasWidth * canvasHeight) / (scale ^ 2)
```
* The default redraw time and batching values should be sufficient for most situations. However ```Canvas:AdjustBatchSize(integer)``` and ```Canvas:AdjustRedrawTimer(float)``` are available to tweak. Remember that some computers are slower, err on the side of caution.


Licensed under MIT License

Copyright (c) 2015 NexusInstruments
