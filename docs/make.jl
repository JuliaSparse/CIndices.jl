using CIndices
using Documenter

DocMeta.setdocmeta!(CIndices, :DocTestSetup, :(using CIndices); recursive=true)

makedocs(;
    modules=[CIndices],
    authors="Willow Ahrens <willow.ahrens@mit.edu, Raye Kimmerer <kimmerer@mit.edu>",
    repo="https://github.com/Wimmerer/CIndices.jl/blob/{commit}{path}#{line}",
    sitename="CIndices.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://Wimmerer.github.io/CIndices.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Wimmerer/CIndices.jl",
    devbranch="main",
)
