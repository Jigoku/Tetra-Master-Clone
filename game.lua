local class = require("libs/middleclass/middleclass")
local stateful = require("libs/stateful/stateful")

require("libs/TLfres/TLfres")

Game = class("Game")
Game:include(stateful)

local EndGame = Game:addState("EndGame")

local function check_endgame()
  if #hands["red"].cards == 0 and #hands["blue"].cards == 0 then
    return true
  end

  return false
end

local function reset_window_size(z)
    TLfres.setScreen({w=320*z, h=240*z, full=false, vsync=true, aa=0, resizable=false}, 320, false, false)
    zoom = love.graphics.getWidth() / 320
end

local function count_score(side)
    local c = 0
    for i = 0, 3 do
      for j = 0, 3 do
        if card_grid[i + 1][j + 1] then
            if card_grid[i + 1][j + 1].side == side then
                c = c + 1
            end
        end
      end
    end

    return c
end

local function setup()
  current_turn = "blue"

  init_grid()

  hands = {
      ["red"] = Hand:new("red", true),
      ["blue"] = Hand:new("blue", false)
  }
end

function Game:initialize()
    love.graphics.setDefaultFilter("nearest", "nearest")
    init_graphics()
    cards = require("cards")

    self.ai_turn_counter = {
        cur_time = 0,
        tar_time = 1
    }

    setup()

    reset_window_size(4)
end

function Game:draw()
    TLfres.transform()
    love.graphics.draw(graphic_sheet, background_q, 0, 0)

    love.graphics.draw(graphic_sheet, grid_q, 48, 0)

    local grid_start_x = 73
    local grid_start_y = 9
    local grid_spacing_x = 42
    local grid_spacing_y = 52

    local selected_grid_x = -1
    local selected_grid_y = -1
    selected_grid_x, selected_grid_y = get_grid_cell(love.mouse.getX(), love.mouse.getY())

    for i = 0, 3 do
      for j = 0, 3 do
          love.graphics.setColor(1,1,1)

          local x = grid_start_x + i * grid_spacing_x
          local y = grid_start_y + j * grid_spacing_y

        if card_grid[i + 1][j + 1] then
          local c = card_grid[i + 1][j + 1]

          if c.side == "blue" then
             love.graphics.draw(graphic_sheet, card_back_blue_q, x, y)
          elseif c.side == "red" then
            love.graphics.draw(graphic_sheet, card_back_red_q, x, y)
          end

          -- If it has a card id then draw the card
          if c.card_id then
              c:draw(x, y)
          -- Otherwise draw the neutral cards
          elseif c.side == "neutral" then
            love.graphics.draw(graphic_sheet, block_card_q, x, y)
          elseif c.side == "neutral2" then
            love.graphics.draw(graphic_sheet, block_card2_q, x, y)
          end
        end
      end
    end

    -- Score
    love.graphics.draw(graphic_sheet, score_divider_q, 16, 185)

    -- Draw hand
    hands[current_turn]:draw(260, 8)

    love.graphics.draw(graphic_sheet, score_text_q["red"][count_score("red") + 1], 25, 170)
    love.graphics.draw(graphic_sheet, score_text_q["blue"][count_score("blue") + 1], 38, 203)

    self:draw_ui()

    TLfres.letterbox(4,3)
end

function Game:draw_ui()

end

function Game:update(dt)
    if hands[current_turn].ai_controlled then
        self.ai_turn_counter.cur_time = self.ai_turn_counter.cur_time + dt

        if self.ai_turn_counter.cur_time > self.ai_turn_counter.tar_time then
            self.ai_turn_counter.cur_time = 0

            if check_endgame() then
              setup()
              return
            end

            hands[current_turn]:ai_move()
            turn_end()
        end
    end

    if check_endgame() then
      self:gotoState("EndGame")
      self:load()
    end
end

function Game:mousepressed(x, y, button, istouch)
    if button ~= 1 or hands[current_turn].ai_controlled then
      return
    end

    x1, y1 = get_grid_cell(x, y)

    if x1 == -1 or y1 == -1 then
        hands[current_turn]:mousepressed(x, y, button)
        return
    end

    -- Check for existing card etc.
    if card_grid[x1][y1] == nil then
        if not hands[current_turn].selected_card then
            return
        end

        place_card(x1, y1, hands[current_turn].selected_card)
        hands[current_turn]:remove_selected_card()

        turn_end()
        return
    end
end

--

function EndGame:load()
  self.stay_counter = {
      cur_time = 0,
      tar_time = 3
  }
end

function EndGame:update(dt)
  self.stay_counter.cur_time = self.stay_counter.cur_time + dt

  if self.stay_counter.cur_time > self.stay_counter.tar_time then
    self:gotoState()
    setup()
  end
end

function EndGame:draw_ui()
  love.graphics.print("END GAME STATE", 0, 0)
end
