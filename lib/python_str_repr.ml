(*
static PyObject *
unicode_repr(PyObject *unicode)
{
    PyObject *repr;
    Py_ssize_t isize;
    Py_ssize_t osize, squote, dquote, i, o;
    Py_UCS4 max, quote;
    int ikind, okind, unchanged;
    const void *idata;
    void *odata;

    isize = PyUnicode_GET_LENGTH(unicode);
    idata = PyUnicode_DATA(unicode);

    /* Compute length of output, quote characters, and
       maximum character */
    osize = 0;
    max = 127;
    squote = dquote = 0;
    ikind = PyUnicode_KIND(unicode);
    for (i = 0; i < isize; i++) {
        Py_UCS4 ch = PyUnicode_READ(ikind, idata, i);
        Py_ssize_t incr = 1;
        switch (ch) {
        case '\'': squote++; break;
        case '"':  dquote++; break;
        case '\\': case '\t': case '\r': case '\n':
            incr = 2;
            break;
        default:
            /* Fast-path ASCII */
            if (ch < ' ' || ch == 0x7f)
                incr = 4; /* \xHH */
            else if (ch < 0x7f)
                ;
            else if (Py_UNICODE_ISPRINTABLE(ch))
                max = ch > max ? ch : max;
            else if (ch < 0x100)
                incr = 4; /* \xHH */
            else if (ch < 0x10000)
                incr = 6; /* \uHHHH */
            else
                incr = 10; /* \uHHHHHHHH */
        }
        if (osize > PY_SSIZE_T_MAX - incr) {
            PyErr_SetString(PyExc_OverflowError,
                            "string is too long to generate repr");
            return NULL;
        }
        osize += incr;
    }

    quote = '\'';
    unchanged = (osize == isize);
    if (squote) {
        unchanged = 0;
        if (dquote)
            /* Both squote and dquote present. Use squote,
               and escape them */
            osize += squote;
        else
            quote = '"';
    }
    osize += 2;   /* quotes */

    repr = PyUnicode_New(osize, max);
    if (repr == NULL)
        return NULL;
    okind = PyUnicode_KIND(repr);
    odata = PyUnicode_DATA(repr);

    PyUnicode_WRITE(okind, odata, 0, quote);
    PyUnicode_WRITE(okind, odata, osize-1, quote);
    if (unchanged) {
        _PyUnicode_FastCopyCharacters(repr, 1,
                                      unicode, 0,
                                      isize);
    }
    else {
        for (i = 0, o = 1; i < isize; i++) {
            Py_UCS4 ch = PyUnicode_READ(ikind, idata, i);

            /* Escape quotes and backslashes */
            if ((ch == quote) || (ch == '\\')) {
                PyUnicode_WRITE(okind, odata, o++, '\\');
                PyUnicode_WRITE(okind, odata, o++, ch);
                continue;
            }

            /* Map special whitespace to '\t', \n', '\r' */
            if (ch == '\t') {
                PyUnicode_WRITE(okind, odata, o++, '\\');
                PyUnicode_WRITE(okind, odata, o++, 't');
            }
            else if (ch == '\n') {
                PyUnicode_WRITE(okind, odata, o++, '\\');
                PyUnicode_WRITE(okind, odata, o++, 'n');
            }
            else if (ch == '\r') {
                PyUnicode_WRITE(okind, odata, o++, '\\');
                PyUnicode_WRITE(okind, odata, o++, 'r');
            }

            /* Map non-printable US ASCII to '\xhh' */
            else if (ch < ' ' || ch == 0x7F) {
                PyUnicode_WRITE(okind, odata, o++, '\\');
                PyUnicode_WRITE(okind, odata, o++, 'x');
                PyUnicode_WRITE(okind, odata, o++, Py_hexdigits[(ch >> 4) & 0x000F]);
                PyUnicode_WRITE(okind, odata, o++, Py_hexdigits[ch & 0x000F]);
            }

            /* Copy ASCII characters as-is */
            else if (ch < 0x7F) {
                PyUnicode_WRITE(okind, odata, o++, ch);
            }

            /* Non-ASCII characters */
            else {
                /* Map Unicode whitespace and control characters
                   (categories Z* and C* except ASCII space)
                */
                if (!Py_UNICODE_ISPRINTABLE(ch)) {
                    PyUnicode_WRITE(okind, odata, o++, '\\');
                    /* Map 8-bit characters to '\xhh' */
                    if (ch <= 0xff) {
                        PyUnicode_WRITE(okind, odata, o++, 'x');
                        PyUnicode_WRITE(okind, odata, o++, Py_hexdigits[(ch >> 4) & 0x000F]);
                        PyUnicode_WRITE(okind, odata, o++, Py_hexdigits[ch & 0x000F]);
                    }
                    /* Map 16-bit characters to '\uxxxx' */
                    else if (ch <= 0xffff) {
                        PyUnicode_WRITE(okind, odata, o++, 'u');
                        PyUnicode_WRITE(okind, odata, o++, Py_hexdigits[(ch >> 12) & 0xF]);
                        PyUnicode_WRITE(okind, odata, o++, Py_hexdigits[(ch >> 8) & 0xF]);
                        PyUnicode_WRITE(okind, odata, o++, Py_hexdigits[(ch >> 4) & 0xF]);
                        PyUnicode_WRITE(okind, odata, o++, Py_hexdigits[ch & 0xF]);
                    }
                    /* Map 21-bit characters to '\U00xxxxxx' */
                    else {
                        PyUnicode_WRITE(okind, odata, o++, 'U');
                        PyUnicode_WRITE(okind, odata, o++, Py_hexdigits[(ch >> 28) & 0xF]);
                        PyUnicode_WRITE(okind, odata, o++, Py_hexdigits[(ch >> 24) & 0xF]);
                        PyUnicode_WRITE(okind, odata, o++, Py_hexdigits[(ch >> 20) & 0xF]);
                        PyUnicode_WRITE(okind, odata, o++, Py_hexdigits[(ch >> 16) & 0xF]);
                        PyUnicode_WRITE(okind, odata, o++, Py_hexdigits[(ch >> 12) & 0xF]);
                        PyUnicode_WRITE(okind, odata, o++, Py_hexdigits[(ch >> 8) & 0xF]);
                        PyUnicode_WRITE(okind, odata, o++, Py_hexdigits[(ch >> 4) & 0xF]);
                        PyUnicode_WRITE(okind, odata, o++, Py_hexdigits[ch & 0xF]);
                    }
                }
                /* Copy characters as-is */
                else {
                    PyUnicode_WRITE(okind, odata, o++, ch);
                }
            }
        }
    }
    /* Closing quote already added at the beginning */
    assert(_PyUnicode_CheckConsistency(repr, 1));
    return repr;
}
   *)

let repr s =
  let osize, squote, dquote =
    String.fold_left
      (fun (osize, squote, dquote) c ->
         match c with
         | '\'' ->
           (succ osize, succ squote, dquote)
         | '"' ->
           (succ osize, squote, succ dquote)
         | '\\' | '\t' | '\r' | '\n' ->
           (osize + 2, squote, dquote)
         | '\x00'..'\x1f' (* c < ' ' *) | '\x7f' ->
           (osize + 4, squote, dquote)
         | ' '..'~' ->
           (succ osize, squote, dquote)
         | _ ->
           (* TODO: unicode *)
           invalid_arg "repr"
      )
      (0, 0, 0)
      s
  in
  let quote, osize =
    match squote, dquote with
    | 0, _ -> '\'', osize + 2
    | _non_zero, 0 -> '"', osize + 2
    | _non_zero, _non_zero' -> '\'', osize + squote + 2
  in
  if osize = String.length s + 2 then
    Printf.sprintf "%c%s%c" quote s quote
  else begin
    let b = Buffer.create osize in
    Buffer.add_char b quote;
    String.iter (function
        | '\'' | '"' as c ->
          if c = quote then
            Buffer.add_char b '\\';
          Buffer.add_char b c
        | '\t' | '\n' | '\r' as c ->
          Buffer.add_string b (Char.escaped c)
        | '\x00'..'\x1f' (* c < ' ' *) | '\x7f' as c ->
          Printf.ksprintf (Buffer.add_string b) "\\x%02x" (Char.code c)
        | ' '..'~' as c -> 
          (* ASCII printable char *)
          Buffer.add_char b c
        | _non_ascii ->
          assert false)
      s;
    Buffer.add_char b quote;
    assert (Buffer.length b = osize);
    Buffer.contents b
  end
