using Bukdu # ApplicationController Conn JavaScript Plug.Static Router Utils CLI render routes get plug

#=
using Charlotte # @code_wasm

    relu(x) = ifelse(x < 0, 0, x)
    w = @code_wasm relu(1)
    wast = string(w)
    Render("application/octet-stream", unsafe_wrap(Vector{UInt8}, wast))

(func (param i64) (result i64)
  (i64.const 0)
  (get_local 0)
  (get_local 0)
  (i64.const 0)
  (i64.lt_s)
  (select)
  (return))
=#

struct WasmController <: ApplicationController
    conn::Conn
end

function hello_wast(::WasmController)
    render(Text, """
(module
  (type (;0;) (func (param i32 i32)))
  (type (;1;) (func))
  (import "env" "memory" (memory (;0;) 256 256))
  (import "env" "print" (func (;0;) (type 0)))
  (func (;1;) (type 1)
    i32.const 1400
    i32.const 13  ;; length
    call 0)
  (export "_main" (func 1))
  (data (i32.const 1400) "Hello, world!"))
""")
end

# https://gist.github.com/SpaceManiac/daf03e0ac6ed56e7a7723ccdeaf5cfe2
function hello_js(::WasmController)
    render(JavaScript, """
var memory = new WebAssembly.Memory({initial:256, maximum:256});
var imports = { 'env': { 'memory': memory, 'print': print, } };

function console_out(text) {
    let LF = "\\n";
    var c = document.getElementById('console');
    c.innerText += text + LF;
}

function print(ptr, len) {
    let text = new TextDecoder().decode(new DataView(memory.buffer, ptr, len));
    console_out(text);
};

async function fetch_wast() {
    console_out("fetch_wast /hello.wast");
    let res = await fetch('/hello.wast');
    return res.arrayBuffer();
}

function wast_to_wasm(buf) {
    console_out("wast_to_wasm (wast: " + buf.byteLength + " bytes)");
    let module = wabt.parseWat('hello.wast', buf);
    module.resolveNames();
    module.validate();
    let bin = module.toBinary({log: true, write_debug_names: true});
    return bin.buffer;
}

function wasm_instantiate(bytes) {
    console_out("wasm_instantiate (wasm: " + bytes.length + " bytes)");
    return WebAssembly.instantiate(bytes, imports);
}

function call_result_instance_main(result) {
    console_out("call_result_instance_main()");
    result.instance.exports._main();
}

document.addEventListener('DOMContentLoaded', function () {
    wabt.ready.then(fetch_wast)
              .then(wast_to_wasm)
              .then(wasm_instantiate)
              .then(call_result_instance_main);
});
""")
end

using InteractiveUtils # versioninfo
function get_banner_versioninfo()
    Utils.read_stdout() do
        Base.banner()
        versioninfo()
    end
end

function index(::WasmController)
    render(HTML, """
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
  <title>Bukdu sevenstars</title>
  <script src="/javascripts/libwabt.js"></script>
  <script src="/hello.js"></script>
  <style>
    div#console {
      background-color: lightgoldenrodyellow;
      border-style: ridge;
    }
  </style>
</head>
<body>
  <h3>Bukdu sevenstars</h3>
  <ul>
    <li>Full code of this page => <a href="https://github.com/wookay/Bukdu.jl/blob/sevenstars/examples/wasm.jl">https://github.com/wookay/Bukdu.jl/blob/sevenstars/examples/wasm.jl</a></li>
    <li>Heroku example => <a href="https://github.com/wookay/heroku-sevenstars">https://github.com/wookay/heroku-sevenstars</a></li>
  </ul>
  <pre>$(get_banner_versioninfo())</pre>
  <div id="console" />
</body>
</html>
""")
end



if PROGRAM_FILE == basename(@__FILE__)

routes() do
    get("/", WasmController, index)
    get("/hello.js", WasmController, hello_js)
    get("/hello.wast", WasmController, hello_wast)
    plug(Plug.Static, at="/", from=normpath(@__DIR__, "public"))
end

# on Heroku
import Sockets: @ip_str
Bukdu.start(parse(Int,ENV["PORT"]); host=ip"0.0.0.0")
# Bukdu.start(8080)

Router.request(get, "/") #
CLI.routes() #

Base.JLOptions().isinteractive==0 && wait()

# Bukdu.stop()

end # if
