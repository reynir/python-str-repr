let repr = Python_str_repr.repr

let test_repr =
  let make_test (message, input, expected) =
    message, `Quick, fun () -> Alcotest.(check string) message expected (repr input)
  in
  List.map make_test [
    "empty", "", "''";
    "simple", "a", "'a'";
    "one single quote", {|'|}, {|"'"|};
    "one single double quote", {|"|}, {|'"'|};
    "tab character", "tab\tthis", {|'tab\tthis'|};
    "line feed", "new\nline", {|'new\nline'|};
    "carraige return line feed", "Host: example.com\r\n", {|'Host: example.com\r\n'|};

    "non-printable ascii", "\x00\x7f\x20\x10", {|'\x00\x7f \x10'|};

    "mixed quotes", "\"I told him 'no' back then.\"", {|'"I told him \'no\' back then."'|};
    "mixed quotes, mainly single quotes", "'''\"'''", {|'\'\'\'"\'\'\''|};
    "mixed quotes, mainly double quotes", "\"\"\"'\"\"\"", {|'"""\'"""'|};
]

let test_repr_fail =
  let test_unicode_fails () =
    try
      Alcotest.(check string) "unicode 'æ'" "'æ'" (repr "æ")
    with Invalid_argument _ ->
      (* TODO *)
      ()
  in
  ["unicode fails", `Quick, test_unicode_fails]

let test_suites = [
  "repr", test_repr;
  "repr fail", test_repr_fail;
]

let () =
  Alcotest.run
    "python-str-repr"
    test_suites
