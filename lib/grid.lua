---
-- grid.lua


local Grid = {}

Grid.__index = Grid

local function new(size_x, size_y, def_value)
    if not size_x or type(size_x) ~= "number" or size_x < 1 or not size_y or type(size_y) ~= "number" or size_y < 1 then
        error("Grid.new: size_x and size_y must be a number values equal or greater than 1")
    end

    local g = {}

    for y = 1, size_y   do
        for x = 1, size_x do
            g[(x - 1) * size_x + y] = def_value
        end
    end

    return setmetatable(
        {
            size_x = size_x,
            size_y = size_y,
            default_value = def_value or nil,
            _grid = g
        },
        Grid
    )
end

function Grid:get_size()
    return self.size_x, self.size_y
end

function Grid:get_default_value()
    return self.default_value
end

function Grid:iterate()
    local x, y = 0, 1

    return function ()
        if x < self.size_x then
            x = x + 1
        else
            if y < self.size_y  then
                y = y + 1
                x = 1
            else
                return nil
            end
        end

        return x, y, self:get_cell(x, y)
    end
end

function Grid:iterate_neighbor(x, y)
    if not self:is_valid(x, y) then
        error("Grid.iterate_neighbor: try to iterate around invalid cell index [ " .. tostring(x) .. " : " .. tostring(y) .. "]")
    end

    local iterate_table = {}

    for _, val in pairs(Grid.direction) do
        if self:is_valid(x + val[1], y + val[2]) then
            table.insert(iterate_table, {
                cur_x = x + val[1],
                cur_y = y + val[2],
                dx = val[1],
                dy = val[2]
            })
        end
    end

    local index = 0

    return function ()
        if index < #iterate_table then
            index = index + 1
        else
            return nil
        end

        return iterate_table[index].dx, iterate_table[index].dy, self:get_cell(iterate_table[index].cur_x, iterate_table[index].cur_y)
    end
end

--[[
-- This checks to see if a given x,y pair are within
-- the boundries of the grid.
--]]
function Grid:is_valid(x, y)
    if x == nil or type(x) ~= "number" or y == nil or type(y) ~= "number" then
        return false
    end

    return  0 < x and x <= self.size_x and 0 < y and y <= self.size_y
end

--[[ Gets the data in a given x,y cell. ]]
function Grid:get_cell(x, y)
    if self:is_valid(x, y) then
        return self._grid[(x - 1) * self.size_x + y]
    else
        error("Grid.get_cell: try to get cell by invalid index [ " .. tostring(x) .. " : " .. tostring(y) .. "]")
    end
end

--[[
-- This method will return a set of cell data in a table.
-- The 'cells' argument should be a table of x,y pairs of
-- the cells being requested.
--]]
function Grid:get_cells(cells)
    local data = {}

    if type(cells) ~= "table" then
        error("Grid.get_cells: invalid cells data - must be a table value, but actual is " .. type(cells))
    end

    for _, v in ipairs(cells) do
        local x, y = table.unpack(v)

        if self:is_valid(x, y) then
            table.insert(data, self:get_cell(x, y))
        else
            error("Grid.get_cells: try to get cell by invalid index [ " .. tostring(x) .. " : " .. tostring(y) .. "]")
        end
    end

    return data
end

--[[ Sets a given x,y cell to the data object. ]]
function Grid:set_cell(x, y, obj)
    if self:is_valid(x, y) then
        self._grid[(x - 1) * self.size_x + y] = obj
    else
        error("Grid.set_cell: try to set cell by invalid index [ " .. tostring(x) .. " : " .. tostring(y) .. "]")
    end
end

--[[ Resets a given x,y cell to the grid default value. ]]
function Grid:reset_cell(x, y)
    if self:is_valid(x, y) then
        self:set_cell(x, y, self.default_value)
    else
        error("Grid.reset_cell: try to reset cell by invalid index [ " .. tostring(x) .. " : " .. tostring(y) .. "]")
    end
end

--[[ Resets the entire grid to the default value. ]]
function Grid:reset_all()
    for x, y, _ in self:iterate() do
        self:set_cell(x, y, self.default_value)
    end
end

--[[
-- This method is used to populate multiple cells at once.
-- The 'data' argument must be a table, with each element
-- consisting of three values: x, y, and the data to set
-- the cell too. IE:
--   d = {{4, 4, "X"}, {4, 5, "O"}, {5, 4, "O"}, {5, 5, "X"}}
--   G:populate(d)
-- If the object to be populated is nil, it is replaced with
-- the default value.
--]]
function Grid:populate(data)
    if type(data) ~= "table" then
        error("Grid.populate: invalid input data - must be a table value, but actual " .. type(data))
    end

    for _, v in ipairs(data) do
        local x, y, obj = table.unpack(v)

        if self:is_valid(x, y) then
            if obj == nil then
                obj = self.default_value
            end

            self:set_cell(x, y, obj)
        end
    end
end

--[[
-- This method returns the entire grid's contents in a
-- flat table suitable for feeding to populate() above.
-- Useful for recreating a grid layout.
-- If the 'no_default' argument is non-nil, then the
-- returned data table only contains elements who's
-- cells are not the default value.
--]]
function Grid:get_contents(no_default)
    local data     = {}

    for x, y, val in self:iterate() do
        if not (no_default and val == self.default_value) then
            table.insert(data, {x, y, val})
        end
    end

    return data
end

--[[ Gets a cell's neighbor in a given vector. ]]
function Grid:get_neighbor(x, y, vector)
    local obj    = nil
    local vx, vy = table.unpack(vector)

    if vx ~= nil then
        x = x + vx
        y = y + vy

        if self:is_valid(x, y) then
            obj = self:get_cell(x, y)
        end
    end

    return obj
end

--[[
-- Will return a table of 8 elements, with each element
-- representing one of the 8 neighbors for the given
-- x,y cell. Each element of the returned table will consist
-- of the x,y cell pair, plus the data stored there, suitable
-- for use of the populate() method. If the neighbor cell is
-- outside the grid, then {nil, nil, GRID_OUTSIDE} is used for
-- that value.
-- If the given x,y values are not sane, an empty table
-- is returned instead.
--]]
function Grid:get_neighbors(x, y)
    local data = {}
    local vx, vy

    if not self:is_valid(x, y) then return data end

    --[[
    -- The vectors used are x,y pairs between -1 and +1
    -- for the given x,y cell.
    -- IE:
    --     (-1, -1) (0, -1) (1, -1)
    --     (-1,  0) (0,  0) (1,  0)
    --     (-1,  1) (0,  1) (1,  1)
    -- Value of 0,0 is ignored, since that is the cell
    -- we are working with! :D
    --]]
    for gx = -1, 1 do
        for gy = -1, 1 do
            vx = x + gx
            vy = y + gy

            if self:is_valid(vx, vy) and not (gx == 0 and gy == 0) then
                table.insert(data, {vx, vy, self:get_cell(vx, vy)})
            end
        end
    end

    return data
end

--[[
-- This method will change the grid size. If the new size is
-- smaller than the old size, data in the cells now 'outside'
-- the grid is lost. If the grid is now larger, new cells are
-- filled with the default value given when the grid was first
-- created.
--]]
function Grid:resize(newx, newy)
    if (type(newx) ~= "number" or newx == nil) or (type(newy) ~= "number" or newy == nil) then
        error("Grid.resize: size_x and size_y must be a number values equal or greater than 1")
    end

    -- Save old data.
    local contents = self:get_contents()

    -- Set the new sizes.
    self.size_x = newx
    self.size_y = newy

    -- Destroy/reset the internal grid.
    self._grid = {}

    for y = 1, self.size_y   do
        for x = 1, self.size_x do
            self:set_cell(x, y, self.default_value)
        end
    end

    -- Restore the contents.
    self:populate(contents)
end

--[[
-- This method returns a table of all values in a given
-- row 'x' value.
--]]
function Grid:get_row(y)
    local row = {}

    if type(y) == "number" and 0 < y and y <= self.size_y then
        for x = 1, self.size_x do
            table.insert(row, self:get_cell(x, y))
        end
    else
        error("Grid.get_row: invalid row index " .. tostring(y))
    end

    return row
end

--[[
-- This method returns a table of all values in a given
-- column 'y' value.
--]]
function Grid:get_column(x)
    local col = {}

    if type(x) == "number" and  0 < x and x <= self.size_x then
        for y = 1, self.size_y do
            table.insert(col, self:get_cell(x, y))
        end
    else
        error("Grid.get_column: invalid column index " .. tostring(x))
    end

    return col
end

--[[
-- This method traverses a line of cells, from a given x,y
-- going in 'vector' direction. The vector arg is one of the
-- GRID_* traversal constants. This will return a table of
-- data of the cells along the traversal path or nil if
-- the original x,y is not valid or if the vector is not one
-- of the constant values.
-- In the returned table, each element will be in the format
-- of {x, y, obj}, suitable for populate().
--]]
function Grid:traverse(x, y, vector)
    local data = {}
    local gx, gy, vx, vy

    if self:is_valid(x, y) then
        vx, vy = table.unpack(vector)

        if vx == nil then
            -- table is still empty.
            return data
        end

        gx = x + vx
        gy = y + vy

        while self:is_valid(gx, gy) do
            local obj = self:get_cell(gx, gy)

            table.insert(data, {gx, gy, obj})

            gx = gx + vx
            gy = gy + vy
        end

        return data
    end

    return nil
end

return setmetatable(
    {
        new = new,
        direction = {
            GRID_TOP_LEFT = {-1, -1},
            GRID_TOP = {0, -1},
            GRID_TOP_RIGHT = {1, -1},
            GRID_LEFT = {-1, 0},
            GRID_RIGHT = {1, 0},
            GRID_BOTTOM_LEFT = {-1 , 1},
            GRID_BOTTOM = {0, 1},
            GRID_BOTTOM_RIGHT = {1, 1}
        }
    },
    {
        __call = function(_, ...) return new(...) end
    }
)
