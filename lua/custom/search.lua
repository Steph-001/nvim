local M = {}

-- ===============================
-- Helper functions
-- ===============================

-- Find all markdown files in given directories
local function find_markdown_files(directories)
  local files = {}
  for _, dir in ipairs(directories) do
    local expanded_dir = vim.fn.expand(dir)
    local handle
    if vim.fn.executable('rg') == 1 then
      handle = io.popen('rg --files --glob "*.md" "' .. expanded_dir .. '" 2>/dev/null')
    else
      handle = io.popen('find "' .. expanded_dir .. '" -type f -name "*.md" 2>/dev/null')
    end
    if handle then
      for file in handle:lines() do
        files[#files+1] = file
      end
      handle:close()
    end
  end
  return files
end

-- Extract YAML front matter from a markdown file
local function extract_front_matter(file_path)
  local file = io.open(file_path, "r")
  if not file then return nil end
  local content = file:read("*all")
  file:close()

  local front_matter_text = content:match("^%-%-%-\n(.-)\n%-%-%-\n")
  if not front_matter_text then
    front_matter_text = content:match("^%-%-%-%s*\n(.-)\n%-%-%-%s*\n")
    if not front_matter_text then return nil end
  end

  local metadata = {}
  for line in front_matter_text:gmatch("[^\r\n]+") do
    if line:match("^%s*$") then goto continue end
    local key, value = line:match("^%s*([^:]+):%s*(.*)$")
    if key and value then
      key = key:gsub("^%s+", ""):gsub("%s+$", "")
      value = value:gsub("^%s+", ""):gsub("%s+$", "")
      if value:match("^%[.+%]$") then
        local items = {}
        for item in value:sub(2, -2):gmatch("[^,]+") do
          items[#items+1] = item:gsub("^%s+", ""):gsub("%s+$", "")
        end
        metadata[key] = items
      elseif value:match('^".*"$') or value:match("^'.*'$") then
        metadata[key] = value:sub(2, -2)
      else
        metadata[key] = value
      end
    end
    ::continue::
  end
  return metadata
end

-- Get tags from a markdown file
local function get_tags_from_file(file_path)
  local metadata = extract_front_matter(file_path)
  if not metadata or not metadata.tags then return {} end
  local tags = metadata.tags
  if type(tags) == "string" then
    local result = {}
    for tag in tags:gmatch("[^,]+") do
      result[#result+1] = tag:gsub("^%s+", ""):gsub("%s+$", "")
    end
    return result
  end
  return tags
end

-- ===============================
-- Public functions
-- ===============================

-- Search notes by tags with preview (<leader>ft)
function M.search_by_tags()
  local notes_dirs = {
    '/mnt/c/Users/steph/OneDrive - Région Île-de-France/nts',
    '~/notes',
  }

  local files = find_markdown_files(notes_dirs)
  if #files == 0 then
    vim.notify('No markdown files found', vim.log.levels.WARN)
    return
  end

  local all_tags = {}
  local tag_to_files = {}
  local tag_count = {}

  for _, file_path in ipairs(files) do
    local tags = get_tags_from_file(file_path)
    for _, tag in ipairs(tags) do
      if not all_tags[tag] then
        all_tags[tag] = true
        tag_to_files[tag] = {}
        tag_count[tag] = 0
      end
      tag_to_files[tag][#tag_to_files[tag]+1] = file_path
      tag_count[tag] = tag_count[tag] + 1
    end
  end

  local tags_list = {}
  for tag, _ in pairs(all_tags) do
    tags_list[#tags_list+1] = string.format("%s (%d)", tag, tag_count[tag])
  end
  table.sort(tags_list)

  if #tags_list == 0 then
    vim.notify('No tags found', vim.log.levels.WARN)
    return
  end

  require('fzf-lua').fzf_exec(tags_list, {
    prompt = 'Tags> ',
    actions = {
      ['default'] = function(selected)
        local tag = selected[1]:match("^([^(]+)"):gsub("%s+$", "")
        local matching_files = tag_to_files[tag]

        require('fzf-lua').fzf_exec(matching_files, {
          prompt = 'Files with tag [' .. tag .. ']> ',
          previewer = "builtin",
          winopts = { preview = { wrap = "nowrap", title = "File Preview", title_pos = "center" } },
          file_icons = true,
          git_icons = true,
          actions = { ['default'] = function(sel) vim.cmd('edit ' .. sel[1]) end }
        })
      end
    }
  })
end

-- Search for a specific tag (<leader>fs)
function M.search_specific_tag()
  vim.ui.input({ prompt = 'Enter tag to search: ' }, function(tag)
    if not tag or tag == '' then return end

    local notes_dirs = {
      '/mnt/c/Users/steph/OneDrive - Région Île-de-France/nts',
      '~/notes',
    }

    local files = find_markdown_files(notes_dirs)
    local matching_files = {}
    for _, file_path in ipairs(files) do
      local tags = get_tags_from_file(file_path)
      for _, t in ipairs(tags) do
        if t:lower() == tag:lower() then
          matching_files[#matching_files+1] = file_path
          break
        end
      end
    end

    if #matching_files > 0 then
      require('fzf-lua').fzf_exec(matching_files, {
        prompt = 'Files with tag [' .. tag .. ']> ',
        previewer = "builtin",
        winopts = { preview = { wrap = "nowrap", title = "File Preview", title_pos = "center" } },
        file_icons = true,
        git_icons = true,
        actions = { ['default'] = function(sel) vim.cmd('edit ' .. sel[1]) end }
      })
    else
      vim.notify('No files found with tag: ' .. tag, vim.log.levels.WARN)
    end
  end)
end

-- Free-text grep across all notes (<leader>fn)
function M.search_notes_text()
  require('fzf-lua').live_grep({
    search_paths = {
      '/mnt/c/Users/steph/OneDrive - Région Île-de-France/nts',
      '~/notes',
    }
  })
end

return M

