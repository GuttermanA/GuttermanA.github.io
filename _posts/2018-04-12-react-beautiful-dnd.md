---
layout: post
title:  "Getting Started with the React Beautiful Drag and Drop Library"
date:   2018-04-12 08:15:00
categories: React, React Beautiful Drag and Drop, Drag and Drop, JavaScript
published: true
future: true
---
Today I am going to discuss setting up the React Beautiful Drag and Drop library. I used this library in my first React project. As disclaimed in the documentation, this drag and drop is only for ordered lists. While it was a pain to setup, once it was working it worked well for its intended purpose. However, the same cannot be said of the documentation, which does not contain enough examples to make it easy to use. As a result, me and my partner struggled for an entire day to implement drag and drop in our project.

Example:
<iframe width="560" height="315" src="https://www.youtube.com/embed/IWeg53ZRv7s" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

### Setup

As with any JavaScript library, you need to add it as a dependency to your project with ```yarn add react-beautiful-dnd``` or ```npm add react-beautiful-dnd --save```. To create a simple drag and drop, there are 3 main Components to this library:

* DragDropContext
* Droppable
* Draggable

#### DragDropContext Component ####

For this library to work, all of the react components where drag and drop will be implemented need to be wrapped in a DragDropContext. It may be easiest to just wrap your entire app with the component to ensure you have the functionality anywhere you need it. For DragDropContext to function correctly, it requires a callback to be passed to an onDragEnd event.

```
<DragDropContext onDragStart={this.onDragStart} onDragUpdate={this.onDragUpdate} onDragEnd={this.onDragEnd}>
CONTENT
</DragDropContext>
```

onDragEnd is where the state of the list will be updated, whether an item is added, removed, or rearranged in this list. Optionally, you can also add callbacks for the onDragStart and onDragUpdate events. For my simple example, these were not required.

#### Droppable Component ####

Next, you will have to set up your Droppable area inside of your DragDropContext. Droppable will wrap your Draggable components and give them a place on the DOM where they can be rearranged and dropped into.

```
<Droppable droppableId="search-results" type="MOVIE" isDropDisabled>
    {(provided, snapshot) => (
      <div
        ref={provided.innerRef}
        style={getListStyle(snapshot.isDraggingOver)}
        {...provided.droppableProps}
        {...provided.dragHandleProps}
      >
        <Card.Group itemsPerRow={4}>
          {movies}
        {provided.placeholder}
      </Card.Group>
      </div>
    )}
</Droppable>
```

Droppable has 3 main props you should be aware of: droppableId, type, and isDropDisabled.

droppableId is the name of the Component. You can reference this inside of you DragDropContext callbacks. Type is a classification for the component. Only Droppable and Draggable components of the same type can interact with each other. isDropDisabled is a boolean prop that allows you to disable dropping into the component.

Droppable must also contain a callback that returns a <div> with all of the props, except in the above code snippet. In the example above, the style prop contains a callback that changes the styling when a Draggable is dragged into the component.

#### Draggable Component ####

The Draggable is the component that a user can actually drag and drop on the page. This contains any JSX to style the component wrapped inside of a Draggable component, similar to the Droppable component.

```
<Draggable draggableId={props.id} type="MOVIE" index={props.index}>
  {(provided, snapshot) => (
    <div>
      <div
        ref={provided.innerRef}
        {...provided.draggableProps}
        {...provided.dragHandleProps}
      >
      <Card onClick={handleClick} style={{maxWidth: 'none'}}>
        <Image src={poster} />
        { props.fromWhere !== "MovieList" ? <Icon name='delete' inverted size="large" circular onClick={handleDelete}/> : null}

      </Card>
    </div>
    {provided.placeholder}
  </div>
  )}
</Draggable>
```

Similar to the Droppable, the Draggable has a draggableId and a type. Both of these function the same way as they do in the Droppable: draggableId can be refernced in your dragging callbacks and type allows you to define which Droppables the Draggable can be placed into. Additionally, the Draggable needs an index prop so you can update your state correctly in your onDragEnd callback.

As shown in the snippet above, the Droppable must contain a function that returns a <div> that wraps another <div> and a placeholder. The placeholder allows for other items in the Droppable to move out of the way of the Draggable as it moves. The inner <div> is similar to the Droppable <div>, requiring all of the props listed in the snippet. This <div> then wraps the JSX to display as the droppable.

### Putting it All Together

Your final setup should look something like this:

```
<DragDropContext onDragStart={this.onDragStart} onDragUpdate={this.onDragUpdate} onDragEnd={this.onDragEnd}>
  <Droppable droppableId="search-results" type="MOVIE" isDropDisabled>
      {(provided, snapshot) => (
        <div
          ref={provided.innerRef}
          style={getListStyle(snapshot.isDraggingOver)}
          {...provided.droppableProps}
          {...provided.dragHandleProps}
        >
          <Card.Group itemsPerRow={4}>
            <Draggable draggableId={props.id} type="MOVIE" index={props.index}>
              {(provided, snapshot) => (
                <div>
                  <div
                    ref={provided.innerRef}
                    {...provided.draggableProps}
                    {...provided.dragHandleProps}
                  >
                  <Card onClick={handleClick} style={{maxWidth: 'none'}}>
                    <Image src={poster} />
                    { props.fromWhere !== "MovieList" ? <Icon name='delete' inverted size="large" circular onClick={handleDelete}/> : null}

                  </Card>
                </div>
                {provided.placeholder}
              </div>
              )}
            </Draggable>
            {provided.placeholder}
        </Card.Group>
        </div>
      )}
  </Droppable>
</DragDropContext>
```

The final piece that makes everything work is your onDragEnd callback. This is where all of your logic goes dictating how your drag and drop React components interact with each other.

See below for a commented snippet.

```
onDragEnd = result => {

  // Prevents breaking when the Draggable does not end in a valid Droppable
  if (!result.destination && result.source.droppableId === "search-results") {
    return;
  }

  // Checks the type of Droppable
  if (result.source.droppableId === "list") {
    //Logic to remove from list if Draggable is dropped
    //outside of a valid Draggable
    if (result.destination === null) {
      let foundMovie = this.props.movies.find(
        movie => movie.id === parseInt(result.draggableId.split("-")[1])
      );
      this.props.removeFromList(foundMovie);
      return;
    }

    // Function that reorders list by taking in array, the Draggable start
    //index and end index
    const favoriteList = reorder(
      this.props.favoriteList,
      result.source.index,
      result.destination.index
    );

    // Update state with reordered list
    this.props.updateFavoriteList(favoriteList);
  }
};
```

I hope this breakdown can be of help to anyone to start there way on using the React Beautiful DND library. Project example and documentation will be linked below.

### Resources

[Documentation](https://github.com/atlassian/react-beautiful-dnd)

[Project with example code](https://github.com/GuttermanA/favorite-lister)
