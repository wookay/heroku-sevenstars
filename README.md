Bukdu sevenstars 🌌  on Heroku
==============================

* Go to the demo site =>  https://sevenstars.herokuapp.com

------------------

[Bukdu](https://github.com/wookay/Bukdu.jl) is a web development framework for Julia (http://julialang.org).

It's influenced by Phoenix framework (http://phoenixframework.org).

You can run Bukdu on [Heroku](https://www.heroku.com/).

 * Heroku: Create new app like this.

   - [heroku-sevenstars](https://github.com/wookay/heroku-sevenstars)

 * Heroku: Add a buildpack on **Settings** -> **Add buildpack**

   - [https://github.com/wookay/heroku-buildpack-julia-07](https://github.com/wookay/heroku-buildpack-julia-07)

```sh
λ ~/work/heroku-sevenstars $ heroku buildpacks
=== sevenstars Buildpack URL
https://github.com/wookay/heroku-buildpack-julia-07

λ ~/work/heroku-sevenstars $ git push heroku master
```

 * Get more information: [https://devcenter.heroku.com/categories/deployment](https://devcenter.heroku.com/categories/deployment)


