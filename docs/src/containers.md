# Containers

## Root Element
In matplotlib we have the container structure Figure -> Axes, where you can draw on the
Figure, or the Axes (which can be more than one). I think there can be only one Figure, that
is, it is the root of all other graphics.

So we have the following names for the root object:

* SVG: svg
* Matplotlib/PlotlyJS: Figure
* Mathematica: Graphics
* Vega.js: scene (I think, it seems largely implicit)
* Compose: Context
* Grid: viewport (the default one made that covers the entire device)

I am tempted to use `Canvas` as it feels the most general (though `Graphics` also seems
decent, I just don't love the plural nature of it. I think it is worth distinguishing
the root versus having a Graphics contain other Graphics, but I maybe the later is better).

## Axes
Now the real key is the container that has coordinate information (or data co-ordinates,
versus "device" co-ordinates of the root item).

Names from other packages

* SVG: no built in, the viewBox attribute can make different linear scales I think
* Matplotlib: Axes
* Mathematica: I am not sure how it works, as I think each nested Graphics will have
relative coordinates and alignment
* Vega.js: axes + scales (I think they interact)
* Compose: Form
* Grid: viewport, plotViewport, dataViewport (where the later two are styled versions of
    the first. I like this way of doing it.)

It seems to me that Matplotlibs Axes can act like Grid's viewports, that is they can
overlap. I am not sure how the nested coordinates are handled. I imagine it would be like
Grid and depend on if the Axes is added to another Axes or the top level Figure.

So axes seems pretty common. For some reason I don't love the name. I think of the axes as
being the a synonym for the "spines" or "scales", the visual representation of the
co-ordinates not the container. This seems to be the view taken by Grid, which uses axes
to mean the spines as well. Maybe I use Viewport, it has a nice feel to it. And even though
it might be a little confusing with the concept from SVG, as there is not conflicting
attribute name in the SVG spec I think I am fine.

## Conclusions
I will have the hierarchy root(Canvas) -many-> leaf(Viewport) -many-> leaf(Viewport). If no
Viewport is given in the Canvas item list, then a default one will be created. I can then
have a Grid container that will do what Matplotlib does with a GridSpec, which will contain
a Grid of aligned Viewport's.

It really is not natural to do nested Viewport's using Matplotlib axes. I also notice that
Mathematica doesn't really do nested Viewport like sets either, and has a much flatter
coordinate hierarchy like Matplotlib does. I am going to do this instead as the fully
general solution is hard to get right and I would rather work on the high level convenience
methods. Hopefully this doesn't bite me in the ass later.

So given that I am going to replicate the Matplotlib model and have
root(Canvas) -many-> leaf(Viewport) I need to think about how I add the Viewport's to a
canvas.

Strictly I should do:
```julia
Canvas([Viewport[]...])
# for a grid of Viewports?
Canvas(grid([Viewport[], ..., Viewport[]], layout=GridLayout()))
# This is very explicit, but I lose the common case of having, for a default viewport
Canvas([Grobs...])
# maybe I have the methods
Canvas(::AbstractArray{Grob}) # create default viewport
Canvas(::AbstractArray{Viewport}) # use explicit viewports
```

## Naming
Something I am struggline with is what to do about the naming of my types. Clearly they to
be like they are, but to create them should I be using the inner constructors or special
methods?
```julia
canvas([viewport()])
canvas(gridview())
```
The lowercase feels more correct. But then you think about types like `DataFrames` and
`Dict` and they are created using the type constructors. The issue arrises for when I want
some convience setups for things like `ViewPort`, if I want a version with the axes on
`AxesView`, but really this is just a `ViewPort` with different attributes. So should I call
this `axesview()`? In some ways this is related to things like `zeros()` which return
special kinds of `Array` types.

From the mailing list it seems that current naming (studly caps) is the correct way. I will
continue trying to build the api using the current vision. Though I will still have the
problem of

## Styling

* SVG: style, and element parameters, CSS
* Matplotlib: rcParams, kwargs
* Mathematica: Directive, kwargs
* Compose: Parameters
* Grid: gpar (Graphical Parameters)
