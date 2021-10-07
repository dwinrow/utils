"""
    readdirext(location;filterstring=nothing,subdirectories=false,filesonly=false)

Extends the readdir() function to allow filtering and including subdirectories, or filesonly

See also: readdir
"""
function readdirext(location;filterstring=nothing,subdirectories=false,filesonly=false)
    list = readdir(location)
    if subdirectories || filesonly
        returnlist = []
        for item in list
            itemloc = joinpath(location, item)
            if isdir(itemloc)
                if subdirectories
                    returnlist = vcat(returnlist,joinpath.(item,readdirext(itemloc,filterstring=filterstring,subdirectories=subdirectories,filesonly=filesonly)))
                end
                if !filesonly
                    push!(returnlist,item)
                end
            else
                push!(returnlist,item)
            end
        end
    else
        returnlist = list
    end
    if !isnothing(filterstring)
        returnlist = filter(x -> occursin(filterstring,x), returnlist)
    end
    returnlist
end