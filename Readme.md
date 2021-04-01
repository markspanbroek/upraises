Upraises
========

Helps with exception tracking on older versions of Nim.

Exception tracking
------------------

[Exception tracking in Nim][1] can be used to explicitly define which exceptions
a proc is allowed to raise.

For instance you can declare a proc that is guaranteed to only raise `IOError`s:

```nim
proc example {.raises: [IOError].} =
  # only allowed to raise IOError
```

Or a proc that is guaranteed to not raise any errors at all:

```nim
proc example {.raises: [].} =
  # not allowed to raise any errors
```

You can also apply this to a number of procs in one go by using [push and
pop][2] pragmas:

```nim
{.push raises:[].}

proc example1 =
  # not allowed to raise any errors

proc example2 =
  # not allowed to raise any errors either

{.pop.}
```

Nim 1.2 versus 1.4
------------------

Versions of Nim before 1.4 handled `Error`s (that you can catch) and `Defect`s
(that you shouldn't catch) differently. In practice this means that there's
always the possiblity that your code may raise a `Defect`. So in Nim 1.2 you
specify `{.raises: [Defect].}` instead of `{.raises: [].}` for procs that are
not expected to raise an `Error`.

The unfortunate side-effect is that the compiler will output a bunch of hints
about `Defect` being declared but not used.

Using Upraises:
---------------

You can use Upraises to work around the differences between Nim 1.2 and 1.4. You
should only use Upraises when your code needs to be backwards compatible with
Nim 1.2.

Use the [Nimble][3] package manager to add `upraises` to an existing project.
Add the following to its .nimble file:

```nim
requires "upraises >= 0.1.0 & < 0.2.0"
```

Now you can use `upraises` instead of `raises`:

```nim
proc example {.upraises: [].} =
  # not allowed to raise any errors
```

This will translate into `{.raises: [].}` for Nim 1.4, and into `{.raises:
[Defect].}` for Nim 1.2. It also inserts code to suppress the hint about
`Defect` not being used in Nim 1.2.

You can also apply `upraises` to a number of procs in one go:

```nim
push: {.upraises: [].}

proc example1 =
  # not allowed to raise any errors

proc example2 =
  # not allowed to raise any errors either

{.pop.}
```

Note the slightly different syntax for `push`; this is required because Nim currently [doesn't support][3] pushing custom pragmas.

[1]: https://nim-lang.org/docs/manual.html#effect-system-exception-tracking
[2]: https://nim-lang.org/docs/manual.html#pragmas-push-and-pop-pragmas
[3]: https://github.com/nim-lang/Nim/issues/12867
