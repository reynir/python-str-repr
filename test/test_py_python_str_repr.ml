
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

let test_repr_unicode =
  let inputs = [
    "\u{80}";
  ]
  in
  List.map (fun input ->
      Printf.sprintf "%S" input, `Quick, (fun () ->
          Alcotest.(check string) input (py_repr input) (Python_str_repr.repr input)))
    inputs

let test_repr_qcheck =
  let valid_utf8 =
    let folder acc _index = function
      | `Uchar _ -> acc
      | `Malformed _ -> false
    in
    Uutf.String.fold_utf_8 folder true
  in
  let test_case =
    QCheck2.Test.make
      ~print:(fun s ->
          Printf.sprintf "%S: %S vs %S" s
            (py_repr s) (Python_str_repr.repr s))
      ~name:"repr qcheck"
      QCheck2.Gen.string
      (fun s ->
         QCheck2.assume (valid_utf8 s);
         String.equal (py_repr s) (Python_str_repr.repr s))
  in
  [ QCheck_alcotest.to_alcotest test_case ]

let test_suites = [
  "py repr", test_repr;
  "py repr unicode", test_repr_unicode;
  "py repr qcheck", test_repr_qcheck;
]

let () =
  Alcotest.run
    "python-str-repr"
    test_suites
