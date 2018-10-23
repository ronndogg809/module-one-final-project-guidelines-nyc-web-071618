require 'rest-client'
require 'json'
require 'pry'
$cart= []
$cart_price = []
$invoice = []

def welcome
  puts "Welcome to BriRon's Discount Palace!"
end

def get_customer_name
  puts "Please enter your full name."
  gets.chomp
end

def invalid_command
  puts "Please enter a valid command"
end

def prompt_for_keyword
  puts "Please enter a product keyword"
end

def prompt_for_specific
 puts "please select item number"
end

def get_item_number
 gets.chomp.to_i
end

def prompt_for_quantity
  puts "Please select the quantity"
end

def get_quantity_num
 gets.chomp.to_i
end

def get_user_input
  gets.chomp
end

def offer_prev_cust_next_choice
  puts "Would you like to shop or end your session?"
  puts "Type 's' to shop or 'e' to end session"
    cust_answer=gets.chomp
      if cust_answer=='s'
        results_menu
      else
        puts "Here are your purchases:"
        show_invoice
        puts "Thanks for stopping by!"
      end
end

def get_results_from_api(cust_input_word)
  api_info = RestClient.get("http://api.walmartlabs.com/v1/search?query=#{cust_input_word}&format=json&apiKey=7sdwmrs9mhx2zg7sjq3arbqu")
  inventory_info = JSON.parse(api_info)
    inventory_info["items"].map do |product_hash|
      hash = {}
      hash[:name] = product_hash["name"]
      hash[:sale_price] = product_hash["salePrice"]
      hash
    end
end

def results_menu(cust_input_word)
   results = get_results_from_api(cust_input_word)
   i=1
     results.each do |item|
       puts "#{i}. #{item[:name]} (price: $#{item[:sale_price]})"
       i+=1
     end
end

def select_result_and_quantity(cust_input_word, cust_input_number, cust_input_quantity)
  results = get_results_from_api(cust_input_word)
    index = cust_input_number -= 1
      $cart << results[index][:name]
      $cart_price << (results[index][:sale_price]* cust_input_quantity).round(2)
        results[index]
end

def add_cart
  puts "Would you like to add to cart? press 'y' for yes and 'n' for no"
end

def adds_to_cart
  $cart_price.reduce(:+).round(2)
end

def invoice
  $invoice = $cart.zip $cart_price
    puts $invoice
end

def find_or_create_customer
  welcome
    name = get_customer_name #asks for full name, assigns input to variable
      customer = Customer.find_by(name: name) #assigns search to variable
        if customer == nil
          customer = Customer.create(name: name) # creates customer if not found
            puts "We've created a customer account for you. Let's go shopping!!"
              return_results
        else
          puts "We're glad to see you back!"
          puts "Let's go shopping!!"
            return_results
        end
end

def keep_shopping
  puts "Enter 's' to keep shopping or 'c' to checkout."
    response=gets.chomp
      if response=='s'
        return_results
      elsif response=='c'
        puts "Here is your invoice:"
          invoice
            puts "Your total is $#{adds_to_cart} You may pay Brian or Ron IN CASH, NOW. Thanks for your business!"
      end
end

def answer_response(input)
  response = input
  if response == "y"
    adds_to_cart
      invoice
      keep_shopping
  elsif response == "n"
    return_results
  else
    invalid_command
    add_cart
    answer = get_user_input
    answer_response(answer)
  end
end

def return_results
prompt_for_keyword
answer = get_user_input
results_menu(answer)
prompt_for_specific
item_number = get_item_number
prompt_for_quantity
quantity= get_quantity_num
select_result_and_quantity(answer,item_number, quantity)
add_cart
answer = get_user_input
answer_response(answer)
end
