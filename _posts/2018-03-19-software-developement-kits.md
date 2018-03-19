---
layout: post
title:  "Software Development Kits (SDKs)"
date:   2018-03-19 08:15:00
categories: SDKs, APIs, Javacript
published: true
future: true
---

Today I am going to give a general overview of Software Development Kits (SDKs). SDKs are the more developed cousins of APIs. An API is an interface that allows software to interact with other software. They are mainly used as ways to get and store data from an application. An API has certain URL endpoints and commands that allow a developer to interact with an applications data.

An SDK goes a step further and provides developers both with the functionality of an API and tools they can use to build their app for a specific platform. A good analogy for an SDK is a model car kit. You both need the parts in the kit and specialized tools to build the model car. The SDK can be seen as the parts and the tools wrapped into a single package.

### Facebook APIs and SDKs as Examples

Facebook has many examples of fully featured APIs and SDKs. One of their most popular is the Facebook API. Essentially, the API allows you to set up targeted adds for your company by querying Facebook for the multitude of data-points that Facebook collects on its user. The API is set up to allow easy interface between Facebook user data and your own custom built ad application.

On the other hand, Facebook's SDKs are expressly designed to develop applications with Facebook integration. Facebook provides several SDKs to develop on different platforms: iOS, Android, and Javascript for web applications. These SDKs come packaged with libraries and code snippets that allow the easy integration of Facebook functionality into your website or mobile application. Common functionality that the SDKs allow you to implement is login, sharing, and posting comments to Facebook.


### An example of a (simple) SDK

While it would have been wonderful to give a demo on how to integrate Facebook login into your own web application, it falls outside of the scope of this blog post. To get the functionality working, you need to register your existing app domain with Facebook on their developer website and setup the SDK in your Javascript and HTML. Since I do not have a completed project that the SDK could be easily integrated into, I decided to show off a different and much simpler SDK in the following section. If you are interested in integrating Facebook functionality into your own web application the documentation is excellent and can be found [here](https://developers.facebook.com/docs/javascript).

**Moving onto...**

**The Magic the Gathering (MTG) SDKs!**

I know you are all excited to learn that someone built an excellent API for search a database of nearly 20,000 cards.

Anyway, ignoring the possibly offensive subject matter to some people, I believe the SDKs built around this API are good examples of simple and functional SDKs.

While it may be fun and cool to build out all of your own fetch requests in your MTG application, the SDK makes this redundant. Built into this SDK are all of the methods you would use to make get requests against the API.

The Javascript SDK is a basic library that gives you a simple programmatic way to query the API without having to write your own fetch requests.

For example, I wrote my own generate search function in an earlier project using this function:

{% highlight javascript %}
generateSearchParams() {
  let params = {}
  for(let input of this.allFieldInputs) {
    if (input.value) {
      params[input.name] = input.value
    }
  }
  if (this.cardTypeList.selectedOptions[0].value !== "") {
    params[this.cardTypeList.name] = this.cardTypeList.selectedOptions[0].value
  }
  let esc = encodeURIComponent;
  let query = Object.keys(params)
      .map(k => esc(k) + '=' + esc(params[k]))
      .join('&');
  return query
}
{% endhighlight %}

This function would output a string like: ```cards?card%5Bcmc%5D=2&card%5Bcolor_identity%5D=WR``` to be attached to the fetch request against my Rails API loaded with card data.

With the Javascript SDK, I would have not had to do any of this. Querying the API would have been as simple as writing a few lines of code with a search parameters object like so:

{% highlight javascript %}
card.where({ supertypes: 'legendary', subtypes: 'goblin' })
.then(cards => {
    console.log(cards[0].name) // "Squee, Goblin Nabob"
})
{% endhighlight %}

That is the power of an SDK. It is another type of library that, if written well, will allow you to focus on other parts of your application that actually require custom work.

#### A Brief Look Under the Hood ####

I thought it would be interesting to take a look under the hood of the MTG Javascript SDK to see how it worked since it is built on a functional programming paradigm. Once you clone the repository from [here](https://github.com/MagicTheGathering/mtg-sdk-javascript), you can see that all of the magic happens in the ```querybuilder.js``` file. Lets break it down:

#### 1. Importing Required Libraries: ####
{% highlight javascript %}

//HTTP Request Library
var request = require('request-promise');

//File that contains the API endpoint
var config = require('./config.js');

//Ramda is a toolkit library for functional programming
var _require = require('ramda'),
    curryN = _require.curryN,
    merge = _require.merge,
    prop = _require.prop;

//Emitter20 allows you to create custom events outside of basic browser events
var Emitter = require('emitter20');
{% endhighlight %}

#### 2. Set up the Private Get Request Function ####

{% highlight javascript %}
//This function will be used is all subsequent functions to make a request against the API
var get = curryN(3, function (type, page, args) {
  return request({
    uri: config.endpoint + '/' + type,
    qs: merge(args, {
      page: page
    }),
    json: true
  }).then(prop(type));
});
{% endhighlight %}

#### 3. Define Public Functions ####

This comes in multiple parts:

**A. Wrap functions in export object to make them public:**

{% highlight javascript %}
module.exports = function (type) {

  return {

{% endhighlight %}

**B. Define functions**

{% highlight javascript %}
    // Gets a resource by its id.
    find: function find(id) {
      return request({
        uri: config.endpoint + '/' + type + '/' + id,
        json: true
      });
    },

    // Gets a resource with a given query.
    where: get(type, 0),

    /** Gets a resource with a given query (like where), but
        returns an emitter that emits 3 events:
        - data(card): emits a card when it is retrieved from the API
        - error(err): emits an error if the request fails
        - end(): called when all results have been retrieved
    */
    all: function all(args) {
      var emitter = new Emitter();
      var getEmit = function getEmit(type, page, args) {
        return get(type, page, args).then(function (items) {
          if (items.length > 0) {
            items.forEach(function (c) {
              return emitter.trigger('data', c);
            });
            return getEmit(type, page + 1, args); // RECURSION
          } else {
            emitter.trigger('end');
          }
        }).catch(function (err) {
          return emitter.trigger('error', err);
        });
      };
      getEmit(type, 1, args);

      return emitter;
    }

  };
};
{% endhighlight %}

To wrap up, when you ```const mtg = require('mtgsdk')``` and then call ```mtg.all```, ```mtg.where```, or ```mtg.find``` you are invoking the functions found in ```querybuilder.js``` which is merely an interface for interacting with the API. If anyone is interested in the MTG API you can find it [here](https://magicthegathering.io/) and the Javascript SDK can be found [here](https://github.com/MagicTheGathering/mtg-sdk-javascript).
