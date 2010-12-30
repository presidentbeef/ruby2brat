require "rubygems"
require "ruby_parser"
require "ruby2ruby"

class Ruby2Brat < Ruby2Ruby
	REPLACE = { :puts => :p, :initialize => :init }

	def initialize *args
		super
		self.auto_shift_type = true
		self.expected = String
		@current_scope = ['my']
	end

	def current_object
		@current_scope.join '.'
	end

	def process_args sexp
		output = sexp.map do |s|
			if s.is_a? Sexp
			else
				s.to_s
			end
		end.join ' ,'
		sexp.clear
		output
	end

	def process_block sexp
		process_scope sexp
	end

	def process_call sexp
		target = process(sexp[0]) || current_object
		method = REPLACE[sexp[1]] || sexp[1]
		args = process sexp[2]

		sexp.clear

		"#{target}.#{method}(#{args})"
	end

	def process_defn sexp
		method_name = sexp[0].to_s
		args = process sexp[1]
		body = process sexp[2]

		sexp.clear

		"#{current_object}.#{method_name} = { #{args} |	#{body} }"
	end

	def process_if sexp
		condition = process sexp[0]
		true_action = process sexp[1]
		false_action = process sexp[2]

		sexp.clear

		<<-BRAT
		true? { #{condition} },
			{ #{true_action} },
			{ #{false_action} }
			BRAT
	end

	def process_lasgn sexp
		lhs = sexp[0]
		rhs = process sexp[1]
		sexp.clear

		"#{lhs} = #{rhs}"
	end

	def process_lit sexp
		output = "#{sexp[0].inspect}"
		sexp.clear
		output
	end

	def process_lvar sexp
		output = sexp[0].to_s

		sexp.clear

		output
	end

	def process_module sexp
		module_name = sexp[0].to_s
		@current_scope << module_name


		output = "#{module_name} = object.new\n" << process(sexp[1])

		sexp.clear

		output
	end

	def process_return sexp
		value = sexp[0]
		sexp.clear
		process value 
	end

	def process_scope sexp
		output = sexp.map do |s|
			process s
		end.join "\n"

		sexp.clear

		output
	end
end

#Test
puts Ruby2Brat.new.process RubyParser.new.parse $stdin.read
