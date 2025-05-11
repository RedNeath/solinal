DIRECTION_REGULAR = 1
DIRECTION_REVERSE = -1
BASE_COLOUR = "\027[0m"

Card = {
    id = nil,
    family = nil,
    value = nil,
    direction = 0,
    representation = nil,
    short_representation = nil
}

function Card:new(family, value, direction)
    local c = setmetatable({}, self)
    self.__index = self

    c.family = family
    c.value = value
    c.direction = direction or DIRECTION_REVERSE -- reversed by default

    c.id = c.family.name .. c.value
    c.representation = render_template(c.value, c.family.name, c.family.symbol, c.family.colour, c.direction)
    c.short_representation = render_short_template(c.value, c.family.name, c.family.symbol, c.family.colour, c.direction)

    return c
end

function Card:display()
    for _,v in pairs(self.representation) do
        print(v)
    end
end

function Card:display_short()
    for _,v in pairs(self.short_representation) do
        print(v)
    end
end

function Card:flip()
    self.direction = -self.direction

    self.representation = render_template(self.value, self.family.name, self.family.symbol, self.family.colour, self.direction)
    self.short_representation = render_short_template(self.value, self.family.name, self.family.symbol, self.family.colour, self.direction)
end

function Card:is_flipped()
    return (self.direction == DIRECTION_REVERSE)
end

function Card:continuous_value()
    return continuous_value(self.value)
end

local continuous_values = {
    A = 1,
    ["2"] = 2,
    ["3"] = 3,
    ["4"] = 4,
    ["5"] = 5,
    ["6"] = 6,
    ["7"] = 7,
    ["8"] = 8,
    ["9"] = 9,
    ["10"] = 10,
    J = 11,
    Q = 12,
    K = 13
}

local templates = {
    reverse = { "---------", "|   _   |", "|  /°\\  |", "| (  o) |", "|  \\_/  |", "|       |", "|       |", "---------" },
    A = { "+--%s-A--+", "|%CA      %c|", "|       |", "|%C   %s   %c|", "|       |", "|       |", "|%C      A%c|", "+-------+" },
    ["2"] = { "+--%s-2--+", "|%C2      %c|", "|%C   %s   %c|", "|       |", "|       |", "|%C   %s   %c|", "|%C      2%c|", "+-------+" },
    ["3"] = { "+--%s-3--+", "|%C3      %c|", "|%C   %s   %c|", "|%C   %s   %c|", "|       |", "|%C   %s   %c|", "|%C      3%c|", "+-------+" },
    ["4"] = { "+--%s-4--+", "|%C4      %c|", "|%C  %s %s  %c|", "|       |", "|       |", "|%C  %s %s  %c|", "|%C      4%c|", "+-------+" },
    ["5"] = { "+--%s-5--+", "|%C5      %c|", "|%C  %s %s  %c|", "|%C   %s   %c|", "|       |", "|%C  %s %s  %c|", "|%C      5%c|", "+-------+" },
    ["6"] = { "+--%s-6--+", "|%C6      %c|", "|%C  %s %s  %c|", "|%C  %s %s  %c|", "|       |", "|%C  %s %s  %c|", "|%C      6%c|", "+-------+" },
    ["7"] = { "+--%s-7--+", "|%C7      %c|", "|%C  %s %s  %c|", "|%C   %s   %c|", "|%C  %s %s  %c|", "|%C  %s %s  %c|", "|%C      7%c|", "+-------+" },
    ["8"] = { "+--%s-8--+", "|%C8      %c|", "|%C  %s %s  %c|", "|%C  %s %s  %c|", "|%C  %s %s  %c|", "|%C  %s %s  %c|", "|%C      8%c|", "+-------+" },
    ["9"] = { "+--%s-9--+", "|%C9 %s %s  %c|", "|%C  %s %s  %c|", "|%C   %s   %c|", "|       |", "|%C  %s %s  %c|", "|%C  %s %s 9%c|", "+-------+" },
    ["10"] = { "+--%s10--+", "|%C10%s %s  %c|", "|%C   %s   %c|", "|%C  %s %s  %c|", "|%C  %s %s  %c|", "|%C   %s   %c|", "|%C  %s %s10%c|", "+-------+" },
    J = { "+--%s-J--+", "|%CJ      %c|", "|%C  /|   %c|", "|%C  / \\  %c|", "|%C   %s   %c|", "|       |", "|%C      J%c|", "+-------+" },
    Q = { "+--%s-Q--+", "|%CQ      %c|", "|%C  / \\  %c|", "|%C ( %s ) %c|", "|%C  \\_/  %c|", "|       |", "|%C      Q%c|", "+-------+" },
    K = { "+--%s-K--+", "|%CK      %c|", "|%C  / \\  %c|", "|%C ( %s ) %c|", "|%C  \\_/  %c|", "|%C   |   %c|", "|%C      K%c|", "+-------+" }
}
local short_templates = {
    reverse = { "---------", "|   _   |" },
    A = { "+--%s-A--+", "|%CA%s     %c|" },
    ["2"] = { "+--%s-2--+", "|%C2%s     %c|" },
    ["3"] = { "+--%s-3--+", "|%C3%s     %c|" },
    ["4"] = { "+--%s-4--+", "|%C4%s     %c|" },
    ["5"] = { "+--%s-5--+", "|%C5%s     %c|" },
    ["6"] = { "+--%s-6--+", "|%C6%s     %c|" },
    ["7"] = { "+--%s-7--+", "|%C7%s     %c|" },
    ["8"] = { "+--%s-8--+", "|%C8%s     %c|" },
    ["9"] = { "+--%s-9--+", "|%C9 %s %s  %c|" },
    ["10"] = { "+--%s10--+", "|%C10%s %s  %c|" },
    J = { "+--%s-J--+", "|%CJ%s     %c|" },
    Q = { "+--%s-Q--+", "|%CQ%s     %c|" },
    K = { "+--%s-K--+", "|%CK%s     %c|" }
}

function continuous_value(value)
    return continuous_values[value]
end

function render_template(value, family_name, symbol, colour, direction)
    return render(templates, value, family_name, symbol, colour, direction)
end

function render_short_template(value, family_name, symbol, colour, direction)
    return render(short_templates, value, family_name, symbol, colour, direction)
end

function render(rendering_templates, value, family_name, symbol, colour, direction)
    if direction == DIRECTION_REVERSE then
        return rendering_templates.reverse
    end

    local rendered = {}
    for k,v in pairs(rendering_templates[value]) do
        local rendered_line

        if k == 1 then
            rendered_line = string.format(v, family_name)
        else
            rendered_line = v
            rendered_line = rendered_line:gsub("%%s", symbol)
            rendered_line = rendered_line:gsub("%%C", colour)
            rendered_line = rendered_line:gsub("%%c", BASE_COLOUR)
        end

        table.insert(rendered, rendered_line)
    end

    return rendered
end

