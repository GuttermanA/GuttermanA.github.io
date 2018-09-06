---
layout: post
title:  "Binary Search in JavaScript"
date:   2018-09-05 20:30:00
categories: JavaScript, Computer Science, Algorithms, Search, Big O
published: true
future: false
---

Hello everyone. I know in my last post I said I would start my journey through data structures in JavaScript. Instead, I decided to take a slight detour into search algorithms. I had a live code challenge through HackerRank where the solution required an implementation of binary search. So, while it is fresh in my mind, I thought I would take everyone through this awesome search algorithm.

## An Introduction

If you have an familiarity with Binary Search Trees, you may already be familiar with the underlying concepts that drive the efficiency of binary search. Binary Search Trees work on the same logic that binary search works on: their efficiency lies in the fact that each iteration of the search or each level of the tree eliminates half of the possible results. The algorithm's average time complexity (and the Binary Search Tree's) is O(log n), which is on the very good side of Big O. You can only do better with constant time, O(1), which means that the action takes the same amount of time, no matter the size of the dataset.

I think this is a good opportunity to understand what O(log n) is and why its so good in the world of algorithms and data structures. At base level, you can understand that most algorithms that halves the dataset on each iteration to be O(log n). Essentially, a logarithmic scale expresses the exponent to which another fixed number must be raised to produce a number. If we take a very simple example, like how many times it takes 16 to be divided by 2 until we reach one, we can see O(log n) in action.

```
N = 16
N 8 /* divide by 2 */ COUNT = 1
N 4 /* divide by 2 */ COUNT = 2
N 2 /* divide by 2 */ COUNT = 3
N 1 I* divide by 2 */ COUNT = 4
```

In this case it takes 4 times, which can also be expressed **log<sub>2</sub>16 = 4**, which is equivalent to this algorithm having a time complexity of O(log n), where in this case n = 16.

The book, Cracking the Coding Interview by Gayle Laakmaan McDowell gives an excellent breakdown of how O(log n) works practically if you want more Big O.

## The Algorithm

To start, I will present the completed algorithm. Then I will take you through each step of it and breakdown what's going on.

{% highlight JavaScript linenos %}
function binarySearch(array, value) {

  if(!isSorted(array)) {
    throw new Error('Array is unsorted')
  }

  let start = 0
  let end = array.length - 1
  let middle = Math.floor((start + end) / 2)

  while(array[middle] !== value && start < end) {
    if (value > array[middle]) {
      start = middle + 1
    } else {
      end = middle - 1
    }

    middle = Math.floor((start + end) / 2)
  }


  if(array[middle] !== value) {
    return 'Value not found'
  }

  return middle
}
{% endhighlight %}

To start understand, what is happening on lines 3 to 5:

{% highlight JavaScript %}
if(!isSorted(array)) {
   throw new Error('Array is unsorted')
 }
{% endhighlight %}

The above block is a helper function that simply returns true if the array is sorted is ascending order or false if it is not. The code for this helper function can be easily found with a quick Google search. A binary search requires a sorted array to work. Why is this? Its because the action of the algorithm continuously reduces the size of the subset of the array being examined. Binary search functions by finding the middle index of a sorted array and then checking if the value to be found is equal, greater than, or less than the middle value. If it is equal, then the algorithm ends and middle index is returned. Otherwise, if it is less than the middle index value, search the left side of the array, starting at index 0 to the middle index. If it is greater than the middle index value, search the left side of the array, starting at the middle index to the end of the array. At each iteration the algorithm runs, the middle index is recalculated based on the starting index and ending index of the subset of the given array.

So, to continue, after checking if the array is sorted find the start index, the end index, and the middle index of the array:

{% highlight JavaScript %}
let start = 0
let end = array.length - 1
let middle = Math.floor((start + end) / 2)
{% endhighlight %}

At the first iteration of the algorithm, the start index is always 0 and the end index is always the length of the array - 1. The middle index is the average of this two numbers. Use ```Math.floor``` to ensure you always get a whole number for your middle index.

Once you have your start, end, and middle you can move to the meat of the algorithm:

{% highlight JavaScript linenos%}
while(array[middle] !== value && start < end) {
  if (value > array[middle]) {
    start = middle + 1
  } else {
    end = middle - 1
  }
  middle = Math.floor((start + end) / 2)
}
{% endhighlight %}

Line 1 is the conditions of the while loop. They state that as long as the middle value does not equal the value to find and that the starting index is less than the ending index, execute the loop.

Lines 2 to 6 contain the logic to iterate through the array using the binary search logic. If the value is greater than the middle, the algorithm should look at the 'right' side of the array, so we set start to the middle index + 1. Otherwise, if the value is less than the middle index value, the end should be set to middle - 1. This is where the algorithm gets its O(log n) time complexity. Each iteration produces a smaller slice of the array to examine in the subsequent iteration.

Line 7 contains the logic to recalculate the middle index of the new array subset. In this case, we use the same logic, which is the average of the starting and ending index.

When the while loop ends, we move to the final part of the algorithm:

{% highlight JavaScript%}
if(array[middle] !== value) {
  return 'Value not found'
}
return middle
{% endhighlight %}

This final piece of logic is checking if the current middle is equal to the value to be found. If it isn't return an error message. Otherwise, return the current middle index.

That's it for this week. I hope you have seen the power of binary search. An O(log n) time complexity is an excellent thing to have for your search algorithm. The only thing better is having an O(1) time complexity, which is impossible for any average or worse time complexity for an algorithm. If you have a sorted dataset, use binary search!

See below for a repository implementing binary search, other search functions, and other sorting functions in JavaScript.

* [JavaScript Sorting and Search Algorithms](https://github.com/GuttermanA/JavaScript-sorting-algorithms)
