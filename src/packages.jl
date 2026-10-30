using Pkg
using TOML
using LocalRegistry
using UUIDs

packages = ["BoalDatabases","BoalInvestments","Mastertrusts","MastertrustProviders","ProviderAPIs","Zurich","RewardsSMPI"]


function migrateJSONdevpkgs(packages=filter(
        p -> isdir(joinpath(@__DIR__, "dev", p)),
        readdir(joinpath(@__DIR__, "dev"))))
    original_project = Base.active_project()
    try
        for p in packages
            package_path = joinpath(@__DIR__, "dev", p)
            migrateJSON(package_path)
        end
    finally
        if original_project === nothing
            Pkg.activate()
        else
            Pkg.activate(dirname(original_project))
        end
    end
end

function updatepackages(packages)
    for p in packages
        Pkg.activate("dev/$p")
        Pkg.update()
    end
    Pkg.activate(".")
end

function registerpackages(packages=packages; registry_name="Boal")
    regs = Pkg.Registry.reachable_registries()
    reg = filter(r -> r.name == registry_name, regs)
    isempty(reg) && error("Registry '$registry_name' not found.")
    reg = first(reg)

    for p in packages
        Pkg.activate("dev/$p")
        project_path = Base.active_project()
        pkg_path = dirname(project_path)
        project = TOML.parsefile(project_path)
        package_name = project["name"]
        package_uuid = UUID(project["uuid"])
        package_version = VersionNumber(project["version"])

        tree_hash = readchomp(Cmd(["git", "-C", pkg_path, "rev-parse", "HEAD^{tree}"]))

        if haskey(reg.pkgs, package_uuid)
            pkgmeta = reg.pkgs[package_uuid]
            versions_path = joinpath(reg.path, pkgmeta.path, "Versions.toml")
            versions = TOML.parsefile(versions_path)
            latest_version = maximum(VersionNumber.(keys(versions)))
            latest_tree = versions[string(latest_version)]["git-tree-sha1"]

            if tree_hash == latest_tree
                continue
            end

            if package_version <= latest_version
                bumped_version = VersionNumber(package_version.major,
                                               package_version.minor,
                                               package_version.patch + 1)
                project["version"] = string(bumped_version)
                open(project_path, "w") do io
                    TOML.print(io, project)
                end

                run(Cmd(["git", "-C", pkg_path, "add", "Project.toml"]))
                run(Cmd(["git", "-C", pkg_path, "commit", "-m", "v$(bumped_version)"]))
                run(Cmd(["git", "-C", pkg_path, "push"]))
            end
        end

        register()
    end

    Pkg.activate(".")
end


function migrateJSON(package_path)
    Pkg.activate(package_path)
    project_path = Base.active_project()
    project = TOML.parsefile(project_path)
    dependencies = get(project, "deps", Dict{String,Any}())
    source_files = String[]

    for (root, _, files) in walkdir(package_path)
        for file in files
            endswith(file, ".jl") || continue
            source_path = joinpath(root, file)
            occursin("JSON3", read(source_path, String)) && push!(source_files, source_path)
        end
    end
    if !haskey(dependencies, "JSON3") && isempty(source_files)
        return
    end

    if haskey(dependencies, "JSON3")
        Pkg.rm("JSON3")
    end
    if !haskey(dependencies, "JSON")
        Pkg.add("JSON")
    end

    for source_path in source_files
        source = read(source_path, String)
        migrated = replace(source,
            r"JSON3\s*\.\s*read\s*\(\s*read\s*\(\s*([^(),]+?)\s*,\s*String\s*\)\s*\)" =>
                m -> "JSON.parsefile($(strip(m.captures[1])))")
        migrated = replace(migrated, r"JSON3\s*\.\s*write\s*\(" => "JSON.json(")
        migrated = replace(migrated, r"JSON3\s*\.\s*read\s*\(" => "JSON.parse(")
        migrated = replace(migrated, "using JSON3" => "using JSON",
            "import JSON3" => "import JSON")
        if migrated != source
            write(source_path, migrated)
        end
    end
end