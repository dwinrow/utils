using Pkg, TOML

# 🔍 EDIT THIS: Set the target package you want to hunt down
target_package = "Git_jll"

manifest_usage_path = joinpath(DEPOT_PATH[1], "logs", "manifest_usage.toml")

if isfile(manifest_usage_path)
    # 1. Parse all known environments tracking on your machine
    usage_data = TOML.parsefile(manifest_usage_path)
    active_manifests = [String(k) for k in keys(usage_data) if isfile(String(k))]
    
    println("🔎 Searching through $(length(active_manifests)) environments for '$target_package'...\n")
    found_any = false

    # 2. Check each environment's Manifest file
    for manifest_path in active_manifests
        try
            manifest_content = TOML.parsefile(manifest_path)
            
            # Manifests can be structured as dictionaries of packages
            if haskey(manifest_content, "deps") # Julia v1.7+ format
                deps = manifest_content["deps"]
                if haskey(deps, target_package)
                    println("📌 Found in: $(dirname(manifest_path))")
                    found_any = true
                end
            else # Older flat or alternative format
                if haskey(manifest_content, target_package)
                    println("📌 Found in: $(dirname(manifest_path))")
                    found_any = true
                end
            end
        catch
            # Skip corrupted or unreadable manifest files safely
        end
    end
    
    if !found_any
        println("✅ Clean! No active environments are tracking '$target_package'.")
    end
else
    println("Could not locate your Julia manifest usage logs.")
end