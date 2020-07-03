class Parser
  class << self
    def parse_expense(input)
      data = {}
      parsed_input = input.split(' ')
      creditor_id = parsed_input[1]
      User.new(parsed_input[1]).find_or_create
      amount = parsed_input[2]
      debitor_count = parsed_input[3].to_i
      debitor_ids = []
      1..debitor_count.times.each do |position|
        debitor_id = parsed_input[3 + position]
        User.new(debitor_id).find_or_create
        debitor_ids.push(debitor_id)
      end
      operation = parsed_input[3 + debitor_count + 1].downcase
      operation_values = parsed_input[3 + debitor_count + 2..]
      data = {creditor_id: creditor_id,
              debitor_ids: debitor_ids,
              amount: amount,
              operation: operation,
              operation_values: operation_values
      }
      data
    end

    def parse_balances(input)
      parsed_input = input.split(' ')
      if parsed_input.length == 1 && parsed_input[0] == 'SHOW'
        data = {user_ids: []}
      else
        user_ids = parsed_input[1..]
        data = {user_ids: user_ids}
      end
      data
    end
  end
end