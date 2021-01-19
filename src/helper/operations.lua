-- helper.operations

local operation = {}

-- Get table len
function operation.tableLen(tab)
    local count = 0
    for _ in pairs(tab) do count = count + 1 end
    return count
end

-- Find array in table with one index search
function operation.tableSearchStatus1(tableName, positonIndex0, positionValue0)
    for i, value in ipairs(tableName) do
      if value[positonIndex0] == positionValue0 then
        return i
      end
    end
end

-- Find array in table with two index search
function operation.tableSearchStatus2(tableName, positonIndex0, positionValue0, positonIndex1, positionValue1)
    for i, value in ipairs(tableName) do
      if value[positonIndex0] == positionValue0 then
        if value[positonIndex1] == positionValue1 then
          return i
        end
      end
    end
end

return operation
