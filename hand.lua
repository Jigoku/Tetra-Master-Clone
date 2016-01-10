local class = require("libs/middleclass/middleclass")

Hand = class("Hand")

function Hand:initialize(side)
    self.cards = {}
    self.side = side

    local i = 0
    while #self.cards < 5 do
        -- local base_card = cards[math.random(1, #cards - 1)]
        local base_card = BASE_CARDS[math.random(54, 55)]

        if base_card ~= nil and base_card.id ~= nil then
            if i == 0 then
                print(self.side..": "..base_card.id)
            end

            local c = Card:new(base_card, self.side)

            if c then
                table.insert(self.cards, c)
                i = i + 1
            end
        end
    end
end

function Hand:draw(x, y)
    local card_height = 51
    local s = 1

    if #self.cards == 5 then
        s = (41 / card_height)
        card_height = 41
    end

    for i, v in ipairs(self.cards) do
        local y = y + ((i - 1) * card_height)

        if self.side == "blue" then
           love.graphics.draw(graphic_sheet, card_back_blue_q, x, y, 0, s, s)
       elseif self.side == "red" then
          love.graphics.draw(graphic_sheet, card_back_red_q, x, y, 0, s, s)
        end

        love.graphics.draw(graphic_sheet, cards_q[v.card_id], x, y, 0, s, s)
    end
end
