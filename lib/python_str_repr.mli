val repr : string -> string
(** [repr s] is the representation of [s] as a Python escaped string. That is,
    the output of {[str.repr(s)]} in Python. Only ASCII strings are supported.

    @raise Invalid_arg if the input string contains non-ascii characters.
*)
