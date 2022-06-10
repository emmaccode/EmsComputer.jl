# Interface.jl
"""
**Interface**
### properties!(::Servable, ::Servable) -> _
------------------
Copies properties from s,properties into c.properties.
#### example

"""
properties!(c::Servable, s::Servable) = merge!(c.properties, s.properties)

"""
**Interface**
### push!(::Component, ::Component ...) -> ::Component
------------------

#### example

"""
push!(s::Component, d::Component ...) = [push!(s[:children], c) for c in d]

"""
**Interface**
### push!(::Component, ::Component) ->
------------------

#### example

"""
push!(s::Component, d::Component) = push!(s[:children], d)

"""
**Interface**
### getindex(::Servable, ::Symbol) -> ::Any
------------------
Returns a property value by symbol or name.
#### example

"""
getindex(s::Servable, symb::Symbol) = s.properties[symb]

"""
**Interface**
### getindex(::Servable, ::String) -> ::Any
------------------
Returns a property value by string or name.
#### example

"""
getindex(s::Servable, symb::String) = s.properties[symb]

"""
**Interface**
### setindex!(::Servable, ::Symbol, ::Any) -> ::Any
------------------
Sets the property represented by the symbol to the provided value.
#### example

"""
setindex!(s::Servable, a::Any, symb::Symbol) = s.properties[symb] = a

"""
**Interface**
### setindex!(::Servable, ::String, ::Any) -> ::Any
------------------
Sets the property represented by the string to the provided value.
#### example

"""
setindex!(s::Servable, a::Any, symb::String) = s.properties[symb] = a

#==
Styles
==#
"""
**Interface**
### animate!(::StyleComponent, ::Animation) -> _
------------------
Sets the Animation as a rule for the StyleComponent. Note that the
    Animation still needs to be written to the same Connection, preferably in
    a StyleSheet.
#### example

"""
function animate!(s::StyleComponent, a::Animation)
    s["animation-name"] = string(a.name)
    s["animation-duration"] = string(a.length) * "s"
    if a.iterations == 0
        s["animation-iteration-count"] = "infinite"
    else
        s["animation-iteration-count"] = string(a.iterations)
    end
end

"""
**Interface**
### style!(::Servable, ::Style) -> _
------------------
Applies the style to a servable.
#### example

"""
style!(c::Servable, s::Style) = begin
    if contains(s.name, ".")
        c.properties[:class] = string(split(s.name, ".")[2])
    else
        c.properties[:class] = s.name
    end
end

"""
**Interface**
### style!(::Style, ::Style) -> _
------------------
Copies the properties from the second style into the first style.
#### example

"""
style!(s::Style, s2::Style) = merge!(s.properties, s2.properties)

"""
**Interface**
### delete_keyframe!(::Animation, ::String) -> _
------------------
Deletes a given keyframe from an animation by keyframe name.
#### example

"""
function delete_keyframe!(s::Animation, key::String)
    delete!(s.keyframes, key)
end

"""
**Interface**
### setindex!(::Animation, ::Pair, ::Int64) -> _
------------------
Sets the animation at the percentage of the Int64 to modify the properties of
pair.
#### example

"""
function setindex!(anim::Animation, set::Pair, n::Int64)
    prop = string(set[1])
    value = string(set[2])
    n = string(n)
    if n in keys(anim.keyframes)
        anim.keyframes[n] = anim.keyframes[n] * "$prop: $value;"
    else
        push!(anim.keyframes, "$n%" => "$prop: $value; ")
    end
end

"""
**Interface**
### setindex!(::Animation, ::Pair, ::Int64) -> _
------------------
Sets the animation at the corresponding key-word's position.
#### example

"""
function setindex!(anim::Animation, set::Pair, n::Symbol)
    prop = string(set[1])
    value = string(set[2])
    n = string(n)
    if n in keys(anim.keyframes)
        anim.keyframes[n] = anim.keyframes[n] * "$prop: $value; "
    else
        push!(anim.keyframes, "$n" => "$prop: $value; ")
    end
end

"""
**Interface**
### push!(::Animation, p::Pair) -> _
------------------
Pushes a keyframe pair into an animation.
#### example

"""
push!(anim::Animation, p::Pair) = push!(anim.keyframes, [p[1]] => p[2])

#==
Serving/Routing
==#
"""
**Interface**
### write!(::Connection, ::Servable) -> _
------------------
Writes a Servable's return to a Connection's stream.
#### example

"""
write!(c::Connection, s::Servable) = s.f(c)


"""
**Interface**
### write!(c::Connection, s::Vector{Servable}) -> _
------------------
Writes, in order of element, each Servable inside of a Vector of Servables.
#### example

"""
write!(c::Connection, s::Vector{Component}) = [write!(c, comp) for comp in s]

"""
**Interface**
### write!(::Connection, ::String) -> _
------------------
Writes the String into the Connection as HTML.
#### example

"""
write!(c::Connection, s::String) = write(c.http, s)

"""
**Interface**
### write!(::Connection, ::Any) -> _
------------------
Attempts to write any type to the Connection's stream.
#### example

"""
write!(c::Connection, s::Any) = write(c.http, s)

"""
**Interface**
### startread!(::Connection) -> _
------------------
Resets the seek on the Connection.
#### example

"""
startread!(c::Connection) = startread(c.http)

"""
**Interface**
### route!(::Connection, ::Route) -> _
------------------
Modifies the routes on the Connection.
#### example

"""
route!(c::Connection, route::Route) = push!(c.routes, route.path => route.page)

"""
**Interface**
### unroute!(::Connection, ::String) -> _
------------------
Removes the route with the key equivalent to the String.
#### example

"""
unroute!(c::Connection, r::String) = delete!(c.routes, r)

"""
**Interface**
### route!(::Function, ::Connection, ::String) -> _
------------------
Routes a given String to the Function.
#### example

"""
route!(f::Function, c::Connection, route::String) = push!(c.routes, route => f)

"""
**Interface**
### route(::Function, ::String) -> ::Route
------------------
Creates a route from the Function.
#### example

"""
route(f::Function, route::String) = Route(route, f)::Route

"""
**Interface**
### route(::String, ::Servable) -> ::Route
------------------
Creates a route from a Servable.
#### example

"""
route(route::String, s::Servable) = Route(route, s)::Route

"""
**Interface**
### routes(::Route ...) -> ::Vector{Route}
------------------
Turns routes provided as arguments into a Vector{Route} with indexable routes.
This is useful because this is the type that the ServerTemplate constructor
likes.
#### example

"""
routes(rs::Route ...) = Vector{Route}([r for r in rs])

#==
    Server
==#
"""
**Interface**
### stop!(x::Any) -> _
------------------
An alternate binding for close(x). Stops a server from running.
#### example

"""
function stop!(ws::WebServer)
    close(ws.server)
end

function route!(f::Function, ws::WebServer, r::String)
    ws.routes[r] = f
end

function getindex(ws::WebServer, s::Symbol)
    ws[extensions][s]
end

getindex(c::Connection, s::Symbol) = c.extensions[s]
#==
Request/Args
==#
"""
**Interface**
### getargs(::Connection) -> ::Dict
------------------
The getargs method returns arguments from the HTTP header (GET requests.)
Returns a full dictionary of these values.
#### example

"""
function getargs(c::Connection)
    target::String = split(c.http.message.target, '?')[2]
    target = replace(target, "+" => " ")
    args = split(target, '&')
    arg_dict = Dict()
    for arg in args
        keyarg = split(arg, '=')
        x = tryparse(keyarg[2])
        push!(arg_dict, Symbol(keyarg[1]) => x)
    end
    return(arg_dict)
end

"""
**Interface**
### getargs(::Connection, ::Symbol) -> ::Dict
------------------
Returns the requested arguments from the target.
#### example
"""
function getarg(c::Connection, s::Symbol)
    getargs(c)[s]
end

"""
**Interface**
### getarg(::Connection, ::Symbol, ::Type) -> ::Vector
------------------
This method is the same as getargs(::HTTP.Stream, ::Symbol), however types are
parsed as type T(). Note that "Cannot convert..." errors are possible with this
method.
#### example
"""
function getarg(c::Connection, s::Symbol, T::Type)
    parse(getargs(http)[s], T)
end

"""
**Interface**
### postarg(::Connection, ::Symbol) -> ::Any
------------------
Get a body argument of a POST response by name.
#### example

"""
function postarg(c::Connection, s::Symbol)

end

"""
**Interface**
### postarg(::Connection, ::Symbol, ::Type) -> ::Any
------------------
Get a body argument of a POST response by name. Will be parsed into the
provided type.
#### example

"""
function postarg(c::Connection, s::Symbol, T::Type)

end

"""
**Interface**
### postargs(::Connection, ::Symbol, ::Type) -> ::Dict
------------------
Get arguments from the request body.
#### example

"""
function postargs(c::Connection)
    http.message.body
end

"""
**Interface**
### get() -> ::Dict
------------------
Quick binding for an HTTP GET request.
#### example

"""
function get(url::String)

end

"""
**Interface**
### post() ->
------------------
Quick binding for an HTTP POST request.
#### example

"""
function post(url::String)

end

"""
**Interface**
### download!() ->
------------------
Downloads a file to a given user's computer.
#### example
"""
function download!(c::Connection, uri::String)

end

"""
**Interface**
### navigate!(::Connection, ::String) -> _
------------------
Routes a connected stream to a given URL.
#### example

"""
function navigate!(c::Connection, url::String)
    HTTP.get(url, response_stream = c.http, status_exception = false)
end
