--// table.binsert( table, value [, comp] )
--
-- LUA 5.x add-on for the table library.
-- Does binary insertion of a given value into the table
-- sorted by [,fcomp]. fcomp is a comparison function
-- that behaves like fcomp in in table.sort(table [, fcomp]).
-- This method is faster than doing a regular
-- table.insert(table, value) followed by a table.sort(table [, comp]).
function table.binsert(t, value, fcomp)
  -- Initialise Compare function
  local fcomp = fcomp or function( a, b ) return a < b end

  --  Initialise Numbers
  local iStart, iEnd, iMid, iState =  1, #t, 1, 0

  -- Get Insertposition
  while iStart <= iEnd do
    -- calculate middle
    iMid = math.floor( ( iStart + iEnd )/2 )

    -- compare
    if fcomp( value , t[iMid] ) then
      iEnd = iMid - 1
      iState = 0
    else
      iStart = iMid + 1
      iState = 1
    end
  end

  local pos = iMid+iState
  table.insert( t, pos, value )
  return pos
end
