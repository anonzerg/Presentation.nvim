local M = {}

M.setup = function()
end

local parse_slides = function(lines)
  local slides = {slides = {}}
  local current_slide = {}
  local seperator = "^#"
  for _, line in ipairs(lines) do
    print(line, "find:", line:find(seperator), "|")
    if line:find(seperator) then
      if #current_slide > 0 then
        table.insert(slides.slides, current_slide)
      end
      current_slide = {}
    end
    table.insert(current_slide, line)
  end

  table.insert(slides.slides, current_slide)

  return slides
end

vim.print(parse_slides {
  "#hello",
  "hello, world!",
  "#another thing",
  "another text",
})

return M

