require 'task'
require 'util'
require 'util/logger'

WaitForOutputTask = Task:new()
local log = Logger.makeLogger("WaitForOutputTask");
