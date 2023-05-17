using CIndices
using Documenter

DocMeta.setdocmeta!(CIndices, :DocTestSetup, :(using CIndices); recursive=true)

makedocs(;
    modules=[CIndices],
    authors="Willow Ahrens <willow@csail.mit.edu>, Raye Kimmerer <kimmerer@mit.edu>",
    repo="https://github.com/JuliaSparse/CIndices.jl/blob/{commit}{path}#{line}",
    sitename="CIndices.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://cindices.juliasparse.org",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/JuliaSparse/CIndices.jl",
    devbranch="main",
)
