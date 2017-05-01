----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- This code is in the public domain.
-- Mostly copied from
--    http://stackoverflow.com/questions/1242572/how-do-you-construct-a-read-write-pipe-with-lua
----------------------------------------------------------------------------
----------------------------------------------------------------------------

local posix = require("posix")

local Pipe = {}

-----------------------------------------------
-- Simple popen3() implementation
-----------------------------------------------
function Pipe.open3(path, ...)
    local r1, w1 = posix.pipe()
    local r2, w2 = posix.pipe()
    local r3, w3 = posix.pipe()

    assert((w1 ~= nil or r2 ~= nil or r3 ~= nil), "pipe() failed")

    local pid, err = posix.fork()
    assert(pid ~= nil, "fork() failed")
    if pid == 0 then
        posix.close(w1)
        posix.close(r2)
        posix.dup2(r1, posix.fileno(io.stdin))
        posix.dup2(w2, posix.fileno(io.stdout))
        posix.dup2(w3, posix.fileno(io.stderr))
        posix.close(r1)
        posix.close(w2)
        posix.close(w3)

        local ret, err = posix.execp(path, unpack({...}))
        assert(ret ~= nil, "execp() failed")

        posix._exit(1)
        return
    end

    posix.close(r1)
    posix.close(w2)
    posix.close(w3)

    return pid, w1, r2, r3
end

-----------------------------------------------
-- Pipe input into cmd + optional arguments and
-- wait for completion and then return status code,
-- stdout and stderr from cmd.
-----------------------------------------------
function Pipe.simple(input, cmd, ...)
    --
    -- Launch child process
    --
    local pid, w, r, e = Pipe.open3(cmd, unpack({...}))
    assert(pid ~= nil, "filter() unable to popen3()")

    --
    -- Write to popen3's stdin, important to close it as some (most?) proccess
    -- block until the stdin pipe is closed
    --
    posix.write(w, input)
    posix.close(w)

    local bufsize = 4096
    --
    -- Read popen3's stdout via Posix file handle
    --
    local stdout = {}
    local i = 1
    while true do
        buf = posix.read(r, bufsize)
        if buf == nil or #buf == 0 then break end
        stdout[i] = buf
        i = i + 1
    end
    posix.close(r)

    --
    -- Read popen3's stderr via Posix file handle
    --
    local stderr = {}
    local i = 1
    while true do
        buf = posix.read(e, bufsize)
        if buf == nil or #buf == 0 then break end
        stderr[i] = buf
        i = i + 1
    end
    posix.close(e)

    --
    -- Clean-up child (no zombies) and get return status
    --
    local wait_pid, wait_cause, wait_status = posix.wait(pid)

    return wait_status, table.concat(stdout), table.concat(stderr)
end

return Pipe
