--- Heading management for orgmark.
--- Re-exports all heading functions from submodules.
local M = {}

local promote = require('orgmark.headings.promote')
local insert = require('orgmark.headings.insert')
local move = require('orgmark.headings.move')
local navigate = require('orgmark.headings.navigate')

M.promote_heading = promote.promote_heading
M.demote_heading = promote.demote_heading
M.promote_subtree = promote.promote_subtree
M.demote_subtree = promote.demote_subtree
M.insert_sibling = insert.insert_sibling_heading
M.insert_child = insert.insert_child_heading
M.move_up = move.move_subtree_up
M.move_down = move.move_subtree_down
M.next_heading = navigate.next_heading
M.prev_heading = navigate.prev_heading
M.next_sibling = navigate.next_sibling
M.prev_sibling = navigate.prev_sibling
M.parent = navigate.parent_heading

return M
