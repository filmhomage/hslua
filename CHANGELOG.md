## Changelog
### 0.9.1

- Increase user-friendlyness of error messages: The error message returned by
  `toHaskellFunction` hinted at the fact that the failing function is a Haskell
  function. This is mostly unnecessary information and might have confused
  users.

### 0.9.0

- Added cabal flag to allow fully safe garbage collection: Lua garbage
  collection can occur in most of the API functions, even in those usually not
  calling back into haskell and hence marked as optimizable. The effect of this
  is that finalizers which call Haskell functions will cause the program to
  hang. A new flag `allow-unsafe-gc` is introduced and enabled by default.
  Disabling this flag will mark more C API functions as potentially calling back
  into Haskell. This has a serious performance impact.
- `FromLuaStack` and `ToLuaStack` instances for lazy ByteStrings are added.
- None-string error messages are handled properly: Lua allows error messages to
  be of any type, but the haskell error handlers expected string values. Tables,
  booleans, and other non-string values are now handled as well and converted to
  strings.

### 0.8.0

- Use newtype definitions instead of type aliases for LuaNumber and LuaInteger.
  This makes it easier to ensure the correct numeric instances in situations
  where Lua might have been compiled with 32-bit numbers.
- Instances of `FromLuaStack` and `ToLuaStack` for `Int` are removed. The
  correctness of these instances cannot be guaranteed if Lua was compiled with a
  non-standard integer type.

### 0.7.1

- The flag `lua_32bits` was added to allow users to compile Lua for 32-bit
  systems.
- When reading a list, throw an error if the lua value isn't a table instead of
  silently returning an empty list.

### 0.7.0

- Tuples from pairs to octuples have been made instances of `FromLuaStack` and
  `ToLuaStack`.
- New functions `dostring` and `dofile` are provided to load and run strings and
  files in a single step.
- `LuaStatus` was renamed to `Status`, the *Lua* prefix was removed from its
  type constructors.
- The constructor `ErrFile` was added to `Status`. It is returned by `loadfile`
  if the file cannot be read.
- Remove unused FFI bindings and unused types, including all functions unsafe to
  use from within Haskell and the library functions added with 0.5.0. Users with
  special requirements should define their own wrappers and raw bindings.
- The module *Foreign.Lua.Api.SafeBindings* was merge into
  *Foreign.Lua.Api.RawBindings*.
- FFI bindings are changed to use newtypes where sensible, most notably
  `StackIndex`, `NumArgs`, and `NumResults`, but also the newly introduced
  newtypes `StatusCode`, `TypeCode`, and `LuaBool`.
- Add functions `tointegerx` and `tonumberx` which can be used to get and check
  values from the stack in a single step.
- The signature of `concat` was changed from `Int -> Lua ()` to
  `NumArgs -> Lua ()`.
- The signature of `loadfile` was changed from `String -> Lua Int` to
  `String -> Lua Status`. 
- The type `LTYPE` was renamed to `Type`, its constructors were renamed to
  follow the pattern `Type<Typename>`. `LuaRelation` was renamed to
  `RelationalOperator`, the *Lua* prefix was removed from its constructors.
- Add function `tolist` to allow getting a generic list from the stack without
  having to worry about the overlapping instance with `[Char]`.


### 0.6.0

* Supported Lua Versions now include Lua 5.2 and Lua 5.3. LuaJIT and Lua 5.1
  remain supported as well.
* Flag `use-pkgconfig` was added to allow discovery of library and include paths
  via pkg-config. Setting a specific Lua version flag now implies `system-lua`.
  (Sean Proctor)
* The module was renamed from `Scripting.Lua` to `Foreign.Lua`. The code is now
  split over multiple sub-modules. Files processed with hsc2hs are restricted to
  Foreign.Lua.Api.
* A `Lua` monad (reader monad over LuaState) is introduced. Functions which took
  a LuaState as their first argument are changed into monadic functions within
  that monad.
* Error handling has been redesigned completely. A new LuaException was
  introduced and is thrown in unexpected situations. Errors in lua which are
  leading to a `longjmp` are now caught with the help of additional C wrapper
  functions. Those no longer lead to uncontrolled program termination but are
  converted into a LuaException.
* `peek` no longer returns `Maybe a` but just `a`. A LuaException is thrown if
  an error occurs (i.e. in situtations where Nothing would have been returned
  previously).
* The `StackValue` typeclass has been split into `FromLuaStack` and
  `ToLuaStack`. Instances not satisfying the law `x == push x *> peek (-1)` have
  been dropped.
* Documentation of API functions was improved. Most docstrings have been copied
  from the official Lua manual, enriched with proper markup and links, and
  changed to properly describe hslua specifics when necessary.
* Example programs have been moved to a separate repository.
* Unused files were removed. (Sean Proctor)

### 0.5.0

* New raw functions for `luaopen_base`, `luaopen_package`, `luaopen_string`,
  `luaopen_table`, `luaopen_math`, `luaopen_io`, `luaopen_os`, `luaopen_debug`
  and their high-level wrappers (with names `openbase`, `opentable` etc.)
  implemented.
* Remove custom versions of `loadfile` and `loadstring`.
* Drop support for GHC versions < 7.8, avoid compiler warnings.
* Ensure no symbols are stripped when linking the bundled lua interpreter.
* Simplify `tostring` function definition. (Sean Proctor)
* Explicitly deprecate `strlen`. (Sean Proctor)
* Add links to lua documentation for functions wrapping the official lua C API.
  (Sean Proctor).

### 0.4.1

* Bugfix(#30): `tolist` wasn't popping elements of the list from stack.

### 0.4.0

* `pushstring` and `tostring` now uses `ByteString` instead of `[Char]`.
* `StackValue [Char]` instance is removed, `StackValue ByteString` is added.
* `StackValue a => StackValue [a]` instance is added. It pushes a Lua array to
  the stack. `pushlist`, `islist` and `tolist` functions are added.
* Type errors in Haskell functions now propagated differently. See the
  `Scripting.Lua` documentation for detailed explanation. This should fix
  segfaults reported several times.
* `lua_error` function is removed, it's never safe to call in Haskell.

Related issues and pull requests: #12, #26, #24, #23, #18.

### 0.3.14

* Pkgconf-based setup removed. Cabal is now using `extra-libraries` to link with Lua.
* `luajit` flag is added to link hslua with LuaJIT.

### 0.3.13

* Small bugfix related with GHCi running under Windows.

### 0.3.12

* `pushrawhsfunction` and `registerrawhsfunction` functions are added.
* `apicheck` flag is added to Cabal package to enable Lua API checking. (useful for debugging)

### 0.3.11

* `luaL_ref` and `luaL_unref` functions are added.
