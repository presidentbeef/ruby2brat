require 'test/unit'
require 'shell'

Shell.def_system_command :brat
Shell.def_system_command :ruby2brat, "ruby ./bin/ruby2brat"

if ARGV.include? "--log"
  File.safe_unlink "test.log"
  LOG = true
else
  LOG = false
end

class Ruby2BratTests < Test::Unit::TestCase
  def assert_result expected, ruby_code, preamble = nil
    ruby_code = <<-RUBY
    #{preamble}

    def test_
    #{ruby_code}
    end

    print test_()
    RUBY

    sh = Shell.new

    brat_code = sh.transact do
      echo(ruby_code) | ruby2brat
    end.to_s

    if LOG
      File.open "test.log", "a+" do |f|
        f.puts "--- #{caller}  ---"
        f.puts brat_code
      end
    end

    result = sh.transact do
      echo(brat_code) | brat("-")
    end.to_s

    assert_equal expected, result
  end

	def test_and_chained
		assert_result "true", "1 and true and 1 == 1"
	end

	def test_and_in_if
		assert_result "1", "x", <<-RUBY
		x = 0

		if x and x = 1
		end
		RUBY
	end

	def test_and_simple
		assert_result "false", "true and false"
		assert_result "false", "nil and false"
		assert_result "true", "true and 1"
	end

  def test_array_access
    assert_result "3", "a = [1,2,3]; a[2]"
    assert_result "3", "a = [1,2,3]; b = [a]; b[0][2]"
    assert_result "[2, 3]", "a = [1,2,3]; a[1..-1]"
  end

  def test_array_set
    assert_result "3", "a = [:a, :b, :c]; a[2] = 3; a[2]"
  end

	def test_class_constant
		assert_result "100", "A::CONSTANT", <<-RUBY
		class A
			CONSTANT = 100
		end
		RUBY
	end

	def test_class_variables
		assert_result "1", "B.new.something", <<-RUBY
		class A
			@@test = 1
		end
	
		class B < A
			def something
				@@test
			end
		end
		RUBY
	end

	def test_constant
		assert_result "100", "CONSTANT", <<-RUBY
		CONSTANT = 100
		RUBY
	end

  def test_default_args
    assert_result "3", "hello 1, 2", <<-RUBY
    def hello x, y, z = 3
      z
    end
    RUBY

    assert_result "c", "hello :a, :b, :c", <<-RUBY
    def hello x, y, z = 3
      z
    end
    RUBY
  end

	def test_early_return
		assert_result "true", "a_method", <<-RUBY
		def a_method
			return true
			false
		end
		RUBY
	end

	def test_hash
		assert_result "a", "a = { 1 => 'a'}; a[1]"
	end

  def test_here_document
    assert_result "    Twinkle, twinkle", "poem.split('\n').first", <<-RUBY
    poem = <<-POEM
    Twinkle, twinkle
      little star
    How I wonder
      what you are
    POEM
    RUBY
  end

  def test_inheritance
    assert_result "a method", "B.new.a_method", <<-RUBY
    class A
      def a_method
        "a method"
      end
    end

    class B < A
    end
    RUBY
  end

  def test_inject
    assert_result "15", "[1,2,3,4,5].inject(0) { |i,m| m += i }"
  end

  def test_instance_method
    assert_result "a method", "A.new.a_method", <<-RUBY
    class A
      def a_method
        "a method"
      end
    end
    RUBY
  end

	def test_method_name
		assert_result "_method", "_method", <<-RUBY
		def _method
			"_method"
		end
		RUBY
	end

	def test_module_nested
		assert_result "c", "A::B::C.new.test", <<-RUBY
		module A
			module B
				class C
					def test
						"c"
					end
				end
			end
		end
		RUBY
	end

	def test_multiple_returns
		assert_result "true", "a_method false", <<-RUBY
		def a_method cond
			if not cond
				return true
			else
				return false
			end

			return 6
		end
		RUBY
	end

	def test_null
		assert_result "null", "nil"
	end

	def test_or_assign
		assert_result "5", "x ||= 3", <<-RUBY
		x = 5
		RUBY

		assert_result "3", "x ||= 3"

		assert_result "3", "x", <<-RUBY
		x ||= 3
		RUBY
	end

	def test_or_chained
		assert_result "true", "nil or false or true"
	end

	def test_or_in_if
		assert_result "0", "x", <<-RUBY
		x = 0

		if x or (x = 1)
		end
		RUBY
	end

	def test_or_simple
		assert_result "true", "true or false"
		assert_result "false", "nil or false"
	end

	def test_simple_return
		assert_result "a method", "a_method", <<-RUBY
		def a_method
			return "a method"
		end
		RUBY
	end

  def test_simple_string_interpolation
    assert_result "hello world", '"hello #{"world"}"'
  end

  def test_simple_method
    assert_result "a method", "a_method", <<-RUBY
    def a_method
      "a method"
    end
    RUBY
  end

  def test_splat_parameters
    assert_result "[]", "hello 1, 2", <<-RUBY
    def hello x, y, *z
      z
    end
    RUBY

    assert_result "[c, d, e]", "hello :a, :b, :c, :d, :e", <<-RUBY
    def hello x, y, *z
      z
    end
    RUBY
  end

  def test_string
    assert_result "hi", "'hi'"
  end

	def test_unused_return
		assert_result "true", "a_method", <<-RUBY
		def a_method
			return 6 if false

			true	
		end
		RUBY
	end
end
