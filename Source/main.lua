import "CoreLibs/graphics"
import "CoreLibs/object"

-- Local aliases
-- TODO: when and why do we use local
local gfx <const> = playdate.graphics

-- Game states
-- TODO: do a i need a super class? how can i make it abstract?
-- TODO: should i move these to new files?
-- TODO: should this have like class name or something as an arg?
class ('GameState').extends()

function GameState:init()
end

class('Title').extends(GameState)

function Title:init()
  Title.super.init(self)
end

function Title:enter()
end

function Title:update()
  -- TODO: why do we need this in update? Why did it not work in enter or leave?
  gfx.clear()

  -- TODO: here is maybe where i could legit use the state transition?
  if (playdate.buttonJustPressed(playdate.kButtonA)) then
    setState(GamePlay)
  end

  -- TODO: How to draw at middle of screen
  -- TODO: why can't i do self.className?
  gfx.drawText('Title', 10, 10)
end

function Title:leave()
end

class ('GamePlay').extends(GameState)

function GamePlay:init()
  GamePlay.super.init(self)
end

function GamePlay:enter()
end

function GamePlay:update()
  gfx.clear()

  if (playdate.buttonJustPressed(playdate.kButtonA)) then
    setState(GameOver)
  end

  -- TODO: How to draw at middle of screen
  gfx.drawText('GamePlay', 10, 10)
end

function GamePlay:leave()
end

class('GameOver').extends(GameState)

function GameOver:init()
  GameOver.super.init(self)
end

function GameOver:enter()
end

function GameOver:update()
  gfx.clear()

  if (playdate.buttonJustPressed(playdate.kButtonA)) then
    setState(Title)
  end

  -- TODO: How to draw at middle of screen
  gfx.drawText('GameOver', 10, 10)
end

function GameOver:leave()
end


local STATE_TITLE = Title()
local STATE_GAME_PLAY = GamePlay()
local STATE_GAME_OVER = GameOver()


local current_game_state = STATE_TITLE


local game_states = {
  Title = { enter = STATE_TITLE.enter, update = STATE_TITLE.update, leave = STATE_TITLE.leave },
  GamePlay = { enter = STATE_GAME_PLAY.enter, update = STATE_GAME_PLAY.update, leave = STATE_GAME_PLAY.leave },
  GameOver = { enter = STATE_GAME_OVER.enter, update = STATE_GAME_OVER.update, leave = STATE_GAME_OVER.leave }
}

-- TODO: Can we get strict typing in lua?
-- TODO: should this be obj or string?
function setState(to_state)
  -- Leave current state (clean up etc.)
  game_states[current_game_state.className].leave()

  -- TODO: validate to_state
  -- TODO: handle nils
  -- Switch state and call enter
  current_game_state = to_state
  game_states[current_game_state.className].enter()
end

function playdate.update()
  game_states[current_game_state.className].update()
end



-- TODO: would an actual state machine be better?
-- Game state machine
-- function FiniteStateMachine(state_transitions)
--   local transition_table = {}
  
--   for _, transition in ipairs(state_transitions) do
--     local old_state, trigger, new_state, entry_action = transition[1], transition[2], transition[3], transition[4]
--     if transition_table[old_state] == nil then transition_table[old_state] = {} end
--     transition_table[old_state][trigger] = { new_state = new_state, entry_action = entry_action }
--   end

--   return transition_table
-- end

-- local game_transition_table = FiniteStateMachine{
--   { STATE_TITLE, }
-- }

