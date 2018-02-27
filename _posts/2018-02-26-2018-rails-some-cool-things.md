---
layout: post
title:  "Rails: Custom Slugs and Params"
date:   2018-02-26 08:15:00
categories: Ruby, Rails, Project
published: true
future: true
---

{% highlight ruby %}
{% endhighlight %}

My first Rails project at Flatiron School presented some unique challenges for my partner and I to solve. This blog post will go over some of these challenges and how we solved them. Hopefully it can be a resource to other beginner Rails developers in taking their projects to the next level. If you want to take look the final product of my Module 2 project, you can find it [here](https://would-you-rather-game.herokuapp.com/).

## Vanity URLs Using Custom Slugs

By default, the paths for a rails website will follow the convention of nesting the ID of an object under the object namespace. For example, our project had questions that belonged to a category, so the default paths would look like so:

{% highlight ruby %}
#route
'/categories/:category_id/questions/:id'
#URL
'/categories/1/questions/57'
{% endhighlight %}

The default path isn't very easy on the eyes, so we create custom paths for questions using the unique slugs generated for each category. What is a slug you ask? It is a part of a URL that identifies a page in human readable keywords. In the case of the above example URLs, the ids are the slugs.

Slugs can easily be replaced in your website with a few easy steps.

### *Step 1 - Generate Slugs*

**Note: you will not find the specific example below in my project. We implemented vanity URLs but did not use them for a Category show page.**

The best practice for using vanity URLs with custom slugs is to generate and store them in your database. Custom slugs **must** be unique, otherwise Rails will throw an error. Make sure you slugs are unique with Rails' built in validation.

First, create a migration to add a slug column with a string datatype to the relevant model.

Next, write a method that will convert the unique name or identifier into a string that can be interpolated into a URL. URLs do not support spaces and by convention, spaces are usually replaced by dashes. To use an example from my project:

{% highlight ruby linenos %}
class Category < ApplicationRecord
  has_many :questions
  validates :slug, uniqueness: true

  def create_slug
    name.downcase.gsub(" ", "-")
  end
end
{% endhighlight %}

### *Step 2 - Save Slugs to Database*

Next, you must add logic to ensure that a slug is generated and updated anytime a row is updated or added to the database:

{% highlight ruby linenos %}
class Category < ApplicationRecord
  has_many :questions
  after_create :update_slug
  before_update :assign_slug
  validates :slug, uniqueness: true

  def create_slug
    name.downcase.gsub(" ", "-")
  end

  def update_slug
    update_attributes slug: assign_slug
  end

  private

  def assign_slug
    self.slug = create_slug
  end
end
{% endhighlight %}

The above logic ensures that anytime .save or .update is called on an instance of the Category class, the slug column is updated as well. If you are adding custom slugs to an existing rails project, you can loop through all of the rows and update the slugs now in the console by calling .save on each instance. Otherwise, every time a new row is added to the database, the slug will be automatically generated and saved.

The final method you must define in the model is .to_param. This method is present in every model inheriting from active record. Is returns the string of the id for an instance of the class like so:

{% highlight ruby %}
  def to_param
    self.id.to_s
  end
{% endhighlight %}

This method is called whenever rails has to interpolate the ```:id``` into a route. We can override this functionality by writing our own version of the method alongside our other slug methods:

{% highlight ruby linenos %}
class Category < ApplicationRecord
  has_many :questions
  after_create :update_slug
  before_update :assign_slug
  validates :slug, uniqueness: true

  def create_slug
    name.downcase.gsub(" ", "-")
  end

  def update_slug
    update_attributes slug: assign_slug
  end

  def to_param
    #return the string of the slug stored in our database
    self.slug
  end

  private

  def assign_slug
    self.slug = create_slug
  end
end
{% endhighlight %}

Now whenever rails needs to pass an :id in the URL for category, it will pass the slug attribute rather than the id attribute. In other words, normally ```params[:id] = self.id```. Now it ```params[:id] = self.slug```.


### *Step 3 - Hook Slugs Up to the Controller(s)*

Now that our slugs have been created and saved in our database, we can move on to adding the functionality to get them to work in our views and controllers. To do this, you will need to use the built in .find_by_slug method in your controller:

{% highlight ruby %}
class CategoriesController < ApplicationController
  def index
    @categories = Category.all
  end

  def show
    @category = Category.find_by_slug(params[:id])
  end
end
{% endhighlight %}

Note that you do not have to do anything special to the routes since rails now will use the slug in place of the id in all routes where we overrode the ```.to_param``` method.

**Success:**
![VanityURL]({{"/assets/02-2018-vanity-slugs/success-shot.png" | absolute_url }})

Notice that the link_to path on the Categories ```index.html.erb``` is the same if you had a normal show route:

{% highlight html %}
  <li><%= link_to category.name, category %></li>
{% endhighlight %}

## Passing Custom Params to Controllers

In our Rails app, my partner and I needed to solve the challenge of selecting a random question from our database when the user pressed the Play link in our navbar. We implemented this functionality by overriding another Rails default: the ```link_to``` method. This method automatically generates a link tag in HTML with two require parameters, the link text and the link target. In many cases, Rails developers will use the default behavior of ```link_to``` by passing a route helper method to go to a show page like so: ```<%= link_to 'Link Title', sample_path(@sample) %>```.

However, we needed to pass a custom param through ```link_to``` to get a random question page. Rails allows developers to pass custom params to your controller like so:

```
 link_to "Link Title", sample_path(param1 => value1, param2 => value2)
```

 In the case of our project, every time a user pressed the Play button, we randomly generated a category for the question using ```.rand_slug``` that would then be passed to our questions controller:

{% highlight html %}
<li>
  <%= link_to "Play", controller: "questions", action: "show", id: rand_slug %>
</li>
{% endhighlight %}
<!-- ![HomePage]({{"/assets/02-2018-vanity-slugs/home-page.png" | absolute_url }}) -->
Make sure you set the ```controller:``` and ```action:``` parameters as well to ensure that your custom link_to goes to the correct controller and route.

Our controller handled this parameter with another custom method to pull a question for the user out of the database:

{% highlight ruby %}
class QuestionsController < ApplicationController
  def show
    @question = select_unanswered_question_by_category(params[:id])
    @comments = @question.comments
  end
end
{% endhighlight %}

Which would then display the random question:

![RandomQuestion]({{"/assets/02-2018-vanity-slugs/random-question.png" | absolute_url }})

I hope the two topics discussed in this blog can be helpful for any budding Rails developer. Both solutions to these unique problems we encountered for our project definitely pushed us to explore some of the many customization options Rails has. If you need something unique in your project that is not handled by the default Rails settings, I guarantee there is a way to override it. Don't stop looking!
