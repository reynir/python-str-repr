(lang dune 3.7)

(name python-str-repr)

(generate_opam_files true)

(source
 (github reynir/python-str-repr))

(authors "Reynir Björnsson <reynir@reynir.dk>")

(maintainers "Reynir Björnsson <reynir@reynir.dk>")

(license BSD-2-Clause)

(documentation https://reynir.github.io/python-str-repr)

(package
 (name python-str-repr)
 (synopsis "Python string escaping for OCaml")
 (description "\
This library attempts to implement Python's str.__repr__() function. That is,
string escaping as done in Python.")
 (depends ocaml dune uutf uucp (alcotest :with-test) (py :with-test) (qcheck :with-test) (qcheck-alcotest :with-test))
 (tags (python)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
