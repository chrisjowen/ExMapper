defmodule ExMapper.DefMapping do
  defmacro __using__(_) do
    quote do
      require ExMapper.DefMapping
      import ExMapper.DefMapping
      @before_compile { unquote(__MODULE__), :__before_compile__ }
      @mappings %ExMapper.Options{}

      def many(struct, opts \\ %ExMapper.Options{}), do: &many(struct, &1, opts)
      defp many(struct, value, opts) when is_list(value), do: value |> Enum.map(&one(struct, &1, opts))
      defp many(_, _, _), do: []

      def one(struct, opts \\ %ExMapper.Options{}), do: &one(struct, &1, opts)
      defp one(struct, val, opts), do: ExMapper.map(struct, val, opts)
    end
  end

  defmacro __before_compile__(_) do
    quote do
      def mappings(), do: @mappings
    end
  end

  defmacro defmapping(block) do
    quote do
      unquote(block)
    end
  end

  defmacro keys(val) do
    quote do
      @mappings Map.put(@mappings, :keys, unquote(val))
    end
  end

  defmacro override(struct_key, override) do
    key = Keyword.get(override, :key, :default)
    value = Keyword.get(override, :value, :default)
    key_func_name = "#{struct_key}_key" |> String.to_atom
    value_func_name = "#{struct_key}_value" |> String.to_atom

    # Note: Akward that we must do this here, but we cannot evaluate the value of key/value in quote incase its a missing local function
    use_key_default = key == :default
    use_value_default = value ==:default

    quote do
      localize_function(unquote(key_func_name), unquote(key))
      localize_function(unquote(value_func_name), unquote(value))

      overrides = Map.put(Map.get(@mappings, :overrides), unquote(struct_key), %ExMapper.Override{
        key: if(unquote(use_key_default), do: :default, else: &__MODULE__.unquote(key_func_name)/1),
        value: if(unquote(use_value_default), do: :default, else: &__MODULE__.unquote(value_func_name)/1)
      })
      @mappings Map.put(@mappings, :overrides, overrides)
    end
  end

  defmacro localize_function(name, defenition) do
    if(is_tuple(defenition)) do
      quote do
        def unquote(name)(input), do: unquote(defenition).(input)
      end
    else
      quote do
        def unquote(name)(input), do: unquote(defenition)
      end
    end
  end

end
