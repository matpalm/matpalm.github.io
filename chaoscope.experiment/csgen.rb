#!/usr/bin/ruby
require 'erb'
require 'ftools'

class Variable
	attr_accessor :current
	def initialize(from, to, num_steps)
		@current = from
		@step = (to-from).to_f / num_steps		
	end
	
	def next
		ret = @current
		@current += @step
		ret
	end	
		
end

class Variables
	def initialize(erb_file)
		@vars = []
		@erb = ERB.new(open(erb_file).read)
	end
	
	def add(var)
		@vars << var
	end
		
	def erb_output
		result = @erb.result(binding)
		next_vars
		result
	end
		
	def x
		@vars.collect { |v| v.current }
	end
	
	def next_vars
		@vars.each { |v| v.next }
	end
	
end

class Projects 	
	def initialize
		File.makedirs 'batch'
	end
	
	def write_next_file_with_contents content
		file = File.new(next_file_name, "w")
		file.write(content)
		file.close		
	end
	
	def next_file_name
		@file_num ||= -1
		@file_num += 1
		"batch/output_project.#{sprintf("%05d",@file_num)}.csproj"
	end
end

raise "usage: csgen.rb erb-file num-steps" unless ARGV.length==2
ERB_FILE, STEPSS = ARGV
STEPS = STEPSS.to_i # hack?

projects = Projects.new

vars = Variables.new(ERB_FILE)
vars.add(Variable.new(0.456098765432099, 0.558098765432099, STEPS))

(1..STEPS).each do 
	projects.write_next_file_with_contents vars.erb_output
end
