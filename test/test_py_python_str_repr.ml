
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

let test_repr_qcheck =
  let test_case =
    QCheck2.Test.make
      ~print:(Printf.sprintf "%S")
      ~name:"repr qcheck"
      QCheck2.Gen.(string_of (char_range ~origin:'a' '\x00' '\x7f'))
      (fun s ->
         String.equal (py_repr s) (Python_str_repr.repr s))
  in
  [ QCheck_alcotest.to_alcotest test_case ]

let test_suites = [
  "py repr", test_repr;
  "py repr qcheck", test_repr_qcheck;
]

let () =
  Alcotest.run
    "python-str-repr"
    test_suites
