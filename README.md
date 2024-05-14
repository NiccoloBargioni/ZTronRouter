# ZTronRouter 

ZTronRouter is part of the ZombieTron/Core packages suite. It provides an efficient, well documented and tested path-based routing functionality backed by a trie. It is inspired on [frzi/SwiftUI-router](https://github.com/frzi/swiftui-router) and [vapor/routing-kit](https://github.com/vapor/routing-kit).

ZTronRouter adds on top of the existing API a large set of methods to iterate through trie nodes and existing paths in the router, inspired to methods defined on Swift Collections. 

## Implementation details

This implementation uses `">"` as root symbol, meaning that a path whose first component is `>` represents an absolute path, otherwise, it represents a relative path. Navigating to an absolute path replaces the current path, while navigating to a relative path adds to it.
Every `init` route initializes the internal `Navigator` with such root symbol, that can't be changed.

## Usage

A `ZTronRouter` accepts three generic types: `RouterInfo`, `RouterOutput`, `RouteParameter`. 

`RouterInfo` is meant to represent an object whose responsibility is to maintain informations about the router as a whole. `RouterOutput` is the type of the objects associated to routes in the ZTronRouter. Each route also has an optional `RouteParameter` parameter associated to it. 

In case that `RouterInfo` and `RouteParameter` are un-needed, an `Empty` type is defined to be used in this case.


Once a new `ZTronRouter` was created, a new route can be added (registered) using the method `.register(_: RouterOutput, at: ZTronNavigator.PathComponents, withParameter: RouteParameter? = nil)` on the router object. If an output was already associated with the specified route, the old output gets overwritten with the new one, as well as the routing parameters, and a message will be logged on the console.

The output of the router for the current path can be accessed using the computed property `output: RouterOutput?` on the router object. Otherwise, to retreive the output at a path different than the current one, you can use the method `.peek(at path: ZTronNavigator.PathComponents) -> RouterOutput?`. Routing parameters associated with a path can be retreived using the method `.getParameter(for route: ZTronNavigator.PathComponents) -> RouteParameter?`.

The current route of the `ZTronRouter` can be changed to `path` using `.navigate(_ path: ZTronNavigator.PathComponents, replace: Bool = false)`. When `replace == true`, the last element in the history stack will be replaced with the new path, otherwise the new path will be pushed onto it. 

The methods for iterating through neighbours and registered paths in general are defined in two ways: one such that their closure passes navigation parameters as well, and one that doesn't. 

If two routers are equipped with the same set of registered paths, they can be `zip`ed to generate a new `ZTronRouter` with the same registered routes as the two zipped routers, with outputs and parameters mapped as specified by `transformOutput` and `transformParameters` parameters.

If two routers have at least one registered path and share the same root symbol, they can be `merge`d, creating a new router whose routes are the set union of that of the two operands, mapping outputs and parameters as the user of this package sees fit, via `transformOutput` and `transformParameters`.


`ZTronRouter` is an observable object, whose `objectWillChange` notification is triggered every time a navigation action is performed, that is: `.navigate()`, `.goBack(_:)`, `.goForward(_:)`, `.clear()` are invoked, the forward and history stack change, or `lastAction` changes. 
