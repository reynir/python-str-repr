
let py_repr =
  let open Py in
  let py_repr_fn = Object.get_item_s (builtins ()) "str" $. String "__repr__" in
  PyWrap.(python_fn (string @-> returning string)) py_repr_fn

let test_repr =
  let inputs = [
    "";
    "a";
    "'";
    "\"";
    "tab\tthis";

  ]
  in
  List.map (fun input ->
      Printf.sprintf "%S" input, `Quick, (fun () ->
          Alcotest.(check string) input (py_repr input) (Python_str_repr.repr input)))
    inputs

let test_suites = [
  "py repr", test_repr;
]

let () =
  Alcotest.run
    "python-str-repr"
    test_suites
