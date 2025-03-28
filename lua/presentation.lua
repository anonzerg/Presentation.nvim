local M = {}

M.setup = function()
end

local function create_floating_win(opts)
  opts = opts or {}
  local width = opts.width or math.floor(vim.o.columns * 0.5)
  local height = opts.height or math.floor(vim.o.lines * 0.5)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)
  local buf = vim.api.nvim_create_buf(flase, true)
  local win_config = {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    focusable = true,
    style = "minimal",
    border = "single",
  }
  local win = vim.api.nvim_open_win(buf, true, win_config)
  return {buf = buf, win = win}
end

local parse_slides = function(lines)
  local slides = {slides = {}}
  local current_slide = {}
  local seperator = "^#"
  for _, line in ipairs(lines) do
    -- print(line, "find:", line:find(seperator), "|")
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

M.start_presentation = function(opts)
  opts = opts or {}
  opts.bufnr = opts.bufnr or 0

  local lines = vim.api.nvim_buf_get_lines(opts.bufnr, 0, -1, false)
  local parsed = parse_slides(lines)
  local floating_win = create_floating_win()

  local current_slide = 1
  vim.keymap.set("n", "n", function()
    current_slide = math.min(current_slide + 1, #parsed.slides)
    vim.api.nvim_buf_set_lines(floating_win.buf, 0, -1, false, parsed.slides[current_slide])
  end, {
  buffer = floating_win.buf})

  vim.keymap.set("n", "p", function()
    current_slide = math.max(current_slide - 1, 1)
    vim.api.nvim_buf_set_lines(floating_win.buf, 0, -1, false, parsed.slides[current_slide])
  end, {
  buffer = floating_win.buf})

  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(floating_win.win, true)
  end, {
  buffer = floating_win.buf})

  vim.api.nvim_buf_set_lines(floating_win.buf, 0, -1, false, parsed.slides[current_slide])
end

M.start_presentation {bufnr = 2}

-- vim.print( {
--   "#hello",
--   "hello, world!",
--   "#another thing",
--   "another text",
-- })

return M

