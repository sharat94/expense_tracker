require 'pry'
class User
  @@friends = []
  attr_accessor :id, :recieve, :give

  def initialize(id)
    @id = id
    @recieve ||= {}
    @give ||= {}
  end

  def find_or_create
    user = @@friends.find {|user| user.id == self.id}
    @@friends.push(self) if user.nil?
    return self
  end

  def self.show_balances(data)
    if !data[:user_ids].empty?
      users = []
      binding.pry
      @@friends.each do |f|
        users.push(f) if data[:user_ids].include?(f.id)
      end
    else
      users = @@friends
    end
    print_balances(users)
  end

  def self.print_balances(users)
    users.each do |user|
      puts "Balance Info for #{user.id}:"
      user.give.keys.each do |creditor_id|
        puts "#{user.id} owes #{creditor_id} an amount of #{user.give[creditor_id]}"
      end
      user.recieve.keys.each do |debitor_id|
        puts "#{user.id} should recieve #{debitor_id} an amount of #{user.recieve[debitor_id]}"
      end
    end
  end
  def self.add_expense(data)
    operation = data[:operation]
    amount = data[:amount].to_f
    operation_values = data[:operation_values]
    creditor = @@friends.find {|f| f.id == data[:creditor_id]}
    debitors = []
    @@friends.each do |f|
      debitors.push(f) if data[:debitor_ids].include?(f.id)
    end
    if operation == 'equal'
      individual_amount = amount / debitors.count.to_f
      debitors.each do |debitor|
        debitor.give[creditor.id] ||= 0
        debitor.give[creditor.id] += individual_amount
        creditor.recieve[debitor.id] ||= 0
        creditor.recieve[debitor.id] += individual_amount
      end
    elsif operation == 'exact'
      raise 'Amount not divided in exact parts' if amount.to_i != operation_values.map(&:to_i).inject(:+)
      debitors.each_with_index do |debitor, index|
        debitor.give[creditor.id] ||= 0
        debitor.give[creditor.id] += operation_values[index].to_i
        creditor.recieve[debitor.id] ||= 0
        creditor.recieve[debitor.id] += operation_values[index].to_i
      end
    elsif operation == 'percent'
      raise 'Amount not divided in correct percetages' if operation_values.map(&:to_i).inject(:+) != 100
      debitors.each_with_index do |debitor, index|
        debitor.give[creditor.id] ||= 0
        debitor.give[creditor.id] += calcualte_percentage(operation_values[index].to_i, amount)
        creditor.recieve[debitor.id] ||= 0
        creditor.recieve[debitor.id] += calcualte_percentage(operation_values[index].to_i, amount)
      end
    elsif operation == 'share'
      raise 'Amount mismatch with shares' if operation_values.map(&:to_i).inject(:+) != debitors.length
      debitors.each_with_index do |debitor, index|
        debitor.give[creditor.id] ||= 0
        debitor.give[creditor.id] += calculate_share(operation_values[index].to_i, amount, debitors.length)
        creditor.recieve[debitor.id] ||= 0
        creditor.recieve[debitor.id] += calculate_share(operation_values[index].to_i, amount, debitors.length)
      end
    end
  end

  def self.calcualte_percentage(value, amount)
    percentage = value / 100.to_f
    actual_amount = percentage * amount
    return actual_amount
  end

  def self.calculate_share(share, amount, total_shares)
    share / total_shares.to_f * amount
  end
end

