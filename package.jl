using Pkg
Pkg.clone("https://github.com/wookay/Bukdu.jl.git")
Pkg.checkout("HTTP", "master")
Pkg.checkout("Bukdu", "sevenstars")
using Bukdu
