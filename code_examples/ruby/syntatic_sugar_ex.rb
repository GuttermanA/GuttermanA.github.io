#EXAMPLES

#Bracket Notation
array = [1, 2, 3, 4, 5]

array.map do |n|
  n + 1
end
#=> [2, 3, 4, 5]

array.map {|n| n + 1}
#=> [2, 3, 4, 5]

#COMPARING ARRAYS

a =  ["a", "b", "c", "d" ]
b = [ "c", "d", "e", "f"]
c = []
a.each do |a_element|
  b.each do |b_element|
    if a_element == b_element
      c << b_element
    end
  end
end

#=> c = [ "c", "d" ]

a =  ["a", "b", "c", "d" ]
b = [ "c", "d", "e", "f"]

a & b
#=> [ "c", "d" ]

#|| Output of methods

def self.login
  puts "Please enter your username: "
  username = gets.chomp.split(" ").map{|w| w.capitalize}.join(" ")
  self.find_by(name: username) || self.login
end


#Storing Method Names
class Cli
  def initialize
    @previous_menu = nil
  end

  def some_menu_interface
    self.previous_menu = __method__
  end

  def return_to_previous_menu_interface
  menu_input = nil
  until menu_input == "0" || menu_input == "m"
    puts "Enter 0 to return to previous menu or M to return to main menu"
    menu_input = gets.chomp
  end
  if menu_input == "0"
    send(previous_menu)
  elsif menu_input.downcase == "m"
    main_menu_interface
  end
end

#Mass Assignment

person = {name: "Bob", age: 50}

def print_person_info(name:, age:)
  puts "Name: #{name}\nAge: #{age}"
end

#=> Name: Bob
#   Age: 50
