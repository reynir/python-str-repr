# python-str-repr

Escape strings in OCaml as if you were using Python.

The function `Python_str_repr.repr` replicates the behavior of Python's
`str.__repr__()` - that is, `str(s)` where `s` is a string.

## FAQ

- **Why not use `String.escaped` or `Printf.sprintf "%S"`?**  
  Good question. If that works for you, great! But sometimes you need to
  closely replicate the behavior of Python. Python will use different quote
  characters (`'`, `"`) depending on the string contents. OCaml also prefers
  octal escapes (`\234`) for non-printable byte values while python uses hex
  escapes (`\x9c`). Finally, Python uses unicode escape sequences for
  non-printable unicode characters (sorry, see next point) while OCaml strings
  are byte sequences and not unicode aware.
- **Why not support unicode?**  
  I would love to! At the moment I don't have much experience or understanding
  of unicode and utf-8.
