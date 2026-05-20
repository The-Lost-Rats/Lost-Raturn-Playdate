import "CoreLibs/graphics"

local gfx = playdate.graphics

function playdate.update()
  gfx.clear(gfx.kColorBlack)
  gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
  gfx.drawText("Hello, Marshall", 10, 10)
end
