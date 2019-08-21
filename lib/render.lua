local matrix_stack = {}

local render_pushMatrix = render.pushMatrix
local render_popMatrix = render.popMatrix

----------------------------------------

-- matrix: the VMatrix
-- absolute: should the matrix be absolute to the render contex or stacked ontop of previously pushed matricies
function render.pushMatrix(matrix, absolute)
    if #matrix_stack > 0 then
        if not absolute then
            matrix = matrix_stack[#matrix_stack] * matrix
        end
        
        render_popMatrix()
    end
    
    matrix_stack[#matrix_stack + 1] = matrix
    render_pushMatrix(matrix)
end

function render.popMatrix()
    local len = #matrix_stack
    matrix_stack[len] = nil
    
    render_popMatrix()
    
    if len > 1 then
        render_pushMatrix(matrix_stack[len - 1])
    end
end