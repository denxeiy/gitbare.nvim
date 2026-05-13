local config = require "gitbare.config"
local Path = require "plenary.path"

local M = {}

local function git_list_files(gitdir)
  return vim.fn.systemlist(
    string.format('git --git-dir="%s" ls-tree -r --name-only HEAD', gitdir)
  )
end

local function git_status_map(gitdir)
  local lines = vim.fn.systemlist(
    string.format('git --git-dir="%s" status --porcelain', gitdir)
  )

  local map = {}
  for _, line in ipairs(lines) do
    if line ~= "" then
      local status = line:sub(1, 1)
      local path = line:sub(4)
      map[path] = status
    end
  end
  return map
end

local function git_size_map(gitdir)
  local lines = vim.fn.systemlist(
    string.format('git --git-dir="%s" ls-tree -r -l HEAD', gitdir)
  )

  local map = {}
  for _, line in ipairs(lines) do
    if line ~= "" then
      local parts = vim.split(line, "%s+")
      local size = tonumber(parts[4]) or 0
      local path = parts[#parts]
      map[path] = size
    end
  end
  return map
end

local function git_mtime_map(gitdir)
  local lines = vim.fn.systemlist(
    string.format('git --git-dir="%s" log --name-only --format="%%ct" HEAD', gitdir)
  )

  local map = {}
  local current_time = nil

  for _, line in ipairs(lines) do
    if line:match("^%d+$") then
      current_time = tonumber(line)
    elseif line ~= "" and current_time then
      map[line] = current_time
    end
  end

  return map
end

function M.scan_repo(dir, gitdir)
  local files = git_list_files(gitdir)
  local statuses = git_status_map(gitdir)
  local sizes = git_size_map(gitdir)
  local mtimes = git_mtime_map(gitdir)

  local results = {}

  for _, rel in ipairs(files) do
    table.insert(results, {
      relpath = rel,
      path = dir .. "/" .. rel,
      status = statuses[rel] or " ",
      size = sizes[rel] or 0,
      mtime = mtimes[rel] or 0,
    })
  end

  return results
end

local function build_tree(files)
  local root = {}

  for _, path in ipairs(files) do
    local parts = {}
    for part in string.gmatch(path, "[^/]+") do
      table.insert(parts, part)
    end

    local node = root
    for i, part in ipairs(parts) do
      local key = tostring(part)

      if i == #parts then
        node[key] = { __file = true }
      else
        if type(node[key]) ~= "table" then
          node[key] = {}
        end
        node = node[key]
      end
    end
  end

  return root
end

local function compute_dir_metadata(node, prefix, sizes, mtimes)
  local total_size = 0
  local latest_mtime = 0

  for name, child in pairs(node) do
    if name ~= "__file" and type(child) == "table" then
      local full = prefix ~= "" and (prefix .. "/" .. name) or name

      if child.__file then
        local sz = sizes[full] or 0
        local mt = mtimes[full] or 0

        child.__total_size = sz
        child.__latest_mtime = mt

        total_size = total_size + sz
        if mt > latest_mtime then latest_mtime = mt end

      else
        compute_dir_metadata(child, full, sizes, mtimes)

        total_size = total_size + (child.__total_size or 0)
        if (child.__latest_mtime or 0) > latest_mtime then
          latest_mtime = child.__latest_mtime
        end
      end
    end
  end

  node.__total_size = total_size
  node.__latest_mtime = latest_mtime
end

local function get_dir_entries(tree, rel)
  if rel == "" or rel == "/" then
    return tree
  end

  local node = tree
  for part in string.gmatch(rel, "[^/]+") do
    part = tostring(part)
    node = node[part]
    if type(node) ~= "table" then
      return {}
    end
  end

  return node
end

function M.scan(path)
  local repo_root = config.options.dir
  local gitdir = config.options.git_dir

  local rel = Path:new(path):make_relative(repo_root)
  if rel == "." then rel = "" end

  local files = git_list_files(gitdir)
  local statuses = git_status_map(gitdir)
  local sizes = git_size_map(gitdir)
  local mtimes = git_mtime_map(gitdir)

  local tree = build_tree(files)
  compute_dir_metadata(tree, "", sizes, mtimes)

  local entries = get_dir_entries(tree, rel)
  local result = {}

  for name, node in pairs(entries) do
    if name ~= "__file" and type(node) == "table" then
      local full = Path:new(repo_root, rel, name):absolute()
      local is_dir = not node.__file
      local relpath = (rel ~= "" and rel .. "/" or "") .. name

      table.insert(result, {
        name = name,
        path = full,
        is_dir = is_dir,
        size = node.__total_size or 0,
        mtime = node.__latest_mtime or 0,
        git_status = statuses[relpath] or " ",
      })
    end
  end

  return result
end

return M
