---
layout: post
title:  "An Introduction to Data Structures in JavaScript"
date:   2018-08-23 16:15:00
categories: JavaScript, Computer Science, Data Structures
published: false
future: false
---

Hello everyone. Back again after another long hiatus. I have been buried in trying to find a job this summer. It has been a long and intense road so far, but I have already learned a lot in my post boot camp life. One of the things I have been learning are the computer science fundamentals many larger companies require you to know to be successful in their technical interviews. I interviewed at the beginning of August. It was very intense, and while I was ultimately rejected, I found all of the time I devoted to learning data structures and algorithms to be incredibly valuable. Anyone who has graduated from a boot camp should take the time to learn the concepts I am going to discuss in my next several posts. Even if an opportunity does not require you to know these concepts to interview with them, if you ever want to interview at a larger tech company like Google, Microsoft, or Facebook, you are going to need to be familiar with the many type of data structures and sorting algorithms found across the computing world.

Today I am going to give a basic overview of the most common data structures that anyone working in programming should know. In the future, I will try to write some posts delving into implementing these in JavaScript. A lot of the most common resources out there for this topic are in languages like Python, Java, or even C++ so I thought it would be valuable to go over these concepts for web developers that may not be familiar with those languages.

To begin, a list of all of the basic data structures that may appear on a coding interview are in no particular order:

* tree
* heap
* trie
* linked list
* graph
* hash table
* queue
* stack


Before I dive into a brief description of each, concepts you must have a basic understanding of is Big-O time and space complexities. An excellent overview of these concepts can be found in the book [Cracking the Coding Interview](https://www.amazon.com/Cracking-Coding-Interview-Programming-Questions/dp/0984782850/ref=sr_1_1?ie=UTF8&qid=1534886681&sr=8-1&keywords=cracking+the+coding+interview). The book is also floating around for free illegally on-line, but I won't link to a place to download here. An reference for Big-O is the [Big-O Cheat Sheet](http://bigocheatsheet.com/).

## Trees - Binary Search Trees, Heaps, and Tries

From [Wikipedia][1]:
> A tree data structure can be defined recursively (locally) as a collection of nodes (starting at a root node), where each node is a data structure consisting of a value, together with a list of references to nodes (the "children"), with the constraints that no reference is duplicated, and none points to the root.

Trees are useful because they offer faster search, insertion, and deletion then other common ordered data structures, like arrays. The average time complexity to search, insert, or deletion from an unsorted array is O(n), because each action is a function of the size of the array. In the case of a tree, search, insertion, and deletion time complexities are O(log(n)). To understand why this is, lets take a look at one of the most common types of trees: the binary search tree.

### Binary Search Trees

A binary search tree is a tree where it's nodes are sorted so that, starting from the root node, items on the left side of the tree are less than the root and items on the right side of the tree are greater than the root. This holds true for each subsequent level of the tree, with each node having a left child less than itself and a right child greater than itself.

The reason binary search trees are more efficient at search, insertion, and deletion than an unsorted array is that as each level is traversed a question is asked: would the node we are looking for be found in the left or the right subtree? Each time this question is answered, a new level is entered and half of the remaining nodes to be searched are removed. This continuous halving of the set to be searched can be represented by the logarithmic scale. This is how we arrive at the fact that the time complexity of search, insertion, and deletion for trees is O(log(n)).

For example:

![binary search tree](/assets/images/200px-Binary_search_tree.svg.png)

If we are searching for the node 7, the traversal of the tree is as follows:

1. Starting at the root, 8: 7 is less than 8, so continue down the left subtree to 3
2. At 3: 7 is greater than 3, so continue down the right subtree to 6
3. At 6: 7 is greater than 6, so continue down the right subtree to 7
4. 7 is our value, so return node

### Heaps

Heaps are also a tree based data structure that has one primary attribute: they satisfy the heap property.

From [Wikipedia][2]:
>if P is a parent node of C, then the key (the value) of P is either greater than or equal to (in a max heap) or less than or equal to (in a min heap) the key of C. The node at the "top" of the heap (with no parents) is called the root node.

Heaps are also known as priority queues. They have similar strengths to binary search trees in that insert and delete are O(log(n)) time complexity.

For example:

![heap](/assets/images/200px-Max-Heap.svg.png)








[1]: https://en.wikipedia.org/wiki/Tree_(data_structure)
[2]: https://en.wikipedia.org/wiki/Heap_(data_structure)
