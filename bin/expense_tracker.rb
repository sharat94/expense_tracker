#!/usr/bin/env ruby
require '../lib/user'
require '../lib/parser'
require 'pry'
@friends = []
while true # STDIN
  puts "Please enter the input:"
  input = gets.downcase.strip
  if input.include? 'expense'
    data = Parser.parse_expense(input)
    User.add_expense(data)
    puts "Expense successfully added"
  elsif input.include? 'show'
    data = Parser.parse_balances(input)
    User.show_balances(data)
  end
end

