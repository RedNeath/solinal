CommandManager = {
    command_history = nil,
    command_history_limit = 0,
    is_history_empty = true
}

function CommandManager:new(command_history_limit)
    local cm = setmetatable({}, self)
    self.__index = self

    cm.command_history = {}
    cm.command_history_limit = command_history_limit or 0
    cm.is_history_empty = true

    return cm
end

function CommandManager:add_command_to_history(command)
    if #self.command_history >= self.command_history_limit then
        table.remove(self.command_history, 1)
    end

    table.insert(self.command_history, command)
    self.is_history_empty = false
end

function CommandManager:execute_command(command)
    command:execute()
    self:add_command_to_history(command)
end

function CommandManager:undo_last_command()
    if self.is_history_empty then
        return
    end

    local command_to_undo = table.remove(self.command_history, #self.command_history)
    command_to_undo:undo()
    self.is_history_empty = (#self.command_history == 0)
end

function CommandManager:get_last_command()
    if self.is_history_empty then
        return nil
    end

    return self.command_history[#self.command_history]
end
