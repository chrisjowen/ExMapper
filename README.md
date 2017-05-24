ExMapper
--------

Defining non trivial transformations from incoming maps to Structs.

#Quick example

```
  defmodule Bar do
    use ExMapper.DefMapping
    defstruct [:baz]

    defmapping do
      override :baz, key: &string_key_prefix/1, value: &times_two/1
    end

    defp times_two(input), do: input * 2
    defp string_key_prefix(key), do: "KEY_#{key}"

  end


  defmodule Foo do
    use ExMapper.DefMapping
    defstruct [:bar, :a]

    defmapping do
      keys: :atomized
      override :bar, value: one(%Bar{}, Bar.mappings)
    end
  end
```

Then:

```
  ExMapper.map(%Foo{}, input, Foo.mappings)
```

Usage
------

To define a mapping use the `ExMapper.DefMapping` DSL and the `defmapping` macro. The result is the module will have a
`mappings` function which you can pass to ExMapper.

Once in a `defmapping` block, two macros are avaliable for you:

- `keys/1` takes either an atom [:atomized|:stringified] which will tell the mapper to look in the input for matching keys of either string or
atom type. Or, you can provide a function in the format `struct_key -> expected_key`
- `overrides/2` - takes the struct key and Options

Override options can include:

- `key:` either a string/atom value to query the input map. Or similarly with the overall keys definition you can specify a function in the format `struct_key -> expected_key`
- `value:` either a string/atom value to use despite whats in the input map. Or more useful a function in the format `input_value -> transformed_value`

Notes
------

- Mappings and structs do not, and really should not be in the same module if you have several mapping definitions for a struct
- Helper functions `one` and `many` allow mapping to nested Structs
