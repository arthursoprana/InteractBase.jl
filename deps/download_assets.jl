using Pkg.Artifacts
using ghr_jll

# See this issue: https://github.com/JuliaGizmos/WebIO.jl/issues/422
interact_base_tag = "v0.10.6"
username = "arthursoprana"

function build_js_bundle(dir)
	deps = Dict(
	    "all.js" => "https://use.fontawesome.com/releases/v5.0.7/js/all.js",
	    "prism.css" => "https://cdn.jsdelivr.net/gh/piever/InteractResources@0.1.0/highlight/prism.css",
	    "prism.js" => "https://cdn.jsdelivr.net/gh/piever/InteractResources@0.1.0/highlight/prism.js",
	    "nouislider.min.js" => "https://cdnjs.cloudflare.com/ajax/libs/noUiSlider/11.1.0/nouislider.min.js",
	    "nouislider.min.css" => "https://cdnjs.cloudflare.com/ajax/libs/noUiSlider/11.1.0/nouislider.min.css",
	    "katex.min.js" => "https://cdnjs.cloudflare.com/ajax/libs/KaTeX/0.9.0/katex.min.js",
	    "katex.min.css" => "https://cdnjs.cloudflare.com/ajax/libs/KaTeX/0.9.0/katex.min.css",
	)

    for (dep_name, dep_url) in deps
		download(
            dep_url,
            joinpath(dir, dep_name),
        )
    end
end

hash = create_artifact() do dir
    # Build all JS files in `dir`
	build_js_bundle(dir)
end

# Now that the artifact is built on our machine and we know its content hash,
# let's package it up into a tarball and host it on GitHub releases:
tarball_hash = mktempdir() do dir
	tarball_hash = archive_artifact(hash, joinpath(dir, "jsbundle.tar.gz"))

	# Use `ghr` from `ghr_jll` to upload this file to the GitHub releases of WebIO.jl
	# Note that I think you will need to export `GITHUB_TOKEN=<token>` before running this.
	# Alternatively, you can skip this step and manually upload the tarball using the browser.
	ghr() do ghr
        run(`$(ghr) -u $(username) -r InteractBase.jl $(interact_base_tag) $(dir)`)
	end
end

# Finally, let's bind this out to our Artifact file.
# This relative pathing is assuming that this script lives within `deps/`.
artifacts_toml = joinpath(dirname(@__DIR__), "Artifacts.toml")
url = "https://github.com/$(username)/InteractBase.jl/releases/download/$(interact_base_tag)/jsbundle.tar.gz"
bind_artifact!(
	# Where the TOML file is that we're writing this binding into
	artifacts_toml,
	# The name of the artifact, used by the `@artifact_str()` macro later
	"jsbundle",
	# The content-hash of the artifact
	hash;
	# Information about how to download this artifact
	download_info = [
		(url, tarball_hash),
	],
)
