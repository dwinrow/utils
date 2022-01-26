using ZipFile

"""
    unzip(zipfilename, directory)

Using ZipFile package, unzip.  This can be used as an alternative to 7zip where it is not installed.
However, this method creates a new file rather than copying the properties of the zipped file.

"""
function unzip(zipfilename, directory)

    r = ZipFile.Reader(zipfilename)
    for f in r.files
        @info "extracting $(f.name)"
        write(joinpath(directory,f.name),read(f,String))
    end
    close(r)
    
end