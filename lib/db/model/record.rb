# frozen_string_literal: true

# Copyright, 2021, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require_relative 'statement/select'
require_relative 'statement/equal'
require_relative 'statement/limit'

require_relative 'statement/insert'
require_relative 'statement/multiple'
require_relative 'statement/fields'
require_relative 'statement/tuple'

require_relative 'statement/update'
require_relative 'statement/assignment'

require_relative 'scope'
require_relative 'where'

module DB
	module Model
		module Record
			class SerializationError < RuntimeError
			end
			
			module Base
				def self.extended(klass)
					klass.instance_variable_set(:@properties, {})
					klass.instance_variable_set(:@relationships, {})
					
					klass.instance_variable_set(:@key_columns, [:id].freeze)
					
					default_type = klass.name.split('::').last.gsub(/(.)([A-Z])/,'\1_\2').downcase!.to_sym
					klass.instance_variable_set(:@type, default_type)
				end
				
				attr :type
				attr :properties
				attr :relationships
				attr :key_columns
				
				def primary_key
					@key_columns.map do |name|
						DB::Identifier[@type, name]
					end
				end
				
				# Directly create one record.
				def create(context, **attributes)
					Statement::Insert.new(self,
						Statement::Fields.new(attributes.keys),
						Statement::Tuple.new(attributes.values)
					).to_a(context).first
				end
				
				# Directly insert one or more records.
				def insert(context, keys, rows, **attributes)
					if attributes.any?
						fields = Statement::Fields.new(attributes.keys + keys)
						values = attributes.values
						tuples = rows.map{|row| Statement::Tuple.new(values + row)}
					else
						fields = Statement::Fields.new(keys)
						tuples = rows.map{|row| Statement::Tuple.new(row)}
					end
					
					return Statement::Insert.new(self, fields, Statement::Multiple.new(tuples)).to_a(context)
				end
				
				# Find records which match the given primary key.
				def find(context, *key)
					Statement::Select.new(self,
						where: find_predicate(*key),
						limit: Statement::Limit::ONE
					).to_a(context).first
				end
				
				def find_predicate(*key)
					Statement::Equal.new(self, self.primary_key, key)
				end
				
				def where(context, *arguments, **options, &block)
					Where.new(context, self, *arguments, **options, &block)
				end
				
				def property(name, klass = nil)
					if @properties.key?(name)
						raise ArgumentError.new("Property #{name.inspect} already defined!")
					end
					
					@properties[name] = klass
					
					if klass
						self.define_method(name) do
							if @changed&.key?(name)
								return @changed[name]
							elsif @attributes.key?(name)
								value = @attributes[name]
								klass.load(value)
							else
								nil
							end
						end
					else
						self.define_method(name) do
							if @changed&.key?(name)
								return @changed[name]
							else
								@attributes[name]
							end
						end
					end
					
					self.define_method(:"#{name}=") do |value|
						@changed ||= Hash.new
						@changed[name] = value
					end
					
					self.define_method(:"#{name}?") do
						value = self.send(name)
						
						if !value
							false
						elsif value.respond_to?(:empty?)
							!value.empty?
						else
							true
						end
					end
				end
			end
			
			def self.included(klass)
				klass.extend(Base)
			end
			
			def initialize(context, attributes, cache = nil)
				@context = context
				@attributes = attributes
				@changed = changed
				@cache = cache
			end
			
			attr :context
			attr :attributes
			attr :changed
			attr :cache
			
			def to_s
				"\#<#{self.class.type} #{@attributes.inspect}>"
			end
			
			def inspect
				if @changed&.any?
					"\#<#{self.class.type} #{@attributes.inspect} changed=#{@changed.inspect}>"
				else
					to_s
				end
			end
			
			def assign(changed)
				@changed = changed
				
				return self
			end
			
			def reload(context = @context)
				if key = self.persisted?
					self.class.find(context, *key)
				end
			end
			
			# A record which has a valid primary key is considered to be persisted.
			def persisted?
				self.class.key_columns.map do |field|
					@attributes[field] or return false
				end
			end
			
			def new_record?
				!persisted?
			end
			
			def save(context: @context)
				return unless attributes = self.flatten!
				
				if key = persisted?
					statement = Statement::Update.new(self.class,
						Statement::Assignment.new(attributes),
						self.class.find_predicate(*key)
					)
				else
					statement = Statement::Insert.new(self.class,
						Statement::Fields.new(attributes.keys),
						Statement::Tuple.new(attributes.values)
					)
				end
				
				statement.call(@context) do |attributes|
					# Only insert will hit this code path:
					@attributes.update(attributes)
				end
				
				return self
			end
			
			def scope(model, attributes)
				Scope.new(@context, model, attributes, @cache)
			end
			
		protected
			
			# Moves values from `@changed` into `@attributes`.
			def flatten!
				return nil unless @changed&.any?
				
				properties = self.class.properties
				changed = {}
				
				@changed.each do |key, value|
					if klass = properties[key]
						value = klass.dump(value)
					end
					
					changed[key] = @attributes[key] = value
				end
				
				@changed = nil
				
				return changed
			end
		end
	end
end
