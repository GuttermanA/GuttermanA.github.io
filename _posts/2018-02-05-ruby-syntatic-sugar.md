---
layout: post
title:  "Ruby: Some Syntactic Sugar and Other Cool Tricks"
date:   2018-02-26 08:15:00
categories: Ruby, beginners, syntactic sugar
published: true
future: true
---
During the first 3 weeks of my time at Flatiron School, I have learned a lot of useful tricks in Ruby that simplify logic and make code significantly easier to read. Ruby is chock full of what the programming world calls syntatic sugar: mechanisms for writing complicated language constructs in a much more succinct way. Most beginner rubyists are already using a lot of Ruby's built in syntatic sugar and don't even know it. The purpose of this blog post is to give some more advanced examples that many beginners will find useful. There are a lot of resources out there on all of the interesting syntatic things you can do with Ruby, but this collection contains what I have found most useful in the beginning of my journey to becoming a fullstack developer.

First, let me give a short example of syntatic sugar that all rubyists, will be familiar with, the bracket notation:

{% highlight ruby %}
array = [1, 2, 3, 4, 5]
array.map do |n|
  n + 1
end
#=> [2, 3, 4, 5]
{% endhighlight %}

The block above can be shortened to:

{% highlight ruby %}
array.map {|n| n + 1}
#=> [2, 3, 4, 5]
{% endhighlight %}

### Comparing Arrays
Continuing on array functions, comparing arrays can be done like this:

{% highlight ruby  %}
a =  ["a", "b", "c", "d" ]
b = [ "c", "d", "e", "f"]
c = []
a.each do |a_element|
  b.select do |b_element|
    a_element == b_element
      c << b_element
    end
  end
end

#=> c = [ "c", "d" ]
{% endhighlight %}

Instead we can do:

{% highlight ruby %}
a =  ["a", "b", "c", "d" ]
b = [ "c", "d", "e", "f"]

a & b
#=> [ "c", "d" ]
{% endhighlight %}

With the & array method, we cut 7 lines of code down into 1.

### The Magic of the Or(||) Operator

The \|\| operator in Ruby  has many more uses than just simply comparing values in conditional statements. \|\| is actually a method that has special syntax, which means it has a return value. It works in two stages. If the parameter on the left is truthy, it returns that value. If the parameter on the left is falsey, it moves onto evaluate the statement on the right and will return that value if it is truthy. If both statements are falsey, then it returns false.

These can be used to change the output of a method:

{% highlight ruby %}
def self.login
  puts "Please enter your username: "
  username = gets.chomp.split(" ").map{|w| w.capitalize}.join(" ")
  self.find_by(name: username) || self.login
end
{% endhighlight %}

The example above is taken from my first project at Flatiron School. The method is used to log a user in to a simple Command Line Interface (CLI) application using ActiveRecord. The magic happens on the final line. In this case, \|\| is acting as an if/else statement. It still follows the rules of the operator, but of values we are passing methods.

If ```self.find_by(name: username)``` evaluates to true, it returns the user in the database. If it evaluates to false, the method is called again until a correct entry is received.

Another cool feature of the \|\| operator can be used to set values of variables:

{% highlight ruby %}
a = nil
b = 20
a ||= b
# a => 20
{% endhighlight %}

In the example above, the value of a will be set to b since it is nil, and therefore a falsey value. If instead a has a value, it will retain that value since \|\| will always return the value on the left it is truthy, ignoring the value on the right completely.

{% highlight ruby %}
a = 10
b = 20
a ||= b
# a  => 10
{% endhighlight %}

### A Shortcut to Modifying Arrays

If you spend enough time on StackOverflow, you will notice that answers about modifying arrays may have a unique syntax.

For example, if you want to capitalize every string in an array, you could write a method like this:

{% highlight ruby %}
array = [ "apple", "orange", "pear"]
array.map do |x|
  x.capitlize
end
#=> [ "Apple", "Orange", "Pear"]
{% endhighlight %}

Instead, you can write the method like so:

{% highlight ruby %}
array = [ "apple", "orange", "pear"]
array.map(&:capitlize)
#=> [ "Apple", "Orange", "Pear"]
{% endhighlight %}

Essentially, the above syntax is using the passed method, in this case capitalize, as a [Proc](http://awaxman11.github.io/blog/2013/08/05/what-is-the-difference-between-a-block/) on each element of the array.

### Storing a Method as a Variable

In my first project at Flatiron, my partner and I encountered an interesting challenge of moving between menus of our CLI application. We wanted to give the user the ability to return the previous menu or main menu in a direct way. We were able to implement this functionality using the following logic:

{% highlight ruby %}
class Cli
  def initialize
    @previous_menu = nil
  end

  def some_menu_interface
    self.previous_menu = __method__
    return_to_previous_menu_interface
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
{% endhighlight %}

The important part of the code snippet above is line 7. The \_\_method\_\_ syntax enables you to store the name of the currently executing method at a symbol. In this case, we associated the current menu method with an instance variable of @previous_menu. This allowed us to move between menus by using send(@previous_menu) in our current instance of the CLI. The send method can be invoked on any object and takes the arguments of a method name stored as symbol and any parameters.

This syntax gets around the fact that Ruby implicitly calls the method when you set a variable equal to a method. I thought this would be interesting to share, even though the same result can be achieved through procs and lambas in this case.

### Mass Assignment of Parameters

If you have used active record, you will be familiar with the concept of mass assignment. Simply put, ruby allows parameters of methods to be passed as a hash, as long as the parameters in the method are symbols, like so:

{% highlight ruby %}
person = {name: "Bob", age: 50}

def print_person_info(name:, age:)
  puts "Name: #{name}\nAge: #{age}"
end

#=> Name: Bob
#   Age: 50
{% endhighlight %}

Mass assignment is very powerful since it allows for the passing of many parameters quickly and without worrying about there order. In ActiveRecord, this allows for methods like .create and .update to function, with the parameters passed being the column names in your SQL database.
