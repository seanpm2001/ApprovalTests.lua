local fileapprover  = require 'approvals.fileapprover'
local utilities     = require 'approvals.utilities'
local path          = require 'pl.path'

local function clean_up_file ( file_path )
  if path.exists(file_path) then
    assert(os.remove(file_path))
  end
end

local function clean_up ( n, extension )
  clean_up_file(n.expected_file(extension))
  clean_up_file(n.actual_file(extension))
end

local function create_text_file_at( path, contents )
  local a = assert(io.open(path, 'w'))
  a:write(contents)
  a:close()
  return path
end


-- local function create_text_file( name, contents )
--   local actual = utilities.adjacent_path(name)
--   return create_text_file_at(actual,contents)
-- end

-- describe( 'A file approver',  function()
--   describe('file verification', function()


--     it('fails when file contents differ', function ()
--       local actual = create_text_file('ac.txt','12345')
--       local expected = create_text_file('ec.txt','54321')

--       local message = fileapprover.verify_files( actual, expected )
--       assert.equal( 'File contents do not match:\r\n.\\spec\\ec.txt(5)\r\n.\\spec\\ac.txt(5)', message);
--     end)


--   end)

describe('verification', function()
  local namer = {
    actual_file = function ( extension )
      return utilities.adjacent_path('verification.actual' .. extension)
    end,
    expected_file = function ( extension )
      return utilities.adjacent_path('verification.expected' .. extension)
    end
  }

  local reporter = {
    report = function(self, ...)
      self.called = true
    end,
    was_called = function(self)
      return self.called
    end
  }

  local writer = {
    extension = '.txt',
    write = function( path )
      create_text_file_at(path, '12345')
    end
  }


  it( 'fails on missing expected file',  function ()
    clean_up(namer, '.txt')
    assert.has_error(function() fileapprover.verify( writer, namer, reporter ) end,
      'Approved expectation does not exist: verification.expected.txt')

  end )

  it( 'fails when file sizes differ',  function ()

      -- local expected = create_text_file('e.txt', 'hello world')

      -- local  message  =  fileapprover.verify_files( actual,  expected )
      clean_up(namer, '.txt')
      local actual = create_text_file_at(namer.expected_file('.txt'), 'hello world')
      assert.has_error(
        function() fileapprover.verify( writer, namer, reporter ) end,
        'File sizes do not match:\r\nverification.expected.txt(11)\r\nverification.actual.txt(5)')
  end )


  -- it('fails when file contents differ', function ()
  --   local actual = create_text_file('ac.txt','12345')
  --   local expected = create_text_file('ec.txt','54321')

  -- assert.falsy(fileapprover.verify( writer, namer, reporter ));
  -- end)

  it('passes when files are same', function ()
    --       local actual = create_text_file(namer.actual_file('.txt'),'12345')
    local expected = create_text_file_at(namer.expected_file('.txt'),'12345')

    --       print('Verify same files...')
    assert.truthy( fileapprover.verify( writer, namer, reporter ), 'verified ok');
    --       print('they were the same')
    assert.falsy(reporter:was_called(), 'reporter not called')
    --       os.remove(actual)
    --       os.remove(expected)
  end)

  --     it('launches reporter on failure', function()
  --       local expected = namer.expected_file('.txt');
  --       create_text_file_at(expected, 'Helol')

  --       fileapprover.verify( writer, namer, reporter );
  --       assert.truthy(reporter:was_called())
  --     end)

  --     it( 'Removes actual file on match', function ( )
  --       local expected = namer.expected_file('.txt')
  --       create_text_file_at( expected, 'Hello' )

  --       fileapprover.verify( writer, namer, reporter )

  --       assert.falsy(path.exists(namer.actual_file('.txt')))
  --     end)

  --     it( 'Preserves approved file on match', function()
  --       local expected_file = namer.expected_file('.txt');
  --       create_text_file_at( expected_file, 'Hello' );

  --       fileapprover.verify( writer, namer, reporter );

  --       assert.truthy(path.exists(namer.expected_file('.txt')))
  --     end)
  --   end)
end)
