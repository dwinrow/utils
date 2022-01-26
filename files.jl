#using ZipFile

"""
    readdirext(location;filterstring=nothing,subdirectories=false,filesonly=false)

Extends the readdir() function to allow filtering and including subdirectories, or filesonly

See also: readdir
"""
function readdirext(location;filterstring=nothing,subdirectories=false,filesonly=false, join=false)
    list = readdir(location,join=join)
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


function renamefiles(directory,regex,substring)
    files = readdir(directory,join = true)
    dirs = filter(x->occursin(regex,x),files)
    newdirs = replace.(dirs,regex=>substring)
    for (i,file) in enumerate(dirs)
        mv(file,newdirs[i])
    end
end

renamefiles(
    raw"F:\Boal & Co\Pensions\CORPORATE PENSIONS\Templates, Procedures and Standard Documents\IPP Reporting\Reports",
    r"(\d\d\d\d)(\d\d)(\d\d)",
    s"\1-\2-\3")


replace("20211231",  r"(\d\d\d\d)(\d\d)(\d\d)"=>       s"\1-\2-\3")

