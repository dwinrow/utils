function flattenjson(json)

    if typeof(json) <: AbstractDict
        df = DataFrame(json)
        for (i,col) in enumerate(eachcol(df))
            if typeof(col[1]) <: AbstractVector || typeof(col[1]) <: AbstractDict
                dfa = flattenjson.(col)
                unique(names(dfa))
                for c in dfa  
                    df[!,dfa.name] = col
                end
                df = flatten(df,names(df)[i])
            end
        end
    elseif typeof(json) <: AbstractVector
        vcat(flattenjson.(json)...)
    else
        return json
    end

    df

end
str_json = """
{
    "org": "SpaceX",
    "id": 123,
    "equipment": [
        {
            "launcher": "Falcon 1",
            "max_payload": 180
        },
        {
            "launcher": "Falcon 9",
            "max_payload": 22800
        },
        {
            "launcher": "Falcon Heavy",
            "max_payload": 63800
        }
    ]
}
"""

using JSON, DataFrames

j = JSON.parse(str_json)
x = flattenjson(j) 